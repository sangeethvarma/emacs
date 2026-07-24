;;; san-llm.el --- Minimal Gptel AI Setup -*- lexical-binding: t -*-

;;; Commentary:
;; Phase 4 (Final): Complete setup with YAML frontmatter persistence.
;; Retains the native gptel header-line and avoids injecting into the global modeline.

;;; Code:

(require 'subr-x)

;; ---------------------------------------------------------------------------
;; UTILITIES: PROMPT READING
;; ---------------------------------------------------------------------------
(defun san/read-prompt-file (filename fallback-text)
  "Load prompt content from Vault Sandbox or config directory; fallback if missing."
  (let* ((sandbox-path (if (boundp 'san-vault-root)
                           (expand-file-name (concat "Sandbox/llm-prompts/" filename) san-vault-root)
                         ""))
         (config-path  (expand-file-name (concat "llm-prompts/" filename) user-emacs-directory))
         (target-file  (cond ((and (not (string-empty-p sandbox-path)) 
                                   (file-exists-p sandbox-path)) 
                              sandbox-path)
                             ((file-exists-p config-path) config-path)
                             (t nil))))
    (if target-file
        (with-temp-buffer
          (insert-file-contents target-file)
          (buffer-string))
      (message "Warning: LLM prompt file missing for %s" filename)
      fallback-text)))


;; ---------------------------------------------------------------------------
;; SESSION METADATA (YAML FRONTMATTER)
;; ---------------------------------------------------------------------------
(defun san/gptel-sync-metadata ()
  "Write gptel session metadata into YAML frontmatter before saving."
  (when gptel-mode
    (save-excursion
      (goto-char (point-min))
      (let* ((backend (if gptel-backend (gptel-backend-name gptel-backend) "Ollama-Windows"))
             (model (if (symbolp gptel-model) (symbol-name gptel-model) gptel-model))
             (persona (or (car (rassoc gptel-system-message gptel-directives)) "default")))
        (if (and (looking-at "^---")
                 (save-excursion
                   (forward-line 1)
                   (re-search-forward "^---" 500 t)))
            ;; Update existing YAML block
            (let ((end (save-excursion
                         (forward-line 1)
                         (re-search-forward "^---" 500 t))))
              (goto-char (point-min))
              (when (re-search-forward "^gptel-backend: .*$" end t)
                (replace-match (format "gptel-backend: %s" backend)))
              (goto-char (point-min))
              (when (re-search-forward "^gptel-model: .*$" end t)
                (replace-match (format "gptel-model: %s" model)))
              (goto-char (point-min))
              (when (re-search-forward "^gptel-persona: .*$" end t)
                (replace-match (format "gptel-persona: %s" persona))))
          ;; Insert new YAML block at top of file
          (goto-char (point-min))
          (insert "---\n")
          (insert (format "gptel-backend: %s\n" backend))
          (insert (format "gptel-model: %s\n" model))
          (insert (format "gptel-persona: %s\n" persona))
          (insert "---\n\n"))))))

(defun san/gptel-auto-hydrate-metadata ()
  "Restore gptel session from YAML frontmatter on file open."
  (save-excursion
    (goto-char (point-min))
    (when (and (looking-at "^---")
               (save-excursion
                 (forward-line 1)
                 (re-search-forward "^gptel-backend: " 200 t)))
      (gptel-mode 1)
      (let ((end (save-excursion
                   (forward-line 1)
                   (re-search-forward "^---" 500 t))))
        (when end
          (goto-char (point-min))
          (when (re-search-forward "^gptel-backend: \\(.*?\\)\r?$" end t)
            (setq-local gptel-backend (gptel-get-backend (match-string 1))))
          (goto-char (point-min))
          (when (re-search-forward "^gptel-model: \\(.*?\\)\r?$" end t)
            (setq-local gptel-model (intern (match-string 1))))
          (goto-char (point-min))
          (when (re-search-forward "^gptel-persona: \\(.*?\\)\r?$" end t)
            (let* ((persona-sym (intern (match-string 1)))
                   (msg (alist-get persona-sym gptel-directives)))
              (when msg
                (setq-local gptel-system-message msg)))))))))

;; Bind metadata hooks globally (the functions have internal safeguards)
(add-hook 'before-save-hook #'san/gptel-sync-metadata)
(add-hook 'find-file-hook #'san/gptel-auto-hydrate-metadata)


;; ---------------------------------------------------------------------------
;; UTILITIES: SESSION MANAGEMENT
;; ---------------------------------------------------------------------------
(defun san/gptel-save-directory ()
  "Return the save directory path for gptel conversations."
  (let ((dir (if (boundp 'san-inbox-dir)
                 (expand-file-name "gptel-conversations/" san-inbox-dir)
               (expand-file-name "gptm-conversations/" user-emacs-directory))))
    (unless (file-directory-p dir)
      (make-directory dir t))
    dir))

(defun san/gptel-save-conversation ()
  "Save current conversation with timestamp-based filename."
  (interactive)
  (if gptel-mode
      (let* ((timestamp (format-time-string "%Y-%m-%d_%H-%M-%S"))
             (filename (concat "conversation_" timestamp ".md"))
             (filepath (expand-file-name filename (san/gptel-save-directory))))
        (write-file filepath)
        (message "Conversation saved to: %s" filepath))
    (user-error "Current buffer is not an active gptel session")))

(defun san/gptel-save-named-conversation ()
  "Save current conversation with user-provided name."
  (interactive)
  (if gptel-mode
      (let* ((default-name (format-time-string "gptel_%Y-%m-%d"))
             (custom-name (read-string "Save conversation as (no extension): " default-name))
             (filename (concat custom-name ".md"))
             (filepath (expand-file-name filename (san/gptel-save-directory))))
        (write-file filepath)
        (message "Conversation saved at: %s" filepath))
    (user-error "Current buffer is not an active gptel session")))

(defun san/gptel-load-conversation ()
  "Interactively load previously saved conversation."
  (interactive)
  (unless (file-directory-p (san/gptel-save-directory))
    (user-error "Conversation directory missing: %s" (san/gptel-save-directory)))
  (let* ((md-files (directory-files (san/gptel-save-directory) nil "\\.md$"))
         (selected-file (completing-read "Load conversation: " md-files nil t)))
    (when selected-file
      (let ((filepath (expand-file-name selected-file (san/gptel-save-directory))))
        (find-file filepath)
        (message "Loaded conversation from: %s" selected-file)))))

(defun san/gptel-save-to-silo ()
  "Save active conversation to designated PARA note silo."
  (interactive)
  (if gptel-mode
      (if (boundp 'san-denote-silo-alist)
          (let* ((silo-name (completing-read "Save to silo: "
                                             (mapcar #'car san-denote-silo-alist)))
                 (silo-path (cdr (assoc silo-name san-denote-silo-alist)))
                 (gptel-convo-path (expand-file-name "conversations/" silo-path))
                 (timestamp (format-time-string "%Y-%m-%d_%H-%M-%S"))
                 (filename (concat "ai_conversation_" timestamp ".md"))
                 (filepath (expand-file-name filename gptel-convo-path)))
            (unless (file-directory-p gptel-convo-path)
              (make-directory gptel-convo-path t))
            (write-file filepath)
            (message "Saved to %s silo: %s" silo-name filepath))
        (user-error "Warning: san-denote-silo-alist is not yet loaded"))
    (user-error "Current buffer is not an active gptel session")))


;; ---------------------------------------------------------------------------
;; MAIN PACKAGE CONFIGURATION
;; ---------------------------------------------------------------------------
(use-package gptel
  :ensure t
  :defer t
  :bind (("C-c g g" . gptel)
         ("C-c g s" . gptel-send)
         ("C-c g m" . gptel-menu)
         ("C-c g l" . san/gptel-load-conversation))
  :config

  ;; 1. OLLAMA LOCAL BACKEND SETUP
  (defun san/gptel-initialize-ollama ()
    "Configure local Ollama backend with WSL host network integration."
    (let ((host-ip "127.0.0.1"))
      (when (and (fboundp 'san/wsl-p) (san/wsl-p))
        (let ((route-ip (string-trim (shell-command-to-string
                                      "ip route | grep default | awk '{print $3}'"))))
          (unless (string-empty-p route-ip)
            (setq host-ip route-ip))))
      (gptel-make-ollama "Ollama-Windows"
        :host (concat host-ip ":11434")
        :stream t
        :models '(qwen2.5-coder:3b qwen2.5:1.5b llama3.2))))

  ;; 2. OPENROUTER CLOUD BACKEND SETUP
  (defun san/gptel-initialize-openrouter ()
    "Configure secure OpenRouter cloud backend using local API key file."
    (let ((key-file (expand-file-name ".openrouter-key" user-emacs-directory)))
      (when (file-exists-p key-file)
        (set-file-modes key-file #o600))
      (if (file-exists-p key-file)
          (let ((token (string-trim (with-temp-buffer
                                      (insert-file-contents key-file)
                                      (buffer-string)))))
            (gptel-make-openai "OpenRouter"
              :host "openrouter.ai"
              :endpoint "/api/v1/chat/completions"
              :stream t
              :key token
              :models '(meta-llama/llama-3.3-70b-instruct
                        qwen/qwen3-coder:latest
                        perplexity/sonar-reasoning
                        deepseek/deepseek-r1
                        google/gemini-2.5-pro
                        anthropic/claude-3.5-sonnet
                        deepseek/deepseek-chat)))
        (message "Warning: OpenRouter key file missing at %s" key-file))))

  ;; 3. PROMPT DIRECTIVES SETUP
  (defun san/gptel-setup-directives ()
    "Initialize directive templates for use in gptel."
    (setq gptel-directives
          `((discourse-analyst . ,(san/read-prompt-file "academic-helper.md"
                                                        "You are an expert scholar in STS and Political Ecology..."))
            (academic-critic . "You are an elite peer-reviewer in Political Science and Development Studies...")
            (boilerplate-coder . "You are a pragmatic Python automation tool...")
            (startup-validation . "You are an EdTech startup incubator coach...")
            (emacs-architect . ,(san/read-prompt-file "emacs-architect.md"
                                                      "You are an expert Emacs Lisp developer and system architect."))
            (academic-helper . ,(san/read-prompt-file "academic-helper.md"
                                                      "You are an academic helper and critic."))
            (default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
            (programming . "You are a large language model and a careful programmer. Provide code and only code as output...")
            (writing . "You are a large language model and a writing assistant. Respond concisely.")
            (chat . "You are a large language model and a conversation partner. Respond concisely."))))

  ;; 4. INITIALIZATION
  (san/gptel-initialize-ollama)
  (san/gptel-initialize-openrouter)
  (san/gptel-setup-directives)

  ;; 5. DEFAULTS & AUTOSAVE
  (setq gptel-backend (gptel-get-backend "Ollama-Windows")
        gptel-model 'qwen2.5-coder:3b
        gptel-auto-save-delay 300)

  ;; 6. MINOR-MODE KEYBINDINGS
  (keymap-set gptel-mode-map "C-c g S" #'san/gptel-save-conversation)
  (keymap-set gptel-mode-map "C-c g n" #'san/gptel-save-named-conversation)
  (keymap-set gptel-mode-map "C-c g W" #'san/gptel-save-to-silo))

(provide 'san-llm)
;;; san-llm.el ends here

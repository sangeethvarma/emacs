;;; san-llm.el --- Local & Cloud AI (gptel) -*- lexical-binding: t -*-

;;; Commentary:
;; This module handles deferred interface pipelines linking active editor buffers to 
;; both local bare-metal Ollama instances and private, secure OpenRouter cloud endpoints.

;;; Code:

(require 'subr-x)
(require 'org)

;;; Utility: Lazy Prompt File Reader
;; ---------------------------------------------------------------------
(defun san/read-prompt-file (filename fallback-text)
  "Read and return the string contents of FILENAME from the llm-prompts directory.
If the file does not exist, return FALLBACK-TEXT to prevent backend failure."
  (let ((filepath (expand-file-name (concat "llm-prompts/" filename) user-emacs-directory)))
    (if (file-exists-p filepath)
        (with-temp-buffer
          (insert-file-contents filepath)
          (buffer-string))
      (message "Warning: LLM prompt file missing at %s" filepath)
      fallback-text)))

;;; Gptel Core Configuration
;; ---------------------------------------------------------------------
(use-package gptel
  :ensure t
  :defer t
  :bind (("C-c g g" . gptel)          ; Spawn an independent interactive chat buffer
         ("C-c g s" . gptel-send)     ; Dispatch active region selection to the backend
         ("C-c g m" . gptel-menu))    ; Launch the primary gptel option configuration interface
  :config
  ;; --- OLLAMA LOCAL BACKEND SETUP ---
  (defun san/gptel-initialize-ollama ()
    "Configure local Ollama backend with WSL host network integration."
    (let ((host-ip "127.0.0.1"))
      (when (san/wsl-p)
        (let ((route-ip (string-trim (shell-command-to-string 
                                      "ip route | grep default | awk '{print $3}'"))))
          (unless (string-empty-p route-ip)
            (setq host-ip route-ip))))
      
      (gptel-make-ollama "Ollama-Windows"
        :host (concat host-ip ":11434")
        :stream t
        :models '(qwen2.5-coder:3b qwen2.5:1.5b llama3.2))))

  ;; --- OPENROUTER CLOUD BACKEND SETUP ---
  (defun san/gptel-initialize-openrouter ()
    "Configure secure OpenRouter cloud backend with token-based authentication."
    (let ((key-file (expand-file-name ".openrouter-key" user-emacs-directory)))
      (when (file-exists-p key-file)
        (set-file-modes key-file #o600))  ; Restrict to owner read/write only
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
                        qwen/qwen3-coder
                        perplexity/sonar-reasoning
                        deepseek/deepseek-r1
                        google/gemini-2.5-pro
			'anthropic/claude-3.5-sonnet
			deepseek/deepseek-chat)))
        (message "Warning: OpenRouter key file missing at %s" key-file))))

  ;; Initialize both backends on load
  (san/gptel-initialize-ollama)
  (san/gptel-initialize-openrouter)

  ;; Set local Ollama Qwen Coder as the default global engine (Optimized for 4GB GPU)
  (setq gptel-backend (gptel-get-backend "Ollama-Windows")
        gptel-model 'qwen2.5-coder:3b)
  
  ;; ;; Set OpenRouter's Llama-3.3 as the default global engine
  ;; (setq gptel-backend (gptel-get-backend "OpenRouter")
  ;;       gptel-model 'meta-llama/llama-3.3-70b-instruct)

  ;; --- PREDEFINED PROMPT TEMPLATES ---
  ;; Role-based directive system for consistent AI behavior across contexts.
  ;; The architect persona is read dynamically from the file system.
  (setq gptel-directives
        `((discourse-analyst . "You are an expert scholar in Science and Technology Studies (STS) and Political Ecology specializing in infrastructural politics, redistributive welfarism, and Critical Discourse Analysis (CDA). Deconstruct this technical report, policy text, or interview transcript fragment. Uncover embedded developmental narratives, implicit technocratic assumptions, structural power configurations, and contested visions of progress. Provide crisp, theoretically grounded analytical notes organized by core themes.")
          (academic-critic . "You are an elite peer-reviewer in Political Science and Development Studies. Deconstruct this draft. Identify unstated systemic assumptions, analytical leaps, or deficiencies in socio-economic structural logic. Be brutally rigorous and concise.")
          (boilerplate-coder . "You are a pragmatic Python automation tool. Write clean, idiomatic Python code blocks using standard library calls wherever possible. Provide ONLY code blocks and inline comments for edge cases.")
          (startup-validation . "You are an EdTech startup incubator coach specializing in business model validation. Triage this idea. Isolate the underlying assumption, evaluate it against low-cost user validation mechanics, and declare the single most critical risk threshold. Keep it under 4 bullet points.")
          (emacs-architect . ,(san/read-prompt-file "emacs-architect.md" 
                                                    "You are an expert Emacs Lisp developer and system architect."))
          (default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
          (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note.")
          (writing . "You are a large language model and a writing assistant. Respond concisely.")
          (chat . "You are a large language model and a conversation partner. Respond concisely.")))

  ;; --- CONVERSATION PERSISTENCE INFRASTRUCTURE ---
  (setq gptel-save-directory (expand-file-name "gptel-conversations/" san-inbox-dir))
  
  (unless (file-directory-p gptel-save-directory)
    (make-directory gptel-save-directory t)
    (message "Created gptel conversation directory: %s" gptel-save-directory))
  
  (setq gptel-auto-save-delay 300)
  
  ;; --- SESSION MANAGEMENT API ---
  (defun san/gptel-save-conversation ()
    "Archive current gptel session with timestamp-based filename."
    (interactive)
    (if (eq major-mode 'gptel-mode)
        (let* ((timestamp (format-time-string "%Y-%m-%d_%H-%M-%S"))
               (filename (concat "conversation_" timestamp ".org"))
               (filepath (expand-file-name filename gptel-save-directory)))
          (gptel-save-session filepath)
          (message "Conversation saved successfully: %s" filepath))
      (user-error "Current buffer is not a gptel chat buffer")))
  
  (defun san/gptel-save-named-conversation ()
    "Archive current gptel session with user-defined semantic name."
    (interactive)
    (if (eq major-mode 'gptel-mode)
        (let* ((default-name (format-time-string "gptel_%Y-%m-%d"))
               (custom-name (read-string "Save conversation as (no extension): " default-name))
               (filename (concat custom-name ".org"))
               (filepath (expand-file-name filename gptel-save-directory)))
          (gptel-save-session filepath)
          (message "Conversation saved as: %s" filepath))
      (user-error "Current buffer is not a gptel chat buffer")))
  
  (defun san/gptel-load-conversation ()
    "Restore previously archived gptel session from file system."
    (interactive)
    (unless (file-directory-p gptel-save-directory)
      (user-error "Conversation directory does not exist: %s" gptel-save-directory))
    
    (let* ((org-files (directory-files gptel-save-directory nil "\\.org$"))
           (selected-file (completing-read "Load conversation: " org-files nil t)))
      (when selected-file
        (let ((filepath (expand-file-name selected-file gptel-save-directory)))
          (gptel-load-session filepath)
          (message "Loaded conversation: %s" selected-file)))))
  
  (defun san/gptel-save-to-silo ()
    "Archive gptel session to domain-specific PARA organizational structure."
    (interactive)
    (if (eq major-mode 'gptel-mode)
        (let* ((silo-name (completing-read "Save to silo (context area): " 
                                           (mapcar #'car san-denote-silo-alist)))
               (silo-path (cdr (assoc silo-name san-denote-silo-alist)))
               (gptel-convo-path (expand-file-name "conversations/" silo-path))
               (timestamp (format-time-string "%Y-%m-%d_%H-%M-%S"))
               (filename (concat "ai_conversation_" timestamp ".org"))
               (filepath (expand-file-name filename gptel-convo-path)))
          (unless (file-directory-p gptel-convo-path)
            (make-directory gptel-convo-path t))
          (gptel-save-session filepath)
          (message "Conversation saved to %s silo: %s" silo-name filepath))
      (user-error "Current buffer is not a gptel chat buffer")))
  
  ;; --- INTERFACE KEYBINDING CONFIGURATION ---
  (with-eval-after-load 'gptel
    (define-key gptel-mode-map (kbd "C-c g S") #'san/gptel-save-conversation)
    (define-key gptel-mode-map (kbd "C-c g n") #'san/gptel-save-named-conversation)  
    (define-key gptel-mode-map (kbd "C-c g l") #'san/gptel-load-conversation)
    (define-key gptel-mode-map (kbd "C-c g W") #'san/gptel-save-to-silo)))

(provide 'san-llm)
;;; san-llm.el ends here

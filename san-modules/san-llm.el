;;; san-llm.el --- gptel AI chat -*- lexical-binding: t -*-

;;; Commentary:
;; gptel against a local Ollama (running on the Windows host, reached
;; over WSL) and OpenRouter, with directives for each use case and
;; conversations saved into the PARA silos.

;;; Code:

(require 'subr-x)
(require 'san-notes)

(defun san/read-prompt-file (filename fallback)
  "Read a directive's prompt text from FILENAME, or return FALLBACK.
Checks Sandbox/llm-prompts/ under the vault first, so prompts can be
edited without touching the git-tracked config, then falls back to
this config's own llm-prompts/."
  (let ((path (or (let ((p (expand-file-name (concat "Sandbox/llm-prompts/" filename) san-vault-root)))
                    (and (file-exists-p p) p))
                  (let ((p (expand-file-name (concat "llm-prompts/" filename) user-emacs-directory)))
                    (and (file-exists-p p) p)))))
    (if path
        (with-temp-buffer
          (insert-file-contents path)
          (buffer-string))
      (message "LLM prompt file missing: %s" filename)
      fallback)))

(defun san/gptel-save-conversation ()
  "Save the current gptel conversation into a PARA silo's conversations/."
  (interactive)
  (unless gptel-mode
    (user-error "Not a gptel conversation buffer"))
  (let* ((silo-name (completing-read "Save to silo: " (mapcar #'car san-denote-silo-alist) nil t))
         (silo-dir (expand-file-name "conversations/" (cdr (assoc silo-name san-denote-silo-alist))))
         (name (read-string "Name: " (format-time-string "gptel_%Y-%m-%d")))
         (path (expand-file-name (concat name ".md") silo-dir)))
    (make-directory silo-dir t)
    (write-file path)
    (message "Saved to %s: %s" silo-name path)))

(defun san/gptel-load-conversation ()
  "Reopen a previously saved conversation from a PARA silo."
  (interactive)
  (let* ((silo-name (completing-read "Load from silo: " (mapcar #'car san-denote-silo-alist) nil t))
         (silo-dir (expand-file-name "conversations/" (cdr (assoc silo-name san-denote-silo-alist))))
         (files (and (file-directory-p silo-dir) (directory-files silo-dir nil "\\.md\\'"))))
    (unless files
      (user-error "No saved conversations in %s" silo-name))
    (find-file (expand-file-name (completing-read "Load: " files nil t) silo-dir))))

;; gptel-mode already persists backend/model/system-prompt as file-local
;; variables on save and restores them when re-enabled -- it just doesn't
;; turn itself back on automatically when you reopen the file.
(defun san/gptel-auto-enable ()
  "Turn `gptel-mode' back on when reopening a file with saved gptel state."
  (when (local-variable-p 'gptel--backend-name)
    (gptel-mode 1)))

(add-hook 'find-file-hook #'san/gptel-auto-enable)

(use-package gptel
  :ensure t
  :defer t
  :bind (("C-c g g" . gptel)
         ("C-c g s" . gptel-send)
         ("C-c g m" . gptel-menu)
         ("C-c g l" . san/gptel-load-conversation))
  :config
  ;; Ollama runs on the Windows host, not localhost, when Emacs is
  ;; inside WSL -- resolve the actual host IP via the default route.
  (gptel-make-ollama "Ollama-Windows"
    :host (concat (if (san/wsl-p)
                       (string-trim (shell-command-to-string "ip route | awk '/default/ {print $3}'"))
                     "127.0.0.1")
                   ":11434")
    :stream t
    :models '(qwen2.5-coder:3b qwen2.5:1.5b llama3.2))

  (let ((key-file (expand-file-name ".openrouter-key" user-emacs-directory)))
    (if (file-exists-p key-file)
        (gptel-make-openai "OpenRouter"
          :host "openrouter.ai"
          :endpoint "/api/v1/chat/completions"
          :stream t
          :key (string-trim (with-temp-buffer
                               (insert-file-contents key-file)
                               (buffer-string)))
          :models '(meta-llama/llama-3.3-70b-instruct
                    qwen/qwen3-coder:latest
                    perplexity/sonar-reasoning
                    deepseek/deepseek-r1
                    google/gemini-2.5-pro
                    anthropic/claude-3.5-sonnet
                    deepseek/deepseek-chat))
      (message "OpenRouter key missing at %s" key-file)))

  (setq gptel-directives
        `((rewrite . gptel--rewrite-directive-default)
          (default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
          (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note.")
          (writing . "You are a large language model and a writing assistant. Respond concisely.")
          (chat . "You are a large language model and a conversation partner. Respond concisely.")
          (boilerplate-coder . "You are a pragmatic Python automation tool...")
          (startup-validation . "You are an EdTech startup incubator coach...")
          (academic-helper . ,(san/read-prompt-file "academic-helper.md" "You are an academic research assistant."))
          (academic-critic . ,(san/read-prompt-file "academic-critic.md" "You are an academic peer reviewer."))
          (adhd-copilot . ,(san/read-prompt-file "adhd-copilot.md" "You are an ADHD executive-function copilot."))
          (emacs-architect . ,(san/read-prompt-file "emacs-architect.md" "You are an Emacs Lisp expert."))))

  (setq gptel-backend (gptel-get-backend "Ollama-Windows")
        gptel-model 'qwen2.5-coder:3b)

  (keymap-set gptel-mode-map "C-c g w" #'san/gptel-save-conversation)
  (keymap-set gptel-mode-map "C-<return>" #'gptel-send))

(provide 'san-llm)
;;; san-llm.el ends here

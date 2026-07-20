;;; san-llm.el --- Local & Cloud AI Engineering Buffer Context (gptel) -*- lexical-binding: t -*-

;;; Commentary:
;; This module handles deferred interface pipelines linking active editor buffers to 
;; both local bare-metal Ollama instances and private, secure OpenRouter cloud endpoints.

;;; Code:

(require 'subr-x)

;;; Gptel Core Configuration
;; ---------------------------------------------------------------------
(use-package gptel
  :ensure t
  :defer t
  :bind (("C-c g g" . gptel)              ; Spawn an independent interactive chat buffer
         ("C-c g s" . gptel-send)         ; Dispatch active region selection to the backend
         ("C-c g m" . gptel-menu))        ; Launch the primary gptel option configuration interface
  :config
  ;; --- 1. LOCAL OLLAMA BACKEND CONFIGURATION ---
  (defun san/gptel-initialize-ollama ()
    "Extract host network routing pathways lazily inside WSL environments.
Calculates the host-side virtual gateway ip route address on demand, bridging 
guest buffers to the native, bare-metal GPU Ollama instance running on the host."
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

  ;; --- 2. OPENROUTER CLOUD BACKEND CONFIGURATION ---
(defun san/gptel-initialize-openrouter ()
  "Initialize OpenRouter safely by reading the hidden token file."
  (let ((key-file (expand-file-name ".openrouter-key" user-emacs-directory)))
    (when (file-exists-p key-file)
      (set-file-modes key-file #o600))  ; Read/write for owner only
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
                      google/gemini-2.5-pro)))
      (message "Warning: OpenRouter key file missing at %s" key-file))))

  ;; Initialize both backends on load
  (san/gptel-initialize-ollama)
  (san/gptel-initialize-openrouter)

  ;; Set OpenRouter's Llama-3.3 as the default global engine
  (setq gptel-backend (gptel-get-backend "OpenRouter")
        gptel-model 'meta-llama/llama-3.3-70b-instruct)

  ;; --- 3. DOMAIN-ISOLATED PERSONA DIRECTIVES MATRIX ---
  (setq gptel-directives
        '((discourse-analyst . "You are an expert scholar in Science and Technology Studies (STS) and Political Ecology specializing in infrastructural politics, redistributive welfarism, and Critical Discourse Analysis (CDA). Deconstruct this technical report, policy text, or interview transcript fragment. Uncover embedded developmental narratives, implicit technocratic assumptions, structural power configurations, and contested visions of progress. Provide crisp, theoretically grounded analytical notes organized by core themes.")
          (academic-critic . "You are an elite peer-reviewer in Political Science and Development Studies. Deconstruct this draft. Identify unstated systemic assumptions, analytical leaps, or deficiencies in socio-economic structural logic. Be brutally rigorous and concise.")
          (boilerplate-coder . "You are a pragmatic Python automation tool. Write clean, idiomatic Python code blocks using standard library calls wherever possible. Provide ONLY code blocks and inline comments for edge cases.")
          (startup-validation . "You are an EdTech startup incubator coach specializing in business model validation. Triage this idea. Isolate the underlying assumption, evaluate it against low-cost user validation mechanics, and declare the single most critical risk threshold. Keep it under 4 bullet points.")
          (emacs-architect . "You are an expert Emacs Lisp developer and system architect. Help me clean, modularize, and optimize my Emacs configuration files. Write clean, modern elisp, maximize lazy loading hooks, use clean use-package semantics, and explain optimization gains explicitly.")
          (default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
          (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note.")
          (writing . "You are a large language model and a writing assistant. Respond concisely.")
          (chat . "You are a large language model and a conversation partner. Respond concisely."))))

(provide 'san-llm)
;;; san-llm.el ends here

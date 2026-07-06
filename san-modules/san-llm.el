;;; san-llm.el --- Local AI Engineering Buffer Context (gptel) -*- lexical-binding: t -*-

;;; Commentary:
;; This module handles deferred interface pipelines linking active editor buffers to 
;; a local, bare-metal Ollama AI server. It isolates system persona definitions 
;; and optimizes network route evaluations to maintain cross-platform performance.

;;; Code:

(require 'subr-x)

;;; Gptel & Local Ollama Infrastructure Configuration
;; ---------------------------------------------------------------------
;; Provisions asynchronous local LLM interaction. Encapsulates host gateway path routing 
;; calculations inside a lazy evaluation wrapper to prevent blocking early startup cycles.

(use-package gptel
  :ensure t
  :defer t
  :bind (("C-c g g" . gptel)              ; Spawn an independent interactive chat buffer
         ("C-c g s" . gptel-send)         ; Dispatch active region selection to the backend
         ("C-c g m" . gptel-menu))        ; Launch the primary gptel option configuration interface
  :config
  (defun san/gptel-initialize-backend ()
    "Extract host network routing pathways lazily inside WSL environments.
Calculates the host-side virtual gateway ip route address on demand, bridging 
guest buffers to the native, bare-metal GPU Ollama instance running on the host."
    (let ((host-ip "127.0.0.1"))
      (when (and (eq system-type 'gnu/linux) (getenv "WSLENV"))
        (let ((route-ip (string-trim (shell-command-to-string 
                                      "ip route | grep default | awk '{print $3}'"))))
          (unless (string-empty-p route-ip)
            (setq host-ip route-ip))))
      
      (setq-default gptel-backend
                    (gptel-make-ollama "Ollama-Windows"
                      :host (concat host-ip ":11434")
                      :stream t
                      :models '(qwen2.5:1.5b llama3.2)))))

  ;; Evaluate host connections lazily on initial configuration setup block execution
  (san/gptel-initialize-backend)
  (setq-default gptel-model 'qwen2.5:1.5b)

  ;;; Domain-Isolated Persona Directives Matrix
  ;; ---------------------------------------------------------------------
  ;; Configures contextual engineering behaviors. Emojis are purposefully utilized 
  ;; inside macro definitions to act as reliable visual layout keys.
  
  (setq gptel-directives
        '((discourse-analyst . "You are an expert scholar in Science and Technology Studies (STS) and Political Ecology specializing in infrastructural politics, redistributive welfarism, and Critical Discourse Analysis (CDA). Deconstruct this technical report, policy text, or interview transcript fragment. Uncover embedded developmental narratives, implicit technocratic assumptions, structural power configurations, and contested visions of progress. Provide crisp, theoretically grounded analytical notes organized by core themes.")
          (academic-critic . "You are an elite peer-reviewer in Political Science and Development Studies. Deconstruct this draft. Identify unstated systemic assumptions, analytical leaps, or deficiencies in socio-economic structural logic. Be brutally rigorous and concise.")
          (boilerplate-coder . "You are a pragmatic Python automation tool. Write clean, idiomatic Python code blocks using standard library calls wherever possible. Provide ONLY code blocks and inline comments for edge cases.")
          (startup-validation . "You are an EdTech startup incubator coach specializing in business model validation. Triage this idea. Isolate the underlying assumption, evaluate it against low-cost user validation mechanics, and declare the single most critical risk threshold. Keep it under 4 bullet points.")
          (default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
          (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note.")
          (writing . "You are a large language model and a writing assistant. Respond concisely.")
          (chat . "You are a large language model and a conversation partner. Respond concisely."))))

(provide 'san-llm)
;;; san-llm.el ends here

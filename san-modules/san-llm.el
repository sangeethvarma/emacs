;;; san-llm.el --- Local AI Engineering Buffer Context (gptel) -*- lexical-binding: t -*-

;;; Commentary:
;; This module interfaces your Emacs editing framework with your local bare-metal
;; Ollama AI server running on the Windows host (utilizing the native GPU).
;;
;; PERFORMANCE ARCHITECTURE:
;; This package is completely deferred. Network routing calculations for WSL2-to-Host
;; gateways are executed lazily upon initial invocation, protecting startup speed.
;;
;; Keybindings:
;; M-x gptel          -> Open a dedicated interactive AI chat session.
;; M-x gptel-send     -> Send active region or paragraph context to the local model.

;;; Code:

(require 'subr-x)

;; =============================================================================
;; 1. Gptel & Local Ollama Infrastructure Configuration
;; =============================================================================

(use-package gptel
  :ensure t
  :defer t  ; PERFORMANCE: Defer loading completely until an AI command is executed
  :bind (("C-c g g" . gptel)
         ("C-c g s" . gptel-send)
         ("C-c g m" . gptel-menu))
  :config
  ;; Define a lazy backend initializer to resolve the cross-virtualization IP address
  (defun san/gptel-initialize-backend ()
    "Extract host network routing pathways lazily inside WSL environments.
Prevents blocking synchronous shell calls from pausing the main Emacs startup thread."
    (let ((host-ip "127.0.0.1")) ; Default fallback loopback matrix
      
      ;; If running inside WSL, query the Linux kernel network routing table for the Windows gateway
      (when (and (eq system-type 'gnu/linux) (getenv "WSLENV"))
        (let ((route-ip (string-trim (shell-command-to-string 
                                      "ip route | grep default | awk '{print $3}'"))))
          (unless (string-empty-p route-ip)
            (setq host-ip route-ip))))
      
      ;; Provision the official local backend framework instance
      (setq-default gptel-backend
                    (gptel-make-ollama "Ollama-Windows"
                      :host (concat host-ip ":11434")
                      :stream t
                      :models '(qwen2.5:1.5b llama3.2)))))

  ;; Initialize the network endpoint routing map cleanly inside the configuration thread
  (san/gptel-initialize-backend)

  ;; Configure your default high-speed syntax parsing model
  (setq-default gptel-model 'qwen2.5:1.5b)

  ;; =============================================================================
  ;; 2. Domain-Isolated Persona Directives Matrix
  ;; =============================================================================
  ;; Custom system prompts mapped explicitly to your PARA operational domains.

  (setq gptel-directives
        '((academic-critic . "You are an elite peer-reviewer in Political Science and Development Studies. Deconstruct this draft. Identify unstated systemic assumptions, analytical leaps, or deficiencies in socio-economic structural logic. Be brutally rigorous and concise.")
          (boilerplate-coder . "You are a pragmatic Python automation tool. Write clean, idiomatic Python code blocks using standard library calls wherever possible. Do not write conversational prose, introductions, or conceptual explanations. Provide ONLY code blocks and inline comments for edge cases.")
          (startup-validation . "You are an EdTech startup incubator coach specializing in business model validation. Triage this idea. Isolate the underlying assumption, evaluate it against low-cost user validation mechanics, and declare the single most critical risk threshold. Keep it under 4 bullet points.")
          (default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
          (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note.")
          (writing . "You are a large language model and a writing assistant. Respond concisely.")
          (chat . "You are a large language model and a conversation partner. Respond concisely."))))

(provide 'san-llm)
;;; san-llm.el ends here

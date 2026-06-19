(use-package gptel
  :ensure t
  :config
  (let ((windows-host-ip (shell-command-to-string 
                          "ip route | grep default | awk '{print $3}' | tr -d '\\n'")))
    
    ;; If the dynamic command pulls blank, default cleanly back to explicit loopback
    (when (string-empty-p windows-host-ip)
      (setq windows-host-ip "127.0.0.1"))

    (setq-default gptel-backend
                  (gptel-make-ollama "Ollama-Windows"
                    :host (concat windows-host-ip ":11434")
                    :stream t
                    :models '(qwen2.5:1.5b llama3.2))))
  (setq-default gptel-model 'qwen2.5:1.5b))

  (with-eval-after-load 'gptel
    (setq gptel-directives
          '((academic-critic . "You are an elite peer-reviewer in Political Science and Development Studies. Deconstruct this draft. Identify unstated systemic assumptions, analytical leaps, or deficiencies in socio-economic structural logic. Be brutally rigorous and concise.")
            (boilerplate-coder . "You are a pragmatic Python automation tool. Write clean, idiomatic Python code blocks using standard library calls wherever possible. Do not write conversational prose, introductions, or conceptual explanations. Provide ONLY code blocks and inline comments for edge cases.")
            (startup-validation . "You are an EdTech startup incubator coach specializing in business model validation. Triage this idea. Isolate the underlying assumption, evaluate it against low-cost user validation mechanics, and declare the single most critical risk threshold. Keep it under 4 bullet points.")
	    (default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
	    (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note.")
	    (writing . "You are a large language model and a writing assistant. Respond concisely.")
	    (chat . "You are a large language model and a conversation partner. Respond concisely."))))
 
(provide 'san-llm)

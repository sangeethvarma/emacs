;;; san-editing.el --- Text Manipulation & High-Speed Editing Utilities -*- lexical-binding: t -*-

;;; Commentary:
;; This module configures global text manipulation utilities and core typing mechanics.
;; It sets up:
;; - Context-aware line navigation overrides (Smart Home key behaviors).
;; - High-performance, JIT byte-compiled contextual spell checking via Jinx.

;;; Code:

;;; Context-Aware Line Navigation (Smart Home Key)
;; ---------------------------------------------------------------------
;; Overrides the default structural behavior of standard 'C-a' execution. 
;; Toggles point position between the true hard line margin and the first non-whitespace 
;; character indentation block on consecutive hits.

(defun san/beginning-of-line-or-indentation ()
  "Intelligently toggle point between indentation text starts and true hard line margins."
  (interactive)
  (if (bolp)
      (back-to-indentation)
    (beginning-of-line)))

(keymap-global-set "C-a" #'san/beginning-of-line-or-indentation)

;;; Jinx High-Performance Spell Checker
;; ---------------------------------------------------------------------
;; Deploys the modern Jinx compiler-driven spelling overlay system. 
;; It checks words on-the-fly purely within visible viewport boundaries to prevent background 
;; I/O processing blocks over massive data logs or academic texts.
(use-package jinx
  :ensure t
  :hook ((text-mode . jinx-mode)
         (prog-mode . jinx-mode))           ; Also enable in programming modes for comments
  :commands (jinx-mode jinx-correct jinx-languages)
  :bind (("M-$" . jinx-correct)             ; Prompt minibuffer dropdown for word corrections at point
         ("C-M-$" . jinx-languages))        ; Dynamically switch or overlay multi-lingual dictionaries
  :custom
  (jinx-delay 0.5)                         ; Delay before starting spell check
  (jinx-idle-delay 1.0)                    ; Idle delay for automatic checking
  :config
  ;; Ensure jinx is properly initialized
  (defun san/setup-jinx-defaults ()
    "Setup default jinx configuration."
    (setq jinx--dict-cache nil)  ; Clear cache to force reinitialization
    (when (bound-and-true-p jinx-mode)
      (jinx-mode -1)
      (jinx-mode 1)))
  
  ;; Initialize jinx when Emacs is idle
  (add-hook 'emacs-startup-hook 
            (lambda () 
              (run-with-idle-timer 2 nil #'san/setup-jinx-defaults))))

(provide 'san-editing)
;;; san-editing.el ends here

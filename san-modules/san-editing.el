;;; san-editing.el --- Text Manipulation & High-Speed Editing Utilities -*- lexical-binding: t -*-

;;; Commentary:
;; This module configures global text manipulation utilities and core typing mechanics.
;; It sets up:
;; - Context-aware line navigation overrides (Smart Home key behaviors).
;; - High-performance, JIT byte-compiled contextual spell checking via Jinx.

;;; Code:

;;; Context-Aware Line Navigation (Smart Home Key)
(defun san/beginning-of-line-or-indentation ()
  "Intelligently toggle point between indentation text starts and true hard line margins."
  (interactive)
  (if (bolp)
      (back-to-indentation)
    (beginning-of-line)))

(keymap-global-set "C-a" #'san/beginning-of-line-or-indentation)

;;; Jinx High-Performance Spell Checker
(use-package jinx
  :ensure t
  :hook ((text-mode . jinx-mode)
         (prog-mode . jinx-mode)
	 (org-mode . jinx-mode)
	 (markdown-mode . jinx-mode))
  :commands (jinx-mode jinx-correct jinx-languages)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages))
  :custom
  (jinx-delay 0.7)
  (jinx-idle-delay 1.2))

(provide 'san-editing)
;;; san-editing.el ends here

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
  :hook (text-mode . jinx-mode)           ; Auto-activate spell checking inside all prose documents
  :bind (("M-$" . jinx-correct)           ; Prompt minibuffer dropdown for word corrections at point
         ("C-M-$" . jinx-languages)))     ; Dynamically switch or overlay multi-lingual dictionaries

(provide 'san-editing)
;;; san-editing.el ends here

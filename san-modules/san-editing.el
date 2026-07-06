;;; san-editing.el --- Text Manipulation & High-Speed Editing Utilities -*- lexical-binding: t -*-

;;; Commentary:
;; This module centralizes core editing and text-manipulation utilities.
;; It configures:
;; 1. A context-aware "Smart Home" key utility (remapping C-a).
;; 2. Jinx: A high-performance, just-in-time spell checker powered by native libenchant.

;;; Code:

;; =============================================================================
;; 1. Context-Aware Line Navigation (Smart Home Key)
;; =============================================================================

(defun san/beginning-of-line-or-indentation ()
  "Intelligently move the cursor within the current line bounds.
If the point is situated in the middle of a line, moves back to the true hard 
beginning of the string block (bolp). If pressed consecutively while already 
at the absolute line start, shifts point cleanly to the first non-whitespace 
indentation character."
  (interactive)
  (if (bolp)
      (back-to-indentation)
    (beginning-of-line)))

;; Remap the core Emacs navigation hook to utilize our smart-line utility
(keymap-global-set "C-a" #'san/beginning-of-line-or-indentation)

;; =============================================================================
;; 2. Jinx High-Performance Spell Checker Configuration
;; =============================================================================
;; Jinx utilizes native code compilation loops to check text blocks seamlessly 
;; without introducing UI input lags or halting mini-buffer updates.

(use-package jinx
  :ensure t
  :hook (text-mode . jinx-mode)         ; Enable spellcheck automatically across prose/org modes
  :bind (("M-$" . jinx-correct)         ; Target correction menu popup over word at point
         ("C-M-$" . jinx-languages)))   ; Dynamic vocabulary switching matrix

(provide 'san-editing)
;;; san-editing.el ends here

;;; san-keybindings.el --- Modal Editing Engine & Global Keymaps -*- lexical-binding: t -*-

;;; Commentary:
;; This module establishes the structural command matrix for the entire environment.
;; 1. Leverages built-in native Emacs DWIM (Do What I Mean) text engines.
;; 2. Implements a custom text case-inversion utility for regions.
;; 3. Sets up Meow modal editing explicitly customized for the Dvorak layout.
;; 4. Builds a smart-switching frame/window navigator combining other-window and ace-window.

;;; Code:

;; =============================================================================
;; 1. Native DWIM Text Transformations & Region Case Inversion
;; =============================================================================

;; Remap standard upper/lower transformations to use native built-in DWIM engines.
;; These intelligently target either the active region, the word at point, or subwords.
(keymap-global-set "M-u" #'upcase-dwim)
(keymap-global-set "M-l" #'downcase-dwim)

(defun san/toggle-case ()
  "Invert the casing of all characters within the currently active region.
If no region is active, raises a clean user-error without affecting text state."
  (interactive)
  (if (not (use-region-p))
      (user-error "No active region detected to toggle case")
    (let* ((beg (region-beginning))
           (end (region-end))
           (input (buffer-substring-no-properties beg end))
           (len (length input))
           (output (make-string len 0)))
      (dotimes (i len)
        (let ((char (aref input i)))
          (aset output i (if (eq char (downcase char)) 
                             (upcase char) 
                           (downcase char)))))
      (delete-region beg end)
      (insert output))))

;; =============================================================================
;; 2. Meow Modal Editing Engine (Dvorak Optimization Layout)
;; =============================================================================

(defun meow-setup-dvorak ()
  "Define navigation, selection, and structural execution layers for Dvorak layout."
  (meow-leader-define-key
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("-" . negative-argument)
   '("<SPC>" . just-one-space))
  
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("'" . meow-beginning-of-thing)
   '("," . meow-inner-of-thing)
   '("." . meow-end-of-thing)
   '("<" . meow-bounds-of-thing)
   '(">" . meow-bounds-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("C" . san/toggle-case) ; Structural map to custom inversion engine
   '("d" . delete-char)
   '("e" . meow-line)
   '("f" . meow-find)
   '("F" . meow-find-expand)
   '("g" . meow-keyboard-quit)
   '("G" . meow-goto-line)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-join)
   '("J" . delete-indentation)
   '("k" . meow-kill)
   '("l" . meow-till)
   '("L" . meow-till-expand)
   '("m" . meow-mark-word)
   '("M" . meow-mark-symbol)
   '("n" . meow-next)
   '("N" . meow-next-expand)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-prev)
   '("P" . meow-prev-expand)
   '("q" . meow-quit)
   '("r" . meow-replace)
   '("R" . meow-replace-save)
   '("/" . meow-search)
   '("s" . meow-right)
   '("S" . meow-right-expand)
   '("t" . meow-right)
   '("T" . meow-right-expand)
   '("u" . undo)
   '("v" . meow-visit)
   '("w" . meow-next-word)
   '("W" . meow-next-symbol)
   '("x" . meow-save)
   '("y" . meow-yank)
   '("z" . meow-pop-selection)
   '("Z" . meow-pop-all-selection)
   '("&" . meow-query-replace)
   '("%" . meow-query-replace-regexp)
   '("<escape>" . meow-last-buffer)))

(use-package meow
  :ensure t
  :config
  (meow-setup-dvorak)
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-dvorak)
  (meow-global-mode 1))

;; =============================================================================
;; 3. Spatial Window Switching Layer (Ace-Window Routing)
;; =============================================================================

(use-package ace-window
  :ensure t
  :config
  ;; Define tactile, high-comfort home row selection targeting keys on Dvorak
  (setq aw-keys '(?h ?u ?a ?s ?e ?t ?o ?n))
  
  (defun san/other-window ()
    "Intelligent context window switcher.
A single invocation smoothly shifts point to the immediate next adjacent window pane.
Executing the shortcut consecutively (double-tapping) upgrades focus mechanisms 
instantly to trigger spatial overlays across all active visual grid windows."
    (interactive)
    (if (eq last-command #'san/other-window) 
        (ace-window 1) 
      (other-window 1)))
  
  ;; Bind the smart navigation hook globally to Alt-o
  (keymap-global-set "M-o" #'san/other-window))

(provide 'san-keybindings)
;;; san-keybindings.el ends here

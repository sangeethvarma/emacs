;;; san-keybindings.el --- Modal Editing Engine & Global Keymaps -*- lexical-binding: t -*-

;;; Commentary:
;; This module establishes the core input mechanics and modal workspace layout.

;;; Code:

;;; Native Case Transformations & String Inversion
(keymap-global-set "M-u" #'upcase-dwim)
(keymap-global-set "M-l" #'downcase-dwim)

(defun san/toggle-case ()
  "Invert the casing of all characters within the currently active region."
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

;;; Meow Modal Editing Engine (Dvorak Layout Profile)
(defun meow-setup-dvorak ()
  "Define positional navigation, expansion bounds, and text manipulation keys for Dvorak."
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
   '(", " . meow-inner-of-thing)
   '("." . meow-end-of-thing)
   '("<" . meow-bounds-of-thing)
   '(">" . meow-bounds-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("C" . san/toggle-case)
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
   '("t" . meow-search-expand)
   '("T" . meow-search-expand)
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
  (when (boundp 'meow-cheatsheet-layout-dvorak)
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-dvorak))
  (meow-global-mode 1))

;;; Spatial Window Switching Layer (Ace-Window Routing)
(use-package ace-window
  :ensure t
  :config
  ;; Target specific accessible key parameters matching home-row focus points
  (setq aw-keys '(?h ?u ?a ?s ?e ?t ?o ?n))
  
  (defun san/other-window ()
    "Intelligent context window switcher."
    (interactive)
    (if (eq last-command #'san/other-window) 
        (ace-window 1) 
      (other-window 1)))
  
  :bind (("M-o" . san/other-window)))

(provide 'san-keybindings)
;;; san-keybindings.el ends here

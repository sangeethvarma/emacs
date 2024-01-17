;;; package
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(use-package no-littering
:ensure t
:config
(no-littering-theme-backups)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory)))


;; appearance : toolbars
;; (tool-bar-mode -1)
;; (scroll-bar-mode -1)
;; (menu-bar-mode -1)

(toggle-frame-fullscreen)

;; appearance : theme
(load-theme 'modus-vivendi t)

;; appearance : fonts
(set-face-attribute 'default nil :font "Consolas-13")
(set-fontset-font t 'malayalam "Chilanka")


;; initial loading
;; (setq inhibit-splash-screen t)
;; (setq visible-bell t
;;       ring-bell-function 'ignore)

(delete-selection-mode t)

(prefer-coding-system 'utf-8)

(global-set-key (kbd "M-o") 'other-window)

(global-unset-key (kbd "C-h h"))

(defalias 'yes-or-no-p 'y-or-n-p)

(global-set-key (kbd "<right-fringe> <mouse-1>") 'suspend-frame)

(defun san/upcase-dwim (arg)
  "Upcase words in the region, if active; if not, upcase character at point.
  If the region is active, this function calls `upcase-region'.
  Otherwise, it calls `upcase-char', with prefix argument passed to it
  to upcase ARG words."
  (interactive "*p")
  (if (use-region-p)
      (upcase-region (region-beginning) (region-end) (region-noncontiguous-p))
    (upcase-char arg)))


(defun meow-setup-dvorak ()
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
   '("'" . meow-beginning-of-thing)
   '("\"" . meow-end-of-thing)
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
   '("<" . meow-inner-of-thing)
   '(">" . meow-bounds-of-thing)
   '("'" . meow-beginning-of-thing)
   '("'" . meow-inner-of-thing)
   '("." . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("C" . san/upcase-dwim)
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
   '("O" . meow-block-expand)
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


(use-package vertico
  :ensure t
  :config
  (vertico-mode))

;; (use-package which-key
;;   :ensure t)

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))


(put 'dired-find-alternate-file 'disabled nil)

(setq shell-file-name "C:/Users/sangeeth/scoop/shims/pwsh.exe")

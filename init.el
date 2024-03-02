;;; package
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq use-package-always-ensure t)

(use-package no-littering
:config
(no-littering-theme-backups)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory)))


;; appearance : toolbars ;; handled in early-init now
;; (tool-bar-mode -1)
;; (scroll-bar-mode -1)
;; (menu-bar-mode -1)

;; appearance : theme
(load-theme 'modus-vivendi t)

;; appearance : fonts
(set-face-attribute 'default nil :font "Consolas-13")
(set-face-attribute 'default nil :font "FantasqueSansM Nerd Font-16")
(set-fontset-font t 'malayalam "Chilanka")
(set-fontset-font t 'symbol "Segoe UI Emoji")


(global-visual-line-mode)
;; initial loading ;; also handled in early-init
;; (setq inhibit-splash-screen t)
;; (setq visible-bell t
;;       ring-bell-function 'ignore)

(delete-selection-mode t)

(prefer-coding-system 'utf-8)

(global-set-key (kbd "M-o") 'other-window)

(global-unset-key (kbd "C-h h"))

(defalias 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-emacs 'yes-or-no-p)

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
   '("," . meow-inner-of-thing)
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
  :config
  (meow-setup-dvorak)
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-dvorak)
  (meow-global-mode 1))

(recentf-mode 1)
(savehist-mode 1)

(use-package vertico
  :config
  (setq vertico-cycle t)
  (setq vertico-resize nil)
  (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :config
  (marginalia-mode 1))

(use-package consult
  :bind (;; A recursive grep
         ("M-s M-g" . consult-ripgrep)
         ;; Search for files names recursively
         ("M-s M-f" . consult-find)
         ;; Search through the outline (headings) of the file
         ("M-s M-o" . consult-outline)
         ;; Search the current buffer
         ("M-s M-l" . consult-line)
         ;; Switch to another buffer, or bookmarked file, or recently
         ;; opened file.
         ("M-s M-b" . consult-buffer)))

(use-package embark
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

(use-package embark-consult)

(use-package wgrep
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

(use-package which-key
  :config
  (which-key-mode))

(put 'dired-find-alternate-file 'disabled nil)

(setq shell-file-name "C:/Users/sangeeth/scoop/shims/pwsh.exe")

(use-package denote
  :config
  (setq denote-directory "c:/Users/sangeeth/OneDrive/notes/"))

(use-package doom-modeline
  :config
  (doom-modeline-mode))

(setq org-cite-global-bibliography '("c:/Users/sangeeth/OneDrive/my_library_biblatex.bib"))

(use-package ace-window
  :config
  (global-set-key (kbd "M-o") 'ace-window)
  (setq aw-keys '(?h ?u ?a ?s ?e ?t ?o ?n)))
		     
(use-package persistent-scratch
  :config
  (persistent-scratch-setup-default)
  (persistent-scratch-mode))


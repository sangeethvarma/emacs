;;; -*- lexical-binding: t -*-

(use-package vertico
  :config
  (setq vertico-cycle t)
  (setq vertico-resize t)
  (vertico-mode 1)
  :custom
  (vertico-sort-function 'vertico-sort-history-alpha))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-quit-no-match t)
  :init
  (global-corfu-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :custom
  (marginalia-align 'center)
  :config
  (marginalia-mode))

(use-package consult
  :bind (;; A recursive grep
         ("M-s M-g" . consult-ripgrep)
         ;; Search for files names recursively
         ("M-s M-f" . consult-find)
         ;; Search through the outline (headings) of the file
         ("M-s M-o" . consult-outline)
         ;; Search the current buffer
         ("M-s M-l" . consult-line)
         ;; Switch to another buffer, or bookmarked file, or recently opened file.
         ("M-s M-b" . consult-buffer)
	 ("C-x M-b" . consult-buffer)))

(use-package embark
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

(use-package embark-consult)

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(provide 'san-completions)


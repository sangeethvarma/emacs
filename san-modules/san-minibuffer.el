;;; -*- lexical-binding: t -*-

(use-package recentf
  :custom
  (recentf-max-saved-items 100)
  :bind
  (("C-c f r" . recentf-open)
   ("C-c r f" . recentf))
  :config
  (recentf-mode 1))

(use-package savehist
  :config
  (savehist-mode 1))

(provide 'san-minibuffer)


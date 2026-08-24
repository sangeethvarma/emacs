;;; san-appearance.el --- Visual interface -*- lexical-binding: t -*-

;;; Commentary:
;; Frame geometry, theme, modeline, and line display.

;;; Code:

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(name . "Emacs"))

(blink-cursor-mode 0)
(global-visual-line-mode 1)

(use-package ef-themes
  :ensure t
  :config
  (load-theme 'ef-bio t))

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-icon-backend 'nerd-icons)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-max-buffer-length 30))

(setq display-time-format "%H:%M %b %d"
      display-time-default-load-average nil)

(display-time-mode 1)
(display-battery-mode 1)
(column-number-mode 1)

(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

(use-package spacious-padding
  :ensure t
  :init
  (spacious-padding-mode 1))

(setq-default line-spacing 3)

(provide 'san-appearance)
;;; san-appearance.el ends here

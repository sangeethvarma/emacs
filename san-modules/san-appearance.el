;;; san-appearance.el --- Visual Interface & UI Frame Configuration -*- lexical-binding: t -*-

;;; Commentary:
;; This module standardizes the user interface presentation settings of the editor canvas.

;;; Code:

;;; Graphical Frame Geometry
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(name . "Emacs"))

(blink-cursor-mode 0)
(global-visual-line-mode 1)

;;; Color Theme Ecosystem
(use-package ef-themes
  :ensure t
  :config
  (load-theme 'ef-bio t))

;;; Visual Cursor Beacon
;; Highlights cursor position when scrolling or switching windows
(use-package beacon
  :ensure t
  :defer t
  :init
  (beacon-mode 1)
  :config
  (setq beacon-color "#56A5A8"
        beacon-blink-when-focused t
        beacon-blink-delay 0.1
        beacon-blink-duration 0.3))

;;; Status Modeline & Time Telemetry
(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-icon-backend 'nerd-icons
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-file-name-style 'truncate-with-project
        doom-modeline-max-buffer-length 30))

(setq display-time-format "%H:%M %b %d"
      display-time-default-load-average nil)

(display-time-mode 1)
(display-battery-mode 1)
(column-number-mode 1)

;;; Line Layout Structure & Relative Margins
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

(use-package spacious-padding
  :ensure t
  :defer t
  :init
  (spacious-padding-mode 1))

(setq-default line-spacing 3)

(provide 'san-appearance)
;;; san-appearance.el ends here

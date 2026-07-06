;;; san-appearance.el --- Visual Interface & UI Frame Configuration -*- lexical-binding: t -*-

;;; Commentary:
;; This module standardizes the user interface presentation settings of the editor canvas.
;; It handles global frame geometries, active graphical theme spaces, modeline telemetry,
;; and customized relative margins and line spacings optimized for high scannability.

;;; Code:

;;; Graphical Frame Geometry
;; ---------------------------------------------------------------------
;; Forces newly generated windows to utilize structural maximized canvas spaces by default
;; and overrides default text navigation patterns.

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(name . "Emacs"))

(blink-cursor-mode 0)                    ; Neutralize distracting cursor blinking loops
(global-visual-line-mode 1)              ; Wrap lines softly at window edges without breaking words

;;; Color Theme Ecosystem
;; ---------------------------------------------------------------------
;; Deploys the accessible, highly scannable Ef-Themes collection, initializing the 
;; contrast-balanced bio variant.

(use-package ef-themes
  :ensure t
  :config
  (load-theme 'ef-bio t))

;;; Status Modeline & Time Telemetry
;; ---------------------------------------------------------------------
;; Provisions an informational telemetry strip at the lower frame edge. Long buffer 
;; identities are truncated visually at the presentation layer without destructively 
;; mutating the underlying buffer string names, keeping third-party lookup tools stable.

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-icon-backend 'nerd-icons
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-state-icon t
        ;; Non-destructive visual truncation settings:
        doom-modeline-buffer-file-name-style 'truncate-with-project
        doom-modeline-max-buffer-length 30))

;; Configure high-contrast system time definitions
(setq display-time-format "%H:%M %b %d"
      display-time-default-load-average nil)

(display-time-mode 1)
(display-battery-mode 1)
(column-number-mode 1)

;;; Line Layout Structure & Relative Margins
;; ---------------------------------------------------------------------
;; Tailors buffer gutters to display relative line positions for high-speed modal jumping, 
;; while introducing spatial breathing room across prose lines.

(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

;; Add comfortable breathing margins to layout borders
(use-package spacious-padding
  :ensure t
  :init
  (spacious-padding-mode 1))

;; Set standard tracking space out of package blocks to prevent environmental side effects
(setq-default line-spacing 3)

(provide 'san-appearance)
;;; san-appearance.el ends here

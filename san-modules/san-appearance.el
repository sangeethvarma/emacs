;;; san-appearance.el --- Visual Interface & UI Frame Configuration -*- lexical-binding: t -*-

;;; Commentary:
;; This module orchestrates the visual identity of the Emacs environment.
;; It configures:
;; 1. Frame geometry optimization (native cross-platform maximization).
;; 2. Color themes (Ef-Themes ecosystem) and status bars (Doom-Modeline).
;; 3. Dynamic buffer name truncation to keep the modeline clean.
;; 4. Spacing rules, typographic padding, and line number hierarchies.

;;; Code:

;; =============================================================================
;; 1. Cross-Platform Frame Geometry Optimization
;; =============================================================================
;; Replaces legacy window configuration hacks with modern, engine-native parameters
;; that handle full-screen maximization cleanly across both Windows 10 and WSLg.

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(name . "Emacs"))

;; Suppress cursor blinking to lower rendering pipeline stress and CPU wakeups
(blink-cursor-mode 0)

;; Enable intelligent visual line wrapping across all text prose buffers
(global-visual-line-mode 1)

;; =============================================================================
;; 2. Color Theme Ecosystem Configuration
;; =============================================================================
(use-package ef-themes
  :ensure t
  :config
  ;; Load the high-contrast, visually comfortable bio-green theme variation
  (load-theme 'ef-bio t))

;; =============================================================================
;; 3. Modeline Status Geometry
;; =============================================================================
(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-icon-backend 'nerd-icons
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-state-icon t))

;; Telemetry tracking adjustments for the status bar layout
(setq display-time-format "%H:%M %b %d"
      display-time-default-load-average nil)

(display-time-mode 1)
(display-battery-mode 1)
(column-number-mode 1)

;; =============================================================================
;; 4. Dynamic Buffer Name Truncation Hook
;; =============================================================================
(defun san/truncate-long-buffer-names ()
  "Truncate the visible buffer name if it exceeds 30 characters.
Ensures that file extension suffixes remain perfectly attached. Defensive logic 
safeguards against files lacking an extension entirely to prevent concat errors."
  (when (and buffer-file-name (not (minibufferp)))
    (let* ((file-name (file-name-nondirectory buffer-file-name))
           (ext (or (file-name-extension file-name t) "")) ; DEFENSIVE: Fallback to string if nil
           (base-name (file-name-sans-extension file-name))
           (max-len 30))
      (when (> (length base-name) max-len)
        (rename-buffer (concat (substring base-name 0 max-len) "..." ext) t)))))

;; Inject the truncation pass directly into the standard file-opening lifecycle
(add-hook 'find-file-hook #'san/truncate-long-buffer-names)

;; =============================================================================
;; 5. Line Layout Structure & Relative Margins
;; =============================================================================
;; Use context-aware relative line numbers for developer and configuration scopes
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

;; Layout Padding & Spatial Adjustments
(use-package spacious-padding
  :ensure t
  :init
  (spacious-padding-mode 1))

;; FIX: Set line-spacing globally via the built-in system parameter.
;; Placing this inside spacious-padding's custom block can fail due to scope mismatches.
(setq-default line-spacing 3)

(provide 'san-appearance)
;;; san-appearance.el ends here

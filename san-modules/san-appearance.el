(blink-cursor-mode 0)

(set-fringe-mode 10)

(global-visual-line-mode) ;; TODO: set visual-line-mode if buffer width more than a certain value

;;; theme
;; (load-theme 'modus-vivendi t)

;; (use-package standard-themes
;;   :config (standard-themes-load-dark))

(use-package ef-themes ;; ef-maris-dark
  :config
  (load-theme 'ef-maris-dark t))
;; (ef-themes-load-random)

;;; modeline
(use-package doom-modeline
  :config
  (doom-modeline-mode))

(setq display-time-format "%H:%M %b %d"
	display-time-default-load-average nil)

(display-time-mode)
(display-battery-mode)
(column-number-mode)

;;; fonts
(set-face-attribute 'default nil :font "0xProto Nerd Font-12")
;; (set-face-attribute 'default nil :font "FiraCode Nerd Font-16")
(set-fontset-font t 'symbol "Segoe UI Symbol")

;;; line highlighting using lin
(use-package lin
  :defer t
  ;; You can use this to live update the face:
  ;; (customize-set-variable 'lin-face 'lin-green)
  :custom
  (setq lin-face 'lin-blue)
  (setq lin-mode-hooks
        '( dired-mode-hook
          grep-mode-hook
          ibuffer-mode-hook
          ilist-mode-hook
          occur-mode-hook
          org-agenda-mode-hook
          pdf-outline-buffer-mode-hook
	  package-menu-mode-hook
          tabulated-list-mode-hook))
  (lin-global-mode 1)) ; applies to all `lin-mode-hooks'

;;; all-the-icons
(use-package all-the-icons
  :if (display-graphic-p))

;;; line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)
;; disable line numbers for some modes
(dolist (mode '(term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; (use-package olivetti
;;   :defer
;;   :config
;;   (setq olivetti-body-width 130))
  
(provide 'san-appearance)

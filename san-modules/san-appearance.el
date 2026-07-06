;;; -*- lexical-binding: t -*-

(defun maximize-frame ()
  "Maximizes the active frame"
  (interactive)
  (if (eq system-type 'windows-nt)
      (w32-send-sys-command 61488)
    (toggle-frame-maximized)))

(when (eq system-type 'gnu/linux)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(name . "Emacs")))

(add-hook 'window-setup-hook 'maximize-frame t)

(blink-cursor-mode 0)

(global-visual-line-mode) ;; TODO: set visual-line-mode if buffer width more than a certain value

;;; theme

;; (load-theme 'modus-vivendi t)

;; (use-package standard-themes
;;   :config (standard-themes-load-dark))

(use-package ef-themes ;; ef-maris-dark
  :config
  (load-theme 'ef-bio t))
;; (ef-themes-load-random)

;;; modeline
(use-package doom-modeline
  :config
  ;; Force doom-modeline to use all-the-icons font families
  (setq doom-modeline-icon-backend 'nerd-icons)
  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-buffer-state-icon t)
  (doom-modeline-mode))

;;; --- UNIVERSAL BUFFER TRUNCATION ENGINE ---
(defun san/truncate-long-buffer-names ()
  "Truncate the visible buffer name if it exceeds 30 characters, preserving the file extension.
This does not affect the actual file name on disk."
  (when (and buffer-file-name (not (minibufferp)))
    (let* ((file-name (file-name-nondirectory buffer-file-name))
           (ext (file-name-extension file-name t)) ; 't' ensures the dot is kept (e.g., ".org")
           (base-name (file-name-sans-extension file-name))
           (max-len 30)) ; <-- Adjust your character limit here
      (when (> (length base-name) max-len)
        ;; Rename the buffer, using 't' to automatically handle duplicate names safely
        (rename-buffer (concat (substring base-name 0 max-len) "..." ext) t)))))

;; Trigger this check every time any file is opened
(add-hook 'find-file-hook #'san/truncate-long-buffer-names)

(setq display-time-format "%H:%M %b %d"
	display-time-default-load-average nil)

(display-time-mode)
(display-battery-mode)
(column-number-mode)

;;; line highlighting using lin
;; (use-package lin
;;   :defer t
;;   ;; You can use this to live update the face:
;;   ;; (customize-set-variable 'lin-face 'lin-green)
;;   :custom
;;   (setq lin-face 'lin-blue)
;;   (setq lin-mode-hooks
;;         '( dired-mode-hook
;;           grep-mode-hook
;;           ibuffer-mode-hook
;;           ilist-mode-hook
;;           occur-mode-hook
;;           org-agenda-mode-hook
;;           pdf-outline-buffer-mode-hook
;; 	  package-menu-mode-hook
;;           tabulated-list-mode-hook))
;;   (lin-global-mode 1)) ; applies to all `lin-mode-hooks'


;;; line numbers
(setq display-line-numbers-type 'relative)
;; Safely activate line numbers only for programming and config tracks
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

(use-package spacious-padding
  :custom
  (line-spacing 3)
  :init
  (spacious-padding-mode 1))

;; (use-package olivetti
;;   :defer
;;   :config
;;   (setq olivetti-body-width 130))
  
(provide 'san-appearance)

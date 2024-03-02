(setq frame-resize-pixelwise t)
(setq frame-inhibit-implied-resize t)
(setq frame-title-format '("%b"))
(setq ring-bell-function 'ignore)
(setq use-dialog-box t) ; only for mouse events, which I seldom use
(setq use-file-dialog nil)
(setq use-short-answers t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq inhibit-x-resources t)
(setq inhibit-startup-echo-area-message user-login-name) ; read the docstring
(setq inhibit-startup-buffer-menu t)

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

(setq package-enable-at-startup t)

;; Temporarily increase the garbage collection threshold. 
;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.5)

(defvar temp/emacs--file-name-handler-alist file-name-handler-alist)
(defvar temp/emacs--vc-handled-backends vc-handled-backends)
(setq file-name-handler-alist nil
      vc-handled-backends nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 1024 1024 20)
                  gc-cons-percentage 0.2
                  file-name-handler-alist temp/emacs--file-name-handler-alist
                  vc-handled-backends temp/emacs--vc-handled-backends)))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

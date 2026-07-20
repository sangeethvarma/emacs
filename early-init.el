;;; early-init.el --- Early Boot Optimizations -*- lexical-binding: t -*-

;;; Commentary:
;; Optimizes Emacs startup performance and suppresses default UI elements.

;;; Code:

;;; Frame Configuration
(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      frame-title-format '("%b"))

;;; UI Defaults
(setq ring-bell-function 'ignore
      use-dialog-box nil
      use-file-dialog nil
      use-short-answers t
      confirm-kill-emacs 'yes-or-no-p)

;;; Startup Suppression
(setq inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-x-resources t
      inhibit-startup-buffer-menu t
      inhibit-startup-echo-area-message (user-login-name)
      initial-scratch-message ";;; scratch buffer\n\n")

;;; Disable UI Components
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;;; Memory Management
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

(defvar emacs--file-name-handler-alist file-name-handler-alist)
(defvar emacs--vc-handled-backends vc-handled-backends)
(setq file-name-handler-alist nil
      vc-handled-backends nil)

;;; Restore Handlers
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist emacs--file-name-handler-alist
                  vc-handled-backends emacs--vc-handled-backends)
            (message "Startup complete: %d packages loaded in %.2fs with %d GCs"
                     (length package-activated-list)
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;;; Frame Naming
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (let ((type (if (daemonp) "daemon" "client")))
              (set-frame-name (format "%s-%d" type (length (frame-list)))))))

;;; early-init.el ends here

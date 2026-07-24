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
(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

;;; Memory Management - Set high threshold during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

;;; File Handler Optimization
(defvar san--file-name-handler-alist file-name-handler-alist)
(defvar san--vc-handled-backends vc-handled-backends)
(setq file-name-handler-alist nil
      vc-handled-backends nil)

;;; Startup Phase Tracking
(defvar san-startup-phase 'early-init
  "Current startup phase for coordination between early-init and modules.")

;;; Defer GC restoration until after package initialization
(defun san/restore-early-init-settings ()
  "Restore settings that were optimized during early init."
  (setq file-name-handler-alist san--file-name-handler-alist
        vc-handled-backends san--vc-handled-backends
        san-startup-phase 'early-restored)
  ;; Keep high GC threshold until gcmh takes over
  (message "Early init optimizations restored: %d packages loaded in %.2fs"
           (length package-activated-list)
           (float-time (time-subtract after-init-time before-init-time))))

(add-hook 'after-init-hook #'san/restore-early-init-settings)


;;; Frame Naming
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (let ((type (if (daemonp) "daemon" "client"))
                  (frame-count (1- (length (frame-list))))) ; Exclude current frame
              (set-frame-name (format "%s-%d" type frame-count)))))

;;; early-init.el ends here

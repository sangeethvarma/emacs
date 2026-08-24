;;; early-init.el --- Early boot optimizations -*- lexical-binding: t -*-

;;; Commentary:
;; Runs before package.el and the GUI frame are initialized: suppresses
;; startup UI chrome and raises GC thresholds so package/module loading
;; in init.el isn't slowed down by GC pauses.

;;; Code:

;;; Frame defaults
(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      frame-title-format '("%b"))

;;; UI behavior
(setq ring-bell-function 'ignore
      use-dialog-box nil
      use-file-dialog nil
      use-short-answers t
      confirm-kill-emacs 'yes-or-no-p)

;;; Startup screen suppression
(setq inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-x-resources t
      inhibit-startup-buffer-menu t
      inhibit-startup-echo-area-message (user-login-name)
      initial-scratch-message ";;; scratch buffer\n\n")

(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))

;;; GC: stay out of the way during startup; gcmh (san-init.el) takes over
;;; once packages are loaded.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

;;; file-name-handler-alist is consulted on every file operation (incl.
;;; each `require'/`load' during startup); disabling it while loading
;;; packages is a well-known startup speedup. Restored once init finishes.
(defvar san--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil
      vc-handled-backends nil)

(defun san/restore-early-init-settings ()
  "Undo the startup-only tweaks above now that init.el has run."
  (setq file-name-handler-alist san--file-name-handler-alist
        vc-handled-backends '(Git))
  (message "Startup: %d packages, %.2fs"
           (length package-activated-list)
           (float-time (time-subtract after-init-time before-init-time))))

(add-hook 'after-init-hook #'san/restore-early-init-settings)

;;; Name each frame by daemon/client index, useful when running as a
;;; persistent `emacs --daemon' with multiple `emacsclient -c' frames.
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (let ((type (if (daemonp) "daemon" "client"))
                  (frame-count (1- (length (frame-list)))))
              (set-frame-name (format "%s-%d" type frame-count)))))

;;; early-init.el ends here

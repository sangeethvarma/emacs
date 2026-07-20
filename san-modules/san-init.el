;;; san-init.el --- Early Runtime Optimizations -*- lexical-binding: t -*-

;;; Commentary:
;; Handles garbage collection optimization and WSL integration.

;;; Code:

;;; Garbage Collection Management
(use-package gcmh
  :ensure t
  :init
  (setq gcmh-idle-delay 'auto
        gcmh-auto-idle-delay-factor 10
        gcmh-high-cons-threshold (* 1024 1024 1024))
  :config
  (gcmh-mode 1))

;;; WSL Integration
(defun san/wsl-p ()
  "Return non-nil if running under WSL."
  (and (eq system-type 'gnu/linux)
       (or (getenv "WSL_DISTRO_NAME")
           (getenv "WSLENV")
           (and (file-exists-p "/proc/version")
                (with-temp-buffer
                  (insert-file-contents "/proc/version")
                  (string-match-p "microsoft" (buffer-string)))))))


(defun emacs--detect-wsl ()
  "Check if Emacs is running inside a WSL environment."
  (san/wsl-p))

(when (emacs--detect-wsl)
  (setq select-enable-clipboard t)
  
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe"))
    (if (file-exists-p cmd-exe)
        (setq browse-url-generic-program cmd-exe
              browse-url-generic-args '("/c" "start" "")
              browse-url-browser-function #'browse-url-generic)
      (display-warning 'san-init
                       "WSL detected but cmd.exe unreachable. URLs will use default handler."
                       :warning))))

(provide 'san-init)
;;; san-init.el ends here

;;; san-init.el --- Early Runtime Optimizations & Platform Bridging -*- lexical-binding: t -*-

;;; Commentary:
;; This module handles high-priority runtime initializations that must execute
;; immediately after the package manager layer is ready. It focuses on:
;; - Garbage Collection Management (GCMH) to eliminate editing stutter.
;; - WSL-to-Windows interoperability (Clipboard sync and host browser forwarding).

;;; Code:

;;; Garbage Collection Management (GCMH)
;; Prevents Emacs from garbage collecting frequently during active typing or minibuffer
;; completion updates. Instead, it expands the allocation memory ceiling up to 1GB
;; while you are working, and forces a collection pass once you stop typing (idle state).

(use-package gcmh
  :ensure t
  :init
  (setq gcmh-idle-delay 'auto               ; Evaluate idle threshold dynamically
        gcmh-auto-idle-delay-factor 10      ; Scale factor for idle detection
        gcmh-high-cons-threshold (* 1024 1024 1024)) ; 1GB active allocation buffer
  :config
  (gcmh-mode 1))

;;; WSL2 Host Platform Integration Layer
;; If Emacs detects it is running inside a WSL2 Linux container, it builds structural
;; interop bridges to seamlessly pass URLs and clipboard data back to the Windows host.

(defun emacs--detect-wsl ()
  "Check if Emacs is running inside a WSL environment."
  (and (eq system-type 'gnu/linux)
       (or (getenv "WSL_DISTRO_NAME")
           (getenv "WSLENV")
           (and (file-exists-p "/proc/version")
                (with-temp-buffer
                  (insert-file-contents "/proc/version")
                  (string-match-p "microsoft" (buffer-string)))))))

(when (emacs--detect-wsl)
  ;; Clipboard synchronization with Windows host
  (setq select-enable-clipboard t)
  
  ;; Host web browser forwarding via cmd.exe
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

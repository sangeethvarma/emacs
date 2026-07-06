;;; san-init.el --- Early Runtime Optimizations & Platform Bridging -*- lexical-binding: t -*-

;;; Commentary:
;; This module handles high-priority runtime initializations that must execute
;; immediately after the package manager layer is ready. It focuses on:
;; - Garbage Collection Management (GCMH) to eliminate editing stutter.
;; - WSL-to-Windows interoperability (Clipboard mapping and host browser forwarding).

;;; Code:

;;; Garbage Collection Management (GCMH)
;; ---------------------------------------------------------------------
;; Prevents Emacs from garbage collecting frequently during active typing or mini-buffer
;; completion updates. Instead, it expands the allocation memory ceiling up to 1GB
;; while you are working, and forces a collection pass once you stop typing (idle state).

(use-package gcmh
  :ensure t
  :init
  (setq gcmh-idle-delay 'auto               ; Evaluate idle threshold dynamically
        gcmh-auto-idle-delay-factor 10     ; Scale factor for idle detection
        gcmh-high-cons-threshold (* 1024 1024 1024)) ; 1GB active allocation buffer
  :config
  (gcmh-mode 1))

;;; WSL2 Host Platform Integration Layer
;; ---------------------------------------------------------------------
;; If Emacs detects it is running inside a WSL2 Linux container, it builds structural
;; interop bridges to seamlessly pass URLs and clipboard data back to the Windows host.

(when (and (eq system-type 'gnu/linux) (getenv "WSLENV"))
  
  ;; Native Clipboard Synchronization
  ;; Instructs the underlying X11/Wayland/WSLg engine to synchronize the Emacs
  ;; kill-ring with the system-wide OS clipboard ring.
  (setq select-enable-clipboard t)
  
  ;; Host Web Browser Intercept Functionality
  ;; Reroutes global web link triggers (e.g., clicking markdown links, org-mode URLs, 
  ;; or help files) out of the headless Linux environment and executes them directly
  ;; within the native Windows host web browser via the host cmd exe engine.
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
        (cmd-args '("/c" "start" "")))
    (if (file-exists-p cmd-exe)
        (setq browse-url-generic-program  cmd-exe
              browse-url-generic-args     cmd-args
              browse-url-browser-function #'browse-url-generic)
      (display-warning 'san-init 
                       "WSL Environment detected, but target Windows host 'cmd.exe' was unreachable." 
                       :warning))))

(provide 'san-init)
;;; san-init.el ends here

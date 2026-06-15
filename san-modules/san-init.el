;;; -*- lexical-binding: t -*-

;;; --- MEMORY MANAGEMENT OPTIMIZATION ---
(use-package gcmh
  :init
  (setq gcmh-idle-delay 'auto  ; Automatically calculate the best idle time
        gcmh-auto-idle-delay-factor 10
        gcmh-high-cons-threshold (* 1024 1024 1024)) ; 1GB threshold during active use
  (gcmh-mode 1))

;; --- WSL TO WINDOWS INTEROP BRIDGES ---
(when (eq system-type 'gnu/linux)
  ;; Sync system clipboard seamlessly
  (setq select-enable-clipboard t)
  
  ;; Route web browsing requests through the host Windows execution layer
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
        (cmd-args '("/c" "start" "")))
    (when (file-exists-p cmd-exe)
      (setq browse-url-generic-program  cmd-exe
            browse-url-generic-args     cmd-args
            browse-url-browser-function 'browse-url-generic))))

;;; --- GLOBAL PATH CONFIGURATION ---
(defvar san-phd-dir
  (if (eq system-type 'windows-nt)
      "C:/Users/sangeeth/OneDrive/PhD/"
    "/mnt/c/Users/sangeeth/OneDrive/PhD/")
  "The absolute root directory for all research data synced via OneDrive.")

(defun san/open-phd-dir ()
  "Instantly open the base PhD directory in Dired."
  (interactive)
  (find-file san-phd-dir))

;; Bind it to a convenient, globally accessible key chord
(keymap-global-set "C-c d p" 'san/open-phd-dir)

(provide 'san-init)

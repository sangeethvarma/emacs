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
  ;; Take over GC management from early init optimizations
  (defun san/setup-gcmh ()
    "Setup gcmh to take over GC management."
    (gcmh-mode 1)
    ;; restore normal GC settings - gcmh will manage them
    (setq gc-cons-threshold 16777216  ; 16MB - baseline
          gc-cons-percentage 0.1)
    (message "GC management transferred to gcmh"))
  
  ;; Run this after all packages are initialized
  (add-hook 'emacs-startup-hook #'san/setup-gcmh))

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
  ;; This is now the single point of truth for WSL clipboard setup
  (setq select-enable-clipboard t)
  
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe"))
    (if (file-exists-p cmd-exe)
        (setq browse-url-generic-program cmd-exe
              browse-url-generic-args '("/c" "start" "")
              browse-url-browser-function #'browse-url-generic)
      (display-warning 'san-init
                       "WSL detected but cmd.exe unreachable. URLs will use default handler."
                       :warning))))

;;; Safe Windows Username Detection
(defun san/get-windows-username ()
  "Safely get Windows username with error handling."
  (condition-case err
      (let ((win-user (ignore-errors 
                        (string-trim (shell-command-to-string "cmd.exe /c echo %USERNAME%")))))
        (when (and win-user (not (string-empty-p win-user)))
          win-user))
    (error 
     (display-warning 'san-init "Failed to retrieve Windows username" :warning)
     nil)))

;;; Spell Checker Verification
(defun san/check-spell-checker ()
  "Check for available spell checking programs and configure appropriately."
  (cond
   ((executable-find "aspell")
    (setq ispell-program-name "aspell")
    (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US")))
   ((executable-find "hunspell")
    (setq ispell-program-name "hunspell")
    (setq ispell-extra-args '("-d" "en_US")))
   (t
    (setq ispell-program-name "ispell"))))

;; Use idle timer to avoid blocking startup
(defun san/delayed-spell-checker-setup ()
  "Setup spell checker with idle delay."
  (run-with-idle-timer 1 nil #'san/check-spell-checker))

(add-hook 'emacs-startup-hook #'san/delayed-spell-checker-setup)

(provide 'san-init)
;;; san-init.el ends here

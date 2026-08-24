;;; san-init.el --- GC tuning and WSL integration -*- lexical-binding: t -*-

;;; Commentary:
;; Runs first: garbage collection handoff, WSL detection, and the
;; WSL-specific clipboard/browser/username helpers other modules use.

;;; Code:

;;; Garbage collection
;; early-init.el disables GC during startup; gcmh takes over once Emacs
;; is idle so we get low pause times without babysitting thresholds by hand.
(use-package gcmh
  :ensure t
  :custom
  (gcmh-idle-delay 'auto)
  (gcmh-auto-idle-delay-factor 10)
  (gcmh-high-cons-threshold (* 1024 1024 1024))
  :hook (emacs-startup . gcmh-mode)
  :config
  (setq gc-cons-threshold 16777216
        gc-cons-percentage 0.1))

;;; WSL detection
(defun san/wsl-p ()
  "Return non-nil if this Emacs is running inside WSL."
  (and (eq system-type 'gnu/linux)
       (or (getenv "WSL_DISTRO_NAME")
           (getenv "WSLENV")
           (and (file-exists-p "/proc/version")
                (with-temp-buffer
                  (insert-file-contents "/proc/version")
                  (string-match-p "microsoft" (buffer-string)))))))

(when (san/wsl-p)
  (setq select-enable-clipboard t)
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe"))
    (if (file-exists-p cmd-exe)
        (setq browse-url-generic-program cmd-exe
              browse-url-generic-args '("/c" "start" "")
              browse-url-browser-function #'browse-url-generic)
      (display-warning 'san-init "WSL detected but cmd.exe unreachable; URLs will use the default handler." :warning))))

(defun san/get-windows-username ()
  "Return the Windows username via cmd.exe, or nil if unavailable.
Used by modules that need to reach into the Windows filesystem (e.g.
locating SumatraPDF under a user's scoop install). cmd.exe prints a
\"UNC paths are not supported\" banner before its output whenever it's
launched from a WSL path (which default-directory always is here), so
we take the last output line rather than the whole trimmed string."
  (when (executable-find "cmd.exe")
    (let* ((output (shell-command-to-string "cmd.exe /c echo %USERNAME%"))
           (user (car (last (split-string output "[\r\n]+" t)))))
      (unless (or (null user) (string-empty-p user) (string-match-p "%USERNAME%" user))
        user))))

;;; Spell checker
;; Deferred to idle so `executable-find' calls don't add to startup time.
(defun san/check-spell-checker ()
  "Point ispell at whichever spell-checking program is installed."
  (cond
   ((executable-find "aspell")
    (setq ispell-program-name "aspell"
          ispell-extra-args '("--sug-mode=ultra" "--lang=en_US")))
   ((executable-find "hunspell")
    (setq ispell-program-name "hunspell"
          ispell-extra-args '("-d" "en_US")))
   (t
    (setq ispell-program-name "ispell"))))

(add-hook 'emacs-startup-hook
          (lambda () (run-with-idle-timer 1 nil #'san/check-spell-checker)))

(provide 'san-init)
;;; san-init.el ends here

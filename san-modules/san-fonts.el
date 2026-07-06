;;; san-fonts.el --- Font & Typography Configuration Engine -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages graphical frame typography mappings across standard frames.
;; It handles:
;; 1. Global fixed-pitch font normalization.
;; 2. Document layout scaling using mixed-pitch rules.
;; 3. Non-blocking host-to-guest font syncing under WSL2.
;; 4. International script isolation for Malayalam text rendering.

;;; Code:

(require 'subr-x)

;; =============================================================================
;; 1. Core Monospace Typography Definitions
;; =============================================================================

(defvar san/default-font "Consolas-16"
  "The default structural font face and pixel size used across standard frames.")

;; Apply font values cleanly across the fallback initialization frame state
(add-to-list 'default-frame-alist `(font . ,san/default-font))

;; Apply font attributes globally across all existing graphical buffers
(set-face-attribute 'default nil :font san/default-font)

;; =============================================================================
;; 2. Proportional Pitch & Icon Fontsets Configuration
;; =============================================================================

;; Automatically toggle beautiful variable-pitch spacing inside prose documents
(use-package mixed-pitch
  :ensure t
  :hook (text-mode . mixed-pitch-mode))

;; Load icon mapping layers cleanly
(use-package nerd-icons
  :ensure t)

;; Isolate modern symbol ranges and map them explicitly to the Nerd Font layer
(set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono"))

;; =============================================================================
;; 3. WSL2 Automatic Font Aggregation Layer
;; =============================================================================

(defun san/setup-wsl-fonts ()
  "Interrogate the host operating system and link Windows fonts directly into WSL.
Generates an explicit local fonts.conf file structure inside the Linux environment
and sweeps updates into fontconfig dynamically in a separate background thread."
  (when (and (eq system-type 'gnu/linux) (getenv "WSL_DISTRO_NAME"))
    (let* ((config-dir (expand-file-name "~/.config/fontconfig"))
           (config-file (expand-file-name "fonts.conf" config-dir)))
      (unless (file-exists-p config-file)
        (let* ((win-user (string-trim (shell-command-to-string "cmd.exe /c echo %USERNAME%")))
               (sys-fonts "/mnt/c/Windows/Fonts")
               (user-fonts (format "/mnt/c/Users/%s/AppData/Local/Microsoft/Windows/Fonts" win-user)))
          (unless (file-directory-p config-dir)
            (make-directory config-dir t))
          (with-temp-file config-file
            (insert "<?xml version=\"1.0\"?>\n")
            (insert "<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">\n")
            (insert "<fontconfig>\n")
            (insert (format "  <dir>%s</dir>\n" sys-fonts))
            (when (file-exists-p user-fonts)
              (insert (format "  <dir>%s</dir>\n" user-fonts)))
            (insert "</fontconfig>\n"))
          (message "WSL Fontconfig configuration missing: Host mappings generated.")
          ;; Fire cache processing asynchronously to prevent UI blocking loops
          (start-process "fc-cache-wsl" nil "fc-cache" "-f"))))))

;; Invoke the setup engine safely
(san/setup-wsl-fonts)

;; =============================================================================
;; 4. Malayalam Script Font Engine
;; =============================================================================

(defun san/set-malayalam-font (frame)
  "Configure high-legibility font mappings for Malayalam script sequences inside FRAME.
Locks target unicode block characters (#x0D00 to #x0D7F) explicitly to Chilanka."
  (with-selected-frame frame
    (when (display-graphic-p frame)
      (set-fontset-font t '(#x0D00 . #x0D7F) (font-spec :family "Chilanka")))))

;; Bind script hooks to frame rendering lifecycles to protect daemon frame spawning
(add-hook 'after-make-frame-functions #'san/set-malayalam-font)

;; Force direct optimization sweep across the fallback startup interface structure
(san/set-malayalam-font (selected-frame))

;; Adjust the font scale balance to keep multi-script text sizing layout uniform
(add-to-list 'face-font-rescale-alist '("Chilanka" . 1.2))

(provide 'san-fonts)
;;; san-fonts.el ends here

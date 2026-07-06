;;; san-fonts.el --- Font configuration -*- lexical-binding: t -*-

;; =============================================================================
;; 1. Default & Fixed-Pitch Font Settings
;; =============================================================================

(defvar san/default-font "Consolas-16"
  "The default font family and size for graphical Emacs frames.")

;; Ensures all future frames (including emacsclient/daemon frames) use this font
(add-to-list 'default-frame-alist `(font . ,san/default-font))

;; Ensures the current frame uses it immediately if launched interactively
(set-face-attribute 'default nil :font san/default-font)

;; =============================================================================
;; 2. UI & Icon Fonts
;; =============================================================================

(use-package mixed-pitch
  :hook
  (text-mode . mixed-pitch-mode))

(use-package nerd-icons)
(set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono"))

;; =============================================================================
;; 3. WSL Font Sharing Automation
;; =============================================================================

(require 'subr-x) ; For string-trim

(defun san/setup-wsl-fonts ()
  "Automatically map Windows fonts into WSL fontconfig if running in WSL."
  (when (and (eq system-type 'gnu/linux)
             (getenv "WSL_DISTRO_NAME")) ; Safely detects a WSL environment
    (let* ((config-dir (expand-file-name "~/.config/fontconfig"))
           (config-file (expand-file-name "fonts.conf" config-dir)))
      
      (unless (file-exists-p config-file)
        (let* ((win-user (string-trim (shell-command-to-string "cmd.exe /c echo %USERNAME%")))
               (sys-fonts "/mnt/c/Windows/Fonts")
               (user-fonts (format "/mnt/c/Users/%s/AppData/Local/Microsoft/Windows/Fonts" win-user)))
          
          (unless (file-exists-p config-dir)
            (make-directory config-dir t))
          
          (with-temp-file config-file
            (insert "<?xml version=\"1.0\"?>\n")
            (insert "<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">\n")
            (insert "<fontconfig>\n")
            (insert (format "  <dir>%s</dir>\n" sys-fonts))
            (when (file-exists-p user-fonts)
              (insert (format "  <dir>%s</dir>\n" user-fonts)))
            (insert "</fontconfig>\n"))
          
          (message "WSL Fontconfig generated automatically.")
          (message "Rebuilding WSL font cache in the background...")
          (start-process "fc-cache-wsl" nil "fc-cache" "-f"))))))

;; Run the setup function on startup
(san/setup-wsl-fonts)

;; =============================================================================
;; 4. Script-Specific Fontsets (Malayalam - Chilanka)
;; =============================================================================
(defun san/set-malayalam-font (frame)
  "Ensure Chilanka handles Malayalam whenever a graphical window opens."
  (with-selected-frame frame
    (when (display-graphic-p frame)
      ;; Optimization: Using explicit Unicode block mapping is more robust than 'malayalam
      (set-fontset-font t '(#x0D00 . #x0D7F) (font-spec :family "Chilanka")))))

;; Fixes Daemon/Client Mode: Run every time a client window connects
(add-hook 'after-make-frame-functions #'san/set-malayalam-font)
;; Fixes Normal Mode: Run immediately if Emacs was launched as a standalone GUI
(san/set-malayalam-font (selected-frame))
;; Global font scaling rule
(add-to-list 'face-font-rescale-alist '("Chilanka" . 1.2))

(provide 'san-fonts)

;;; san-fonts.el --- Font & Typography Configuration -*- lexical-binding: t -*-

;;; Commentary:
;; Configures graphical frame font mapping and typography.

;;; Code:

(require 'subr-x)

;;; Default Monospace Canvas Typography
(defvar san/default-font "Consolas-16"
  "The default structural font face and pixel size used across standard frames.")

(add-to-list 'default-frame-alist `(font . ,san/default-font))
(set-face-attribute 'default nil :font san/default-font)

;;; Proportional Pitch & Icon Fontsets Configuration
(use-package mixed-pitch
  :ensure t
  :defer t
  :hook (text-mode . mixed-pitch-mode))

(use-package nerd-icons
  :ensure t
  :defer t)

(set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono"))

;;; WSL2 Automatic Font Aggregation Layer
(defun san/setup-wsl-fonts ()
  "Interrogate the host operating system and link Windows fonts directly into WSL."
  (when (san/wsl-p)
    (let* ((config-dir (expand-file-name "~/.config/fontconfig"))
           (config-file (expand-file-name "fonts.conf" config-dir)))
      (unless (file-exists-p config-file)
        (let* ((win-user (condition-case err
                             (let ((win-user (or (ignore-errors 
                                                   (string-trim (shell-command-to-string "cmd.exe /c echo %USERNAME%")))
                                                 "")))
                               (when (string-empty-p win-user)
                                 (display-warning 'san-fonts "Could not detect Windows user" :warning)))
                           (error (progn (display-warning 'san-fonts 
                                                          "Failed to retrieve Windows username for font setup"
                                                          :warning)
                                nil))))
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
          (condition-case err
              (start-process "fc-cache-wsl" nil "fc-cache" "-f")
            (file-not-found (display-warning 'san-fonts "fc-cache not found" :warning))))))))

(san/setup-wsl-fonts)

;;; Malayalam Script Typography Engine
(defun san/set-malayalam-font (frame)
  "Configure high-legibility font mappings for Malayalam script sequences inside FRAME."
  (with-selected-frame frame
    (when (display-graphic-p frame)
      (set-fontset-font t '(#x0D00 . #x0D7F) (font-spec :family "Chilanka")))))

(add-hook 'after-make-frame-functions #'san/set-malayalam-font)
(san/set-malayalam-font (selected-frame))
(add-to-list 'face-font-rescale-alist '("Chilanka" . 1.2))

(provide 'san-fonts)
;;; san-fonts.el ends here

;;; san-fonts.el --- Fonts and typography -*- lexical-binding: t -*-

;;; Commentary:
;; Default typeface, icon fonts, WSL→Windows font linking, and Malayalam
;; script fallback.

;;; Code:

(require 'subr-x)

(defvar san/default-font "Consolas-16"
  "Default font and size for graphical frames.")

(add-to-list 'default-frame-alist `(font . ,san/default-font))
(set-face-attribute 'default nil :font san/default-font)

(use-package nerd-icons
  :ensure t
  :defer t)

(set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono"))

;;; WSL: link Windows' font directories into fontconfig so Windows-only
;;; fonts (like Consolas above) are visible to Emacs.
(defun san/setup-wsl-fonts ()
  "Generate ~/.config/fontconfig/fonts.conf pointing at the Windows font dirs."
  (let* ((config-dir (expand-file-name "~/.config/fontconfig"))
         (config-file (expand-file-name "fonts.conf" config-dir))
         (win-user (san/get-windows-username))
         (sys-fonts "/mnt/c/Windows/Fonts")
         (user-fonts (and win-user (format "/mnt/c/Users/%s/AppData/Local/Microsoft/Windows/Fonts" win-user))))
    (cond
     ((file-exists-p config-file) nil)
     ((not win-user)
      (display-warning 'san-fonts "Could not detect Windows username; skipping font linking." :warning))
     (t
      (make-directory config-dir t)
      (with-temp-file config-file
        (insert "<?xml version=\"1.0\"?>\n"
                "<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">\n"
                "<fontconfig>\n"
                (format "  <dir>%s</dir>\n" sys-fonts))
        (when (file-directory-p user-fonts)
          (insert (format "  <dir>%s</dir>\n" user-fonts)))
        (insert "</fontconfig>\n"))
      (message "Generated %s" config-file)
      (if (executable-find "fc-cache")
          (start-process "fc-cache-wsl" nil "fc-cache" "-f")
        (display-warning 'san-fonts "fc-cache not found; run it manually to pick up the new fonts.conf." :warning))))))

(when (san/wsl-p)
  (add-hook 'emacs-startup-hook
            (lambda () (run-with-idle-timer 5 nil #'san/setup-wsl-fonts))))

;;; Malayalam fallback, so it doesn't render in the default (Latin) font
(defun san/set-malayalam-font (frame)
  "Map the Malayalam Unicode block to Chilanka on FRAME."
  (when (display-graphic-p frame)
    (set-fontset-font t '(#x0D00 . #x0D7F) (font-spec :family "Chilanka") frame)))

(add-hook 'after-make-frame-functions #'san/set-malayalam-font)
(san/set-malayalam-font (selected-frame))
(add-to-list 'face-font-rescale-alist '("Chilanka" . 1.2))

(provide 'san-fonts)
;;; san-fonts.el ends here

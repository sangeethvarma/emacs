;;; san-fonts.el --- Font & Typography Configuration Engine -*- lexical-binding: t -*-

;;; Commentary:
;; This module governs graphical frame font mapping topologies. It manages:
;; - Default monospace canvas parameters across all active display platforms.
;; - Mixed-pitch prose rules for proportional reading fields.
;; - An automated asset pipeline linking host Windows font registries straight into WSL.
;; - High-legibility custom text spacing and scale balancing for Malayalam script layers.

;;; Code:

(require 'subr-x)

;;; Default Monospace Canvas Typography
;; ---------------------------------------------------------------------
;; Specifies the central terminal text face and point dimensions across both standard
;; initialization routines and newly spawned client frames.

(defvar san/default-font "Consolas-16"
  "The default structural font face and pixel size used across standard frames.")

;; Apply font values cleanly across the fallback initialization frame state
(add-to-list 'default-frame-alist `(font . ,san/default-font))

;; Apply font attributes globally across all existing graphical buffers
(set-face-attribute 'default nil :font san/default-font)

;;; Proportional Pitch & Icon Fontsets Configuration
;; ---------------------------------------------------------------------
;; Activates localized structural proportional layout fonts inside prose-heavy environments
;; while protecting code block alignment metrics and mapping UI font icon indices.

(use-package mixed-pitch
  :ensure t
  :hook (text-mode . mixed-pitch-mode))

(use-package nerd-icons
  :ensure t)

;; Map standard Unicode symbol ranges directly to Symbols Nerd Font Mono
(set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono"))

;;; WSL2 Automatic Font Aggregation Layer
;; ---------------------------------------------------------------------
;; If running inside a Linux guest virtualization instance, this utility scans the underlying 
;; host operating system architecture. It builds a localized, relative XML font configuration block 
;; linking the native Windows global font registries and local AppData user fonts directly into 
;; the guest container, then regenerates the font cache to guarantee asset parity.

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

;;; Malayalam Script Typography Engine
;; ---------------------------------------------------------------------
;; Intercepts standard buffer text generation streams. When Unicode vectors tracking 
;; the Malayalam character block range are parsed, it overrides standard monospace constraints
;; and renders them using the high-legibility Chilanka typography layout.

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

(setq package-check-signature nil)

;;; package management
(require 'package)
(require 'use-package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

(setq package-install-upgrade-built-in t)
(setq use-package-always-ensure t)
(setq package-native-compile t)
(setq use-package-hook-name-suffix nil)

(set-default-coding-systems 'utf-8)

;;; no-littering
(use-package no-littering
:config
(no-littering-theme-backups))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

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

(setopt xref-search-program 'rg)

;;; encoding - utf-8
(prefer-coding-system 'utf-8)

;;(put 'downcase-region 'disabled nil)

(require 'server)
(setq server-auth-dir (expand-file-name "server" user-emacs-directory))
(unless (server-running-p)
  (server-start))

(add-to-list 'load-path (locate-user-emacs-file "san-modules"))
(add-to-list 'load-path (locate-user-emacs-file "san-elisp"))

(require 'san-defaults)
(require 'san-keybindings)
(require 'san-appearance)
(require 'san-completions)
(require 'san-minibuffer)
(require 'san-notes)
(require 'san-citation)
(require 'san-org-capture)
(require 'san-view-files)
;; (require 'san-org-images)
(require 'san-editing)

;; (require 'san-modeline)
;; (require 'san-frame-mgmt)
;; (require 'san-completions)
;; (require 'san-windows)
;; (require 'san-scratch)
;; (require 'san-help)
;; (require 'san-coding)
;; (require 'san-python)
;; (require 'san-malayalam)
;; (require 'san-git)
;; (require 'san-buffer-mgmt)
;; (require 'san-folding)
;; (require 'san-org)
;; (require 'san-citation)





;; https://www.emacswiki.org/emacs/EmacsMsWindowsIntegration
;; target for shortcut to pin to taskbar
;; C:\Users\sangeeth\scoop\apps\emacs\current\bin\emacsclientw.exe -c -a ""

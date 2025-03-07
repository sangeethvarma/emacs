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

;;; no-littering
(use-package no-littering
:config
(no-littering-theme-backups))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))


;;; encoding - utf-8
;; (prefer-coding-system 'utf-8)

;; (put 'downcase-region 'disabled nil)

(add-to-list 'default-frame-alist '((font . "0xProto Nerd Font-12")))

(add-to-list 'load-path (locate-user-emacs-file "san-modules"))
(add-to-list 'load-path (locate-user-emacs-file "san-elisp"))
(require 'san-defaults)
(require 'san-appearance)
(require 'san-meow)
(require 'san-completions)
(require 'san-minibuffer)
(require 'san-citation)
(require 'san-windows)
(require 'san-notes)
(require 'san-scratch)
(require 'san-help)
(require 'san-editing)
(require 'san-coding)
(require 'san-malayalam)
(require 'san-git)
(require 'san-buffer-mgmt)
(require 'san-org)
(require 'san-org-images)


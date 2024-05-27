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
(setq use-package-hook-name-suffix nil)


;;; no-littering
(use-package no-littering
:config
(no-littering-theme-backups)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory)))

;;; encoding - utf-8
(prefer-coding-system 'utf-8)

(add-to-list 'load-path (locate-user-emacs-file "san-modules"))
(require 'san-defaults)
(require 'san-appearance)
(require 'san-meow)
(require 'san-completions)
(require 'san-citation)
(require 'san-windows)
(require 'san-notes)
(require 'san-scratch)
(require 'san-help)
(require 'san-editing)
(require 'san-coding)

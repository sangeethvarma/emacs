;;; init.el --- Configuration Entry Point -*- lexical-binding: t -*-

;;; Commentary:
;; Sets up package management and loads modules.

;;; Code:

;;; Package Management
(require 'package)

(setq package-check-signature 'allow-unsigned
      package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

(setq use-package-always-demand nil)  ; Ensure lazy loading by default

(add-to-list 'package-archives '("gnu-elpa" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)

(setq package-install-upgrade-built-in t
      use-package-always-ensure t
      package-native-compile t
      use-package-hook-name-suffix nil)

(require 'use-package)

;;; Encoding
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

;;; File Organization
(use-package no-littering
  :ensure t
  :init
  (no-littering-theme-backups))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'noerror))

;;; Server Configuration
(require 'server)
(setq server-auth-dir (expand-file-name "server" user-emacs-directory))
(unless (server-running-p)
  (server-start))

;;; Module Loading
(add-to-list 'load-path (locate-user-emacs-file "san-modules"))

;; Core modules
(require 'san-init)
(require 'san-paths)
(require 'san-defaults)

;; Interface modules
(require 'san-fonts)
(require 'san-appearance)

;; Input modules
(require 'san-keybindings)

;; Completion modules
(require 'san-completions)
(require 'san-minibuffer)

;; Workflow modules
(require 'san-notes)
(require 'san-citation)
(require 'san-project-mgmt)
(require 'san-org-capture)
(require 'san-editing)
(require 'san-help)
(require 'san-scratch)
(require 'san-view-files)
(require 'san-org-images)

;; Experimental modules
(require 'san-llm)      ; Language model integration
;; (require 'san-elfeed)   ; RSS feed reader

;;; init.el ends here

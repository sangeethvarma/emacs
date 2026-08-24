;;; init.el --- Configuration entry point -*- lexical-binding: t -*-

;;; Commentary:
;; Sets up package.el/use-package, then loads each san-modules/*.el in
;; dependency order (paths before anything reading san-*-dir, etc).

;;; Code:

;;; Package management
(require 'package)

(setq package-check-signature 'allow-unsigned
      package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

(add-to-list 'package-archives '("gnu-elpa" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)

(setq package-install-upgrade-built-in t
      package-native-compile t
      use-package-always-ensure t
      use-package-always-demand nil)

(require 'use-package)

;;; Encoding
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

;;; Keep package/mode state out of user-emacs-directory
(use-package no-littering
  :ensure t
  :init
  (no-littering-theme-backups))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'noerror))

;;; emacsclient server, for `emacsclient -c` / editing from the shell
(require 'server)
(setq server-auth-dir (expand-file-name "server" user-emacs-directory))
(unless (server-running-p)
  (server-start))

;;; Modules
(add-to-list 'load-path (locate-user-emacs-file "san-modules"))

;; Core
(require 'san-init)
(require 'san-paths)
(require 'san-defaults)

;; Interface
(require 'san-fonts)
(require 'san-appearance)

;; Input
(require 'san-keybindings)

;; Completion
(require 'san-completions)
(require 'san-minibuffer)

;; Workflow
(require 'san-notes)
(require 'san-citation)
(require 'san-project-mgmt)
(require 'san-org-capture)
(require 'san-editing)
(require 'san-help)
(require 'san-scratch)
(require 'san-view-files)
(require 'san-org-images)
(require 'san-org-latex)

;; AI
(require 'san-llm)

(add-hook 'after-init-hook
          (lambda () (message "Emacs fully loaded")))

;;; init.el ends here

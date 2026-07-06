;;; init.el --- Master Control Deck & Core Module Orchestration Engine -*- lexical-binding: t -*-

;;; Commentary:
;; Primary workspace routing station. It hooks third-party package networks, standardizes 
;; global UTF-8 serialization, insulates transient cache directories, launches structural 
;; communication servers, and appends user configurations sequentially.

;;; Code:

;;; Package Architecture & Repository Ecosystem
;; ---------------------------------------------------------------------
;; Establishes connection pathways to third-party ELPA/MELPA archives and 
;; optimizes bytecode compilation flags during execution setup steps.

(setq package-check-signature nil)
(require 'package)
(require 'use-package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

(setq package-install-upgrade-built-in t
      use-package-always-ensure t
      package-native-compile t
      use-package-hook-name-suffix nil)

;;; System Text Encoding Definition
;; ---------------------------------------------------------------------
;; Enforces strict UTF-8 string serialization parameters across buffer generation 
;; steps and subshell communication sockets.

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

;;; File System Insulation Layer (No-Littering Setup)
;; ---------------------------------------------------------------------
;; Automatically paths transient lock files, historical backups, and automatic 
;; data states into isolated user sub-directories to protect vault cleanliness.

(use-package no-littering
  :ensure t
  :config
  (no-littering-theme-backups))

;; Redirect custom UI adjustments out of primary configurations
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(setopt xref-search-program 'rg)

;;; Core Emacs Server Lifecycle Management
;; ---------------------------------------------------------------------
;; Provisions an automated socket listening connection layer, enabling high-speed 
;; external script interaction and web protocols without launching duplicate instances.

(require 'server)
(setq server-auth-dir (expand-file-name "server" user-emacs-directory))
(unless (server-running-p)
  (server-start))

;;; Modular Configuration Loading Sequence
;; ---------------------------------------------------------------------
;; Registers your custom development modules directory and requires each module 
;; feature sequentially to compose the complete operational workspace environment.

(add-to-list 'load-path (locate-user-emacs-file "san-modules"))

;; Initialization and structural variables
(require 'san-init)
(require 'san-paths)
(require 'san-defaults)

;; Interface, completions, and layout engines
(require 'san-keybindings)
(require 'san-fonts)
(require 'san-appearance)
(require 'san-completions)
(require 'san-minibuffer)

;; Knowledge engines, agenda frameworks, and utilities
(require 'san-notes)
(require 'san-citation)
(require 'san-project-mgmt)
(require 'san-org-capture)
(require 'san-editing)
(require 'san-help)
(require 'san-scratch)
(require 'san-view-files)
(require 'san-org-images)
;; (require 'san-llm)
;; (require 'san-elfeed)

;;; init.el ends here

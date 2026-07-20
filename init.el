;;; init.el --- Master Control Deck & Core Module Orchestration Engine -*- lexical-binding: t -*-

;;; Commentary:
;; Primary workspace routing station. It hooks third-party package networks, standardizes 
;; global UTF-8 serialization, insulates transient cache directories, launches structural 
;; communication servers, and appends user configurations sequentially.

;;; Code:

;;; Package Architecture & Repository Ecosystem
;; Establishes connection pathways to third-party ELPA/MELPA archives and 
;; optimizes bytecode compilation flags during execution setup steps.

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
      use-package-always-ensure t
      package-native-compile t
      use-package-hook-name-suffix nil)

(require 'use-package)

;;; System Text Encoding Definition
;; Enforces strict UTF-8 string serialization parameters across buffer generation 
;; steps and subshell communication sockets.

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

;;; File System Insulation Layer (No-Littering Setup)
;; Automatically paths transient lock files, historical backups, and automatic 
;; data states into isolated user sub-directories to protect vault cleanliness.

(use-package no-littering
  :ensure t
  :init
  (no-littering-theme-backups))

;; Redirect custom UI adjustments out of primary configurations
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (condition-case err
      (load custom-file)
    (error (message "Warning: Failed to load custom.el: %s" (error-message-string err)))))

;;; Core Emacs Server Lifecycle Management
;; Provisions an automated listening connection layer, enabling high-speed 
;; external script interaction and web protocols without launching duplicate instances.

(require 'server)
(setq server-auth-dir (expand-file-name "server" user-emacs-directory))
(unless (server-running-p)
  (condition-case err
      (server-start)
    (error (message "Warning: Could not start Emacs server: %s" (error-message-string err)))))

;;; Modular Configuration Loading Sequence
;; Registers your custom development modules directory and requires each module 
;; feature sequentially to compose the complete operational workspace environment.

(add-to-list 'load-path (locate-user-emacs-file "san-modules"))

;; Initialization and structural variables
(require 'san-init)
(require 'san-paths)
(require 'san-defaults)

;; Interface, fonts, and visual appearance
(require 'san-fonts)
(require 'san-appearance)

;; Input handling and keybindings
(require 'san-keybindings)

;; Completions and minibuffer enhancements
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

;;; Experimental/Disabled Modules
(require 'san-llm)      ; Language model integration
;; (require 'san-elfeed)   ; RSS feed reader

;;; init.el ends here

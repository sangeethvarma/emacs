;;; init.el --- Master Control Deck & Core Module Orchestration Engine -*- lexical-binding: t -*-

;;; Commentary:
;; This is the primary boot routing station of your custom Emacs configuration.
;; It sets up archive connections, locks defaults to UTF-8 encoding, isolates 
;; background telemetry files via 'no-littering', launches a persistent background 
;; application server, and attaches every custom operational module sequentially.

;;; Code:

;; =============================================================================
;; 1. Package Manager & Repository Configuration
;; =============================================================================

(setq package-check-signature nil)      ; Skip package signature lookups if network checks hang
(require 'package)
(require 'use-package)

;; Append the MELPA distribution server cleanly into your package download list
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Define strict download priority weights across your active package archives
(setq package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

;; Performance configuration properties for package loading
(setq package-install-upgrade-built-in t   ; Allow upgrading built-in packages seamlessly
      use-package-always-ensure t          ; Automatically download missing packages via use-package
      package-native-compile t             ; Async compile packages into high-speed native code
      use-package-hook-name-suffix nil)    ; Stop use-package from rewriting hook labels trailing string formats

;; =============================================================================
;; 2. System Text Encoding Model
;; =============================================================================

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

;; =============================================================================
;; 3. File System Insulation Layer (No-Littering Architecture)
;; =============================================================================
;; Forces third-party packages to write temporary, session, and backup assets 
;; into automated folders inside your `.emacs.d/var/` and `/etc/` paths, keeping 
;; your root dotfiles folder perfectly clean.

(use-package no-littering
  :ensure t
  :config
  (no-littering-theme-backups))

;; Extract automated interactive configurations into their own independent storage track
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Route standard identifier searches (`xref`) to utilize Ripgrep
(setopt xref-search-program 'rg)

;; =============================================================================
;; 4. Long-Lived Emacs Server Lifecycle Initialization
;; =============================================================================
;; Launches a background socket connection. This allows fast visual terminal boxes 
;; (like `emacsclientw.exe`) to mount instant workspace sessions in milliseconds 
;; without paying boot lookup costs multiple times.

(require 'server)
(setq server-auth-dir (expand-file-name "server" user-emacs-directory))
(unless (server-running-p)
  (server-start))

;; =============================================================================
;; 5. Modular Configuration Loading Sequence
;; =============================================================================
;; Includes your custom modules directory inside the Emacs search path and loads 
;; your isolated runtime environments sequentially.

(add-to-list 'load-path (locate-user-emacs-file "san-modules"))

;; Core Prerequisites & Environment Mappings
(require 'san-init)         ; Runtime platform adjustments and garbage collection tracking
(require 'san-paths)        ; Cross-platform absolute directory maps (Windows vs WSL2)
(require 'san-defaults)     ; Core editor parameters and Scoop binary mapping adjustments

;; Interface, Navigation, & Modals
(require 'san-keybindings)  ; Modal editing matrix (Meow-Dvorak) and smart window movement
(require 'san-fonts)        ; True type fonts mapping (Consolas) and Malayalam rendering rules
(require 'san-appearance)   ; Visual frames maximization, Ef-Themes, and status line structures
(require 'san-completions)  ; Minibuffer completion stack (Vertico, Corfu, Consult, Embark)
(require 'san-minibuffer)   ; Persistent inputs tracking and recent files search filters

;; Knowledge Base, Academic Reading, & Workspaces
(require 'san-notes)        ; Multi-silo note structures (Denote) and Grasp link capture
(require 'san-citation)     ; Bibliography databases (Citar-Denote) and path translation
(require 'san-org-capture)  ; Context-isolated fast intake data matrices
(require 'san-project-mgmt) ; Context-isolation agenda workspaces and PARA refiling engines
(require 'san-editing)      ; Smart home key movement and high-speed spellcheck (Jinx)
(require 'san-help)         ; Rich documentation inspectors (Helpful) and visual keys discoverer
(require 'san-scratch)      ; Persistent code testing pads (Markdown, Python, Org, Elisp)
(require 'san-view-files)   ; Native PDF parsing tools and Markdown reading hooks
(require 'san-org-images)   ; Direct clipboard image asset ingestion bridge

;;; init.el ends here

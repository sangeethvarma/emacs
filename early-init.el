;;; early-init.el --- Early Boot Optimizations & UI Neutralization -*- lexical-binding: t -*-

;;; Commentary:
;; This module executes before 'init.el' and before any graphical frames or package 
;; engines initialize. It prioritizes:
;; 1. Deactivating heavy, unneeded graphical UI elements early to stop frame stutter.
;; 2. Maxing out allocation thresholds to minimize garbage collection passes during boot.
;; 3. Defensively deferring file-handler lookups to streamline configuration load speeds.

;;; Code:

;; =============================================================================
;; 1. Frame Geometry & Window Spawning Configurations
;; =============================================================================

(setq frame-resize-pixelwise t)          ; Resize frames by pixels to prevent window rounding gaps
(setq frame-inhibit-implied-resize t)    ; Suppress early window resizing recalculations during boot
(setq frame-title-format '("%b"))        ; Standardize window borders to mirror active buffer name

;; =============================================================================
;; 2. Global Interface Comfort Defaults
;; =============================================================================

(setq ring-bell-function 'ignore)        ; Disable the highly intrusive system audio bell alert
(setq use-dialog-box t)                  ; Retain mouse-driven validation boxes for safety
(setq use-file-dialog nil)               ; Force high-speed minibuffer keyboard file selection
(setq use-short-answers t)               ; Enforce brief 'y' or 'n' answers across minibuffers
(setq confirm-kill-emacs 'yes-or-no-p)   ; Guard against accidentally quitting the main application

;; =============================================================================
;; 3. Startup Screen & Splash Suppression
;; =============================================================================

(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq inhibit-x-resources t)             ; Skip heavy X11 resources lookup flags during initialization
(setq inhibit-startup-buffer-menu t)     ; Stop default buffer selector popups at launch

;; FIX: The startup engine requires this variable to be a literal string constant matching 
;; your specific login name (extracted from your environment path: C:\Users\sangeeth).
(setq inhibit-startup-echo-area-message "sangeeth")

;; Clear out default text inside newly provisioned interactive scratchpads
(setq initial-scratch-message ";;; scratch buffer\n\n")

;; =============================================================================
;; 4. Core UI Mode Neutralization
;; =============================================================================
;; Explicitly disable heavy graphical structures before frames render on screen.

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;; =============================================================================
;; 5. Memory Management Boot Optimizations
;; =============================================================================
;; Expands the garbage collection limits to maximum memory thresholds during the boot sequence, 
;; then safely steps down parameters once your initialization hooks complete.

(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.5)

;; Temporarily cache lookups and turn off version-control background hooks during boot
(defvar temp/emacs--file-name-handler-alist file-name-handler-alist)
(defvar temp/emacs--vc-handled-backends vc-handled-backends)
(setq file-name-handler-alist nil
      vc-handled-backends nil)

;; =============================================================================
;; 6. Post-Initialization Performance Telemetry Hook
;; =============================================================================

(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Safely restore standard file handlers and version control monitors
            (setq file-name-handler-alist temp/emacs--file-name-handler-alist
                  vc-handled-backends temp/emacs--vc-handled-backends)
            
            ;; Compute and print configuration load speeds inside the *Messages* log
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Name the initial display terminal container cleanly
(add-hook 'after-init-hook (lambda () (set-frame-name "home")))

;;; early-init.el ends here

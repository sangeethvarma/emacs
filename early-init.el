;;; early-init.el --- Early Boot Optimizations & UI Neutralization -*- lexical-binding: t -*-

;;; Commentary:
;; This module executes ahead of the main configuration routing deck. It maximizes 
;; allocation boundaries, suppresses default graphical interface elements, and caches 
;; structural file handlers to achieve accelerated boot performance.

;;; Code:

;;; Frame Geometry & Spawning Safeguards
;; ---------------------------------------------------------------------
;; Disables pixel-wise display round-offs and layout shifts during active window 
;; creation to prevent stuttering frames.

(setq frame-resize-pixelwise t)
(setq frame-inhibit-implied-resize t)
(setq frame-title-format '("%b"))

;;; Global Interface Baseline Defaults
;; ---------------------------------------------------------------------
;; Neutralizes interactive prompt alerts and forces short string answers (y/n) 
;; to streamline user confirmation workflows.

(setq ring-bell-function 'ignore)
(setq use-dialog-box t)
(setq use-file-dialog nil)
(setq use-short-answers t)
(setq confirm-kill-emacs 'yes-or-no-p)

;;; Startup Screen & Splash Suppression
;; ---------------------------------------------------------------------
;; Bypasses the default splash screen buffer assembly, accelerating immediate 
;; canvas availability upon invocation.

(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq inhibit-x-resources t)
(setq inhibit-startup-buffer-menu t)
(setq inhibit-startup-echo-area-message (user-login-name))

(setq initial-scratch-message ";;; scratch buffer\n\n")

;;; Graphical UI Component Neutralization
;; ---------------------------------------------------------------------
;; Wipes out redundant mouse-driven menu structures at the C-level before 
;; frame visualization cycles begin.

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;;; Startup Memory Management Hacks
;; ---------------------------------------------------------------------
;; Spikes the GC ceiling to maximum memory limits during boot phases and caches 
;; file-name-handler-alist lookup engines to prevent heavy, blocking I/O 
;; evaluations during initialization.

(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.5)

(defvar temp/emacs--file-name-handler-alist file-name-handler-alist)
(defvar temp/emacs--vc-handled-backends vc-handled-backends)
(setq file-name-handler-alist nil
      vc-handled-backends nil)

;;; Post-Initialization Telemetry Hook
;; ---------------------------------------------------------------------
;; Restores structural handler engines once initialization is completed, handing 
;; garbage collection over to GCMH, and prints exact load timings to the echo area.

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist temp/emacs--file-name-handler-alist
                  vc-handled-backends temp/emacs--vc-handled-backends)
            
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(add-hook 'after-init-hook (lambda () (set-frame-name "home")))

;;; early-init.el ends here

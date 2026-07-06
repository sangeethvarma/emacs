;;; san-defaults.el --- Core Editor Behavior & Quality of Life Defaults -*- lexical-binding: t -*-

;;; Commentary:
;; This module defines global default options, file system preferences, and 
;; environment overrides. It contains specific safeguards for mobile Syncthing 
;; file changes, alongside explicit execution adjustments for Windows-native
;; binaries loaded through the Scoop package manager.

;;; Code:

;; =============================================================================
;; 1. Core Keybinding Adjustments & Cleanups
;; =============================================================================

;; Disable the default, easily mis-triggered introductory "hello" language screen
(keymap-global-unset "C-h h")

;; Replace active text selections immediately when typing over them
(delete-selection-mode 1)

;; Standardize intuitive backspace and word removal behaviors
(keymap-global-set "C-h C-h" #'delete-backward-char)
(keymap-global-set "M-d" #'kill-word)

;; Enable alternate-file opening in Dired (reusing the same buffer) without warning prompts
(put 'dired-find-alternate-file 'disabled nil)

;; =============================================================================
;; 2. Window Management & Trash Preferences
;; =============================================================================

(setq help-window-select t              ; Auto-focus help windows when they pop up
      kill-do-not-save-duplicates t     ; Prevent identical text clips from polluting the kill-ring
      delete-by-moving-to-trash t       ; Send deleted items to system trash instead of hard unlinking
      dired-listing-switches "-alh --group-directories-first") ; Clean, categorized Dired files view

;; =============================================================================
;; 3. Windows Native & Scoop Package Manager Optimization Layer
;; =============================================================================
;; Corrects execution pathways when Emacs is running natively on the Windows Host.
;; Ensures tools installed via Scoop (e.g., PowerShell, GNU Coreutils, Ripgrep) map
;; and encode text output perfectly without interface locking.

(when (eq system-type 'windows-nt)
  ;; Route shell subprocess execution to PowerShell Core (pwsh) natively
  (setq shell-file-name "~/scoop/apps/pwsh/current/pwsh.exe" 
        comint-process-echoes 0)
  
  ;; Map Dired directory listings to GNU 'ls' instead of using the fragile native fallback
  (setq insert-directory-program (expand-file-name "~/scoop/apps/coreutils/current/bin/ls.exe"))
  (setq dired-use-ls-dired t)
  
  ;; Configure native Ripgrep paths and optimize standard stream line-endings
  (setq rg-executable (expand-file-name "~/scoop/apps/ripgrep/current/rg.exe"))
  (add-to-list 'process-coding-system-alist '("rg\\.exe" . (utf-8-unix . utf-8-unix))))

;; =============================================================================
;; 4. Syncthing Mobile Safeguards & Integrity Anchors
;; =============================================================================
;; Prevents cross-platform file conflicts caused by mobile background syncing applications.

;; Turn off temporary `. #file#` lockfiles which can trigger race conditions and 
;; replication loops across background file-syncing agents (like Syncthing or Logan).
(setq create-lockfiles nil)

;; Instantly refresh Emacs file buffers when they are modified on disk externally
(global-auto-revert-mode 1)

;; =============================================================================
;; 5. Intelligent Instance Termination Engine (Daemon Aware)
;; =============================================================================

(defun san/smart-quit (&optional arg)
  "Intelligently handle application termination sequences.
If running inside an active Emacs server session (Daemon client frame), closes 
the visual client window while keeping the underlying process server alive.
If a hard modifier ARG is supplied (via C-u prefix), asks to kill the entire 
core background process."
  (interactive "P")
  (if arg
      (when (yes-or-no-p "Warning: You are about to kill the entire Emacs daemon. Proceed? ")
        (save-buffers-kill-emacs))
    (if (daemonp)
        (save-buffers-kill-terminal)
      (save-buffers-kill-emacs))))

;; Bind our streamlined termination logic to the default global exit sequence
(keymap-global-set "C-x C-c" #'san-smart-quit)

(provide 'san-defaults)
;;; san-defaults.el ends here

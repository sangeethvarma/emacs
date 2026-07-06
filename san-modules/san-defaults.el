;;; san-defaults.el --- Core Editor Behavior & Quality of Life Defaults -*- lexical-binding: t -*-

;;; Commentary:
;; This module establishes standard, predictable baseline preferences for the 
;; editor's internal engine. It governs default key maps, global variables,
;; automatic file synchronization behaviors, and specific settings for operating
;; natively under a Windows shell/Scoop package layout.

;;; Code:

;;; Global Key Overrides & Selection Behaviors
;; ---------------------------------------------------------------------
;; Adjusts underlying defaults to match modern, predictable text-editing habits.

(keymap-global-unset "C-h h")           ; Unset the dangerous, accidental 'hello world' help key
(delete-selection-mode 1)               ; Typing while text is selected overrides/deletes it
(keymap-global-set "C-h C-h" #'delete-backward-char) ; Map comfortable backspace alternative
(keymap-global-set "M-d" #'kill-word)   ; Fast word erasure

(put 'dired-find-alternate-file 'disabled nil) ; Enable reuse of buffers in Dired mode

;;; Window Management & Trash Preferences
;; ---------------------------------------------------------------------
;; Dictates interactive frame routing and asset safety rules.

(setq help-window-select t              ; Automatically move point focus to pop-up help windows
      kill-do-not-save-duplicates t     ; Prevent cluttering the kill-ring with identical entries
      delete-by-moving-to-trash t       ; Delete files to system trash instead of wiping them permanently
      dired-listing-switches "-alh --group-directories-first") ; Clean, readable folder sort

;;; Windows Native & Scoop Package Manager Optimization Layer
;; ---------------------------------------------------------------------
;; If execution is running directly on the native Windows NT host, this block routes
;; shell execution loops through cross-platform PowerShell Core installed via Scoop.
;; It also updates the directory parsing engine to use GNU coreutils binaries.

(when (eq system-type 'windows-nt)
  (setq shell-file-name "~/scoop/apps/pwsh/current/pwsh.exe" 
        comint-process-echoes 0)
  
  ;; Bind insertion tracking to native GNU Coreutils binary paths
  (setq insert-directory-program (expand-file-name "apps/coreutils/current/bin/ls.exe" (getenv "USERPROFILE")))
  (setq dired-use-ls-dired t)
  
  ;; Force UTF-8 byte serialization patterns across background Ripgrep processes
  (setq rg-executable (expand-file-name "apps/ripgrep/current/rg.exe" (getenv "USERPROFILE")))
  (add-to-list 'process-coding-system-alist '("rg\\.exe" . (utf-8-unix . utf-8-unix))))

;;; Automated File Sync Integrity Guarding
;; ---------------------------------------------------------------------
;; Mitigates race-conditions, file synchronization locks, and automated backup hooks
;; when editing across multiple active file system contexts.

(setq create-lockfiles nil)             ; Prevent creation of intrusive .# lock files
(global-auto-revert-mode 1)             ; Automatically reload buffers if modified externally on disk

;;; Intelligent Instance Termination Engine (Daemon Aware)
;; ---------------------------------------------------------------------
;; Overrides the standard close window command. If running inside a persistent background
;; daemon process, it terminates the client view connection context without killing the
;; master core environment, unless explicitly passed a universal prefix argument.

(defun san/smart-quit (&optional arg)
  "Intelligently handle application termination sequences.
Closes client connection buffers safely if evaluated inside a daemon session, 
or requests core engine execution shutdown when supplied with a prefix ARG."
  (interactive "P")
  (if arg
      (when (yes-or-no-p "Warning: You are about to kill the entire Emacs daemon. Proceed? ")
        (save-buffers-kill-emacs))
    (if (daemonp)
        (save-buffers-kill-terminal)
      (save-buffers-kill-emacs))))

(keymap-global-set "C-x C-c" #'san/smart-quit)

(provide 'san-defaults)
;;; san-defaults.el ends here

;;; san-defaults.el --- Core Editor Behavior & Quality of Life Defaults -*- lexical-binding: t -*-

;;; Commentary:
;; This module establishes standard, predictable baseline preferences for the 
;; editor's internal engine. It governs default key maps, global variables,
;; automatic file synchronization behaviors, and specific settings for a WSL environment.

;;; Code:

;;; Global Key Overrides & Selection Behaviors
;; Adjusts underlying defaults to match modern, predictable text-editing habits.

(keymap-global-unset "C-h h")           ; Unset the dangerous, accidental 'hello world' help key
(delete-selection-mode 1)               ; Typing while text is selected overrides/deletes it
(keymap-global-set "C-h C-h" #'delete-backward-char) ; Map comfortable backspace alternative
(keymap-global-set "M-d" #'kill-word)   ; Fast word erasure

(put 'dired-find-alternate-file 'disabled nil) ; Enable reuse of buffers in Dired mode

;;; Window Management & Trash Preferences
;; Dictates interactive frame routing and asset safety rules.

(setq help-window-select t              ; Automatically move point focus to pop-up help windows
      kill-do-not-save-duplicates t     ; Prevent cluttering the kill-ring with identical entries
      delete-by-moving-to-trash t       ; Delete files to system trash instead of wiping them permanently
      dired-listing-switches "-alh --group-directories-first" ; Clean, readable folder sort
      dired-use-ls-dired t)             ; Use ls for Dired (available in WSL)

;;; Automated File Sync Integrity Guarding
;; Mitigates race-conditions, file synchronization locks, and automated backup hooks
;; when editing across multiple active file system contexts.

(setq create-lockfiles nil)             ; Prevent creation of intrusive .# lock files
(global-auto-revert-mode 1)             ; Automatically reload buffers if modified externally on disk

;;; Intelligent Instance Termination Engine (Daemon Aware)
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

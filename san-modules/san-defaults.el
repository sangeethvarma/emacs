;;; san-defaults.el --- Core Editor Behavior & Quality of Life Defaults -*- lexical-binding: t -*-

;;; Commentary:
;; Standard baseline preferences for editor's internal engine.

;;; Code:

;;; Global Key Overrides & Selection Behaviors
(keymap-global-unset "C-h h")
(delete-selection-mode 1)
(keymap-global-set "C-h C-h" #'delete-backward-char)
(keymap-global-set "M-d" #'kill-word)

(put 'dired-find-alternate-file 'disabled nil)

;;; Window Management & Trash Preferences
(setq help-window-select t
      kill-do-not-save-duplicates t
      delete-by-moving-to-trash t
      dired-listing-switches "-alh --group-directories-first"
      dired-use-ls-dired t)

;;; Automated File Sync Integrity
(setq create-lockfiles nil
      global-auto-revert-mode 1)

;;; Intelligent Termination
(defun san/smart-quit (&optional arg)
  "Intelligently handle application termination.
Closes client connection if inside daemon session, or requests shutdown with prefix ARG."
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

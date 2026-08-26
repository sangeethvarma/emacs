;;; san-defaults.el --- Core editor behavior -*- lexical-binding: t -*-

;;; Commentary:
;; Baseline editing/window/file preferences that aren't specific to any
;; other module.

;;; Code:

(keymap-global-unset "C-h h")
(keymap-global-set "C-h C-h" #'delete-backward-char)
(keymap-global-set "M-d" #'kill-word)

;; Fresh Arch/WSL installs don't set a GECOS full name, so this otherwise
;; falls back to something unhelpful (e.g. the hostname) in exported
;; documents (LaTeX \author{}, etc).
(setq user-full-name "Sangeeth")

(delete-selection-mode 1)
(put 'dired-find-alternate-file 'disabled nil)

(setq help-window-select t
      kill-do-not-save-duplicates t
      delete-by-moving-to-trash t
      dired-listing-switches "-alh --group-directories-first"
      dired-use-ls-dired t)

(setq create-lockfiles nil)
(global-auto-revert-mode 1)

(defun san/smart-quit (&optional kill-daemon)
  "Kill the current frame/client, or with a prefix arg, kill the daemon.
Without a running daemon this just exits Emacs like `save-buffers-kill-emacs'."
  (interactive "P")
  (cond
   (kill-daemon
    (when (yes-or-no-p "Kill the entire Emacs daemon? ")
      (save-buffers-kill-emacs)))
   ((daemonp) (save-buffers-kill-terminal))
   (t (save-buffers-kill-emacs))))

(keymap-global-set "C-x C-c" #'san/smart-quit)

(provide 'san-defaults)
;;; san-defaults.el ends here

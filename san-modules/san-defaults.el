;;; -*- lexical-binding: t -*-

;; don't display HELLO file - takes a lot of time, freezes up emacs
(keymap-global-unset "C-h h")

(delete-selection-mode t)
(keymap-global-set "C-h C-h" 'delete-backward-char)
(keymap-global-unset "M-d")
(keymap-global-set "M-d" 'kill-word)

(put 'dired-find-alternate-file 'disabled nil) ;; a in dired kills the dired buffer, then visits the current line's file or directory.

(setq help-window-select t)

(setq kill-do-not-save-duplicates t)

(setq delete-by-moving-to-trash t)

;; Keep your preferred dired sorting active globally
(setq dired-listing-switches "-alh --group-directories-first")


;;; WINDOWS & SCOOP OPTIMIZATIONS
(when (eq system-type 'windows-nt)
  ;; Use powershell as the shell on windows
  (setq shell-file-name "~/scoop/apps/pwsh/current/pwsh.exe" 
        comint-process-echoes 0)
  ;; Optimize Dired with native GNU ls (bypassing the shim)
  (setq insert-directory-program (expand-file-name "~/scoop/apps/coreutils/current/bin/ls.exe"))
  (setq dired-use-ls-dired t)
  ;; Optimize Ripgrep (bypassing the shim to prevent UI freezes)
  (setq rg-executable (expand-file-name "~/scoop/apps/ripgrep/current/rg.exe"))
  ;; Force UTF-8 for Ripgrep so characters don't break searches
  (add-to-list 'process-coding-system-alist '("rg\\.exe" . (utf-8-unix . utf-8-unix))))

;;; SYNCTHING MOBILE SAFEGUARDS
;; 1. Disable lockfiles so Android Syncthing doesn't crash on symlinks
(setq create-lockfiles nil)

;; 2. Automatically refresh buffers if the file changes on disk (via mobile sync)
(global-auto-revert-mode 1)

(defun san-smart-quit (&optional arg)
  "Quit Emacs or close the current frame depending on the context.
If running as a daemon, close the current client frame.
If given a prefix argument (C-u), prompt to kill the entire Emacs server."
  (interactive "P")
  (if arg
      ;; If C-u is pressed, ask for strict confirmation before killing the daemon
      (when (yes-or-no-p "Warning: You are about to kill the entire Emacs daemon. Proceed? ")
        (save-buffers-kill-emacs))
    
    ;; If no prefix argument is given
    (if (daemonp)
        ;; We are in a daemon: gracefully close the client frame
        (save-buffers-kill-terminal)
      ;; We are in a standalone instance: just kill Emacs normally
      (save-buffers-kill-emacs))))

;; Remap the default quit keybinding to new smart function
(global-set-key (kbd "C-x C-c") #'san-smart-quit)

(provide 'san-defaults)

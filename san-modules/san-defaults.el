;;; -*- lexical-binding: t -*-

;; don't display HELLO file - takes a lot of time, freezes up emacs
(keymap-global-unset "C-h h")

(keymap-global-set "<right-fringe> <mouse-1>" 'suspend-frame) ;; getting desktop-peek like behaviour

(delete-selection-mode t)
(keymap-global-set "C-h C-h" 'delete-backward-char)

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

(provide 'san-defaults)

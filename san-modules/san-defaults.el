(global-unset-key (kbd "C-h h")) ;; don't display HELLO file - takes a lot of time, freezes up emacs

(global-set-key (kbd "<right-fringe> <mouse-1>") #'suspend-frame) ;; getting desktop-peek like behaviour

(delete-selection-mode t)
(global-set-key (kbd "C-h C-h") 'delete-backward-char)

(put 'dired-find-alternate-file 'disabled nil) ;; a in dired kills the dired buffer, then visits the current line's file or directory.

(if (equal window-system 'w32) (setq shell-file-name "~/scoop/apps/pwsh/current/pwsh.exe" comint-process-echoes 0)) ;; using powershell as the shell on windows

(setq help-window-select t)

(setq kill-do-not-save-duplicates t)


(provide 'san-defaults)

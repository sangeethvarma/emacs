(setq ispell-program-name "~/scoop/apps/aspell/current/bin/aspell.exe")
(add-hook 'text-mode-hook 'flyspell-mode)

(defun beginning-of-line-or-indentation ()
  "move to beginning of line, or indentation"
  (interactive)
  (if (bolp)
      (back-to-indentation)
    (beginning-of-line)))

(keymap-global-set "C-a" 'beginning-of-line-or-indentation)

(provide 'san-editing)

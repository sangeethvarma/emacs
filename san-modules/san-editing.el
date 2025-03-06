(defun beginning-of-line-or-indentation ()
  "move to beginning of line, or indentation"
  (interactive)
  (if (bolp)
      (back-to-indentation)
    (beginning-of-line)))

(keymap-global-set "C-a" 'beginning-of-line-or-indentation)

(use-package flyspell
  :custom
  (ispell-program-name "~/scoop/apps/aspell/current/bin/aspell.exe")
  (setq ispell-dictionary "en_GB")
  (flyspell-mark-duplications-flag nil) ;; Writegood mode does this
  (org-fold-core-style 'overlays) ;; Fix Org mode bug
  :config
  (ispell-set-spellchecker-params)
  :hook
  (text-mode . flyspell-mode)
  :bind
  (("C-c w s s" . ispell)
   ("C-c w s c" . flyspell-auto-correct-previous-word)))

(provide 'san-editing)

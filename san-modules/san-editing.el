;;; -*- lexical-binding: t -*-

(defun beginning-of-line-or-indentation ()
  "move to beginning of line, or indentation"
  (interactive)
  (if (bolp)
      (back-to-indentation)
    (beginning-of-line)))

(keymap-global-set "C-a" 'beginning-of-line-or-indentation)

(use-package jinx
  :hook (text-mode . jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))


(provide 'san-editing)

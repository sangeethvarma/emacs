;;; san-editing.el --- Text editing utilities -*- lexical-binding: t -*-

;;; Commentary:
;; Smart home key and jinx spell-checking.

;;; Code:

(defun san/beginning-of-line-or-indentation ()
  "Move to the first non-whitespace character; if already there, move to column 0."
  (interactive)
  (if (bolp)
      (back-to-indentation)
    (beginning-of-line)))

(keymap-global-set "C-a" #'san/beginning-of-line-or-indentation)

(use-package jinx
  :ensure t
  :hook ((text-mode . jinx-mode)
         (prog-mode . jinx-mode)
         (org-mode . jinx-mode)
         (markdown-mode . jinx-mode))
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

(provide 'san-editing)
;;; san-editing.el ends here

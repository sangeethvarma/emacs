;;; -*- lexical-binding: t -*-

(use-package which-key
  :config
  (which-key-mode))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
	 ("C-h v" . helpful-variable)
	 ("C-h k" . helpful-key)
	 ("C-h x" . helpful-command) 
	 ("C-h F" . helpful-function)
	 ("C-c C-d" . helpful-at-point)))

(defun san/view-backup-log ()
  "Instantly view the nightly encrypted backup log execution stream."
  (interactive)
  (find-file-other-window "~/.config/logs/backup.log"))

(keymap-global-set "C-c h b" 'san/view-backup-log)

(provide 'san-help)

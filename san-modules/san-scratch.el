;;; persistent scratch

(defun san-persistent-scratch-scratch-buffer-p ()
  "Return non-nil if the current buffer's name ends with 'scratch*'."
  (string-match "scratch\*" (buffer-name)))

(use-package persistent-scratch
  :config
  (persistent-scratch-setup-default)
  (persistent-scratch-mode)
  (setq persistent-scratch-scratch-buffer-p-function #'san-persistent-scratch-scratch-buffer-p)
  (setq persistent-scratch-what-to-save '(major-mode point)))

(provide 'san-scratch)

(use-package ace-window
  :config
  (defun san/other-window ()
    (interactive)
    (if (eq last-command 'san/other-window) (ace-window 1) (other-window 1)))
  (keymap-global-set "M-o" 'san/other-window)
  (setq aw-keys '(?h ?u ?a ?s ?e ?t ?o ?n)))

(provide 'san-windows)

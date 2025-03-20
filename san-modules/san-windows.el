(use-package ace-window
  :config
  (defun san/other-window ()
    (interactive)
    (if (eq last-command 'san/other-window) (ace-window 1) (other-window 1)))
  (keymap-global-set "M-o" 'san/other-window)
  (setq aw-keys '(?h ?u ?a ?s ?e ?t ?o ?n)))

;; Window management
;; Split windows sensibly
(setq split-width-threshold 120
      split-height-threshold nil)

;; Keep window sizes balanced
(use-package balanced-windows
  :config
  (balanced-windows-mode))

(use-package activities
  :init
  (activities-mode)
  ;; Prevent `edebug' default bindings from interfering.
  (setq edebug-inhibit-emacs-lisp-mode-bindings t)

  :bind
  (("C-x C-a C-n" . activities-new)
   ("C-x C-a C-d" . activities-define)
   ("C-x C-a C-a" . activities-resume)
   ("C-x C-a C-s" . activities-suspend)
   ("C-x C-a C-k" . activities-kill)
   ("C-x C-a RET" . activities-switch)
   ("C-x C-a b" . activities-switch-buffer)
   ("C-x C-a g" . activities-revert)
   ("C-x C-a l" . activities-list)))

(provide 'san-windows)

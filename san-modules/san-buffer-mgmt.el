(setq switch-to-buffer-obey-display-actions t)

;; (add-to-list 'display-buffer-alist
;;              '("*Async Shell Command*"
;;                display-buffer-no-window (nil)))


;; (use-package popper
;;   :ensure t ; or :straight t
;;   :bind (("C-`"   . popper-toggle)
;;          ("M-`"   . popper-cycle)
;;          ("C-M-`" . popper-toggle-type))
;;   :init
;;   (setq popper-reference-buffers
;;         '("\\*Messages\\*"
;;           "Output\\*$"
;;           "\\*Async Shell Command\\*"
;;           help-mode
;;           compilation-mode))
;;   (popper-mode +1)
;;   (popper-echo-mode +1))                ; For echo area hints

(provide 'san-buffer-mgmt)

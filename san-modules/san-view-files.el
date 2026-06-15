(keymap-global-set "C-c f r" 'recentf-open)

(use-package pdf-tools
  :hook ((pdf-view-mode . pdf-view-midnight-minor-mode)
         ;; Explicitly disable line numbers in the PDF buffer
         (pdf-view-mode . (lambda () (display-line-numbers-mode -1))))
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward))

;; Keep doc-view as a fallback
(use-package doc-view
  :custom
  (doc-view-resolution 300))

;; Doc-View
(use-package doc-view
  :custom
  (doc-view-resolution 300)
  (large-file-warning-threshold (* 50 (expt 2 20))))

(provide 'san-view-files)

(keymap-global-set "C-c f r" 'recentf-open)

;; Doc-View
(use-package doc-view
  :custom
  (doc-view-resolution 300)
  (large-file-warning-threshold (* 50 (expt 2 20))))

(setq dired-listing-switches "-alh --group-directories-first")

(provide 'san-view-files)

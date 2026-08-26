;;; san-view-files.el --- Document viewers -*- lexical-binding: t -*-

;;; Commentary:
;; PDF viewing (pdf-tools), doc-view for everything else, and markdown-mode.

;;; Code:

(use-package pdf-tools
  :ensure t
  :magic ("%PDF" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-view-midnight-minor-mode)
  :bind (:map pdf-view-mode-map
              ("C-s" . isearch-forward))
  :config
  (pdf-tools-install :no-query)
  (setq-default pdf-view-display-size 'fit-page))

(use-package doc-view
  :ensure nil
  :custom
  (doc-view-resolution 300)
  (large-file-warning-threshold (* 50 (expt 2 20))))

(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-header-scaling t)
  (markdown-fontify-code-blocks-natively t))

(provide 'san-view-files)
;;; san-view-files.el ends here

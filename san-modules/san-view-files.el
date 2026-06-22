;;; -*- lexical-binding: t -*-

(keymap-global-set "C-c f r" 'recentf-open)

(use-package pdf-tools
  :hook (pdf-view-mode . pdf-view-midnight-minor-mode)
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward))

;; Doc-View
(use-package doc-view
  :custom
  (doc-view-resolution 300)
  (large-file-warning-threshold (* 50 (expt 2 20))))

(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  ;; Enable a clean visual layout with proportional fonts for headers if preferred
  (markdown-header-scaling t)
  ;; Ensure code blocks inside your markdown files get proper programming language syntax colors
  (markdown-fontify-code-blocks-natively t)
  :config
  ;; Native outline folding: use Tab to expand/collapse sections just like Org-mode
  (add-hook 'markdown-mode-hook #'markdown-cycle))


(provide 'san-view-files)

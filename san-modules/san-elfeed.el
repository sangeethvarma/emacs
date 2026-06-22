;;; -*- lexical-binding: t -*-

(use-package elfeed
  :bind ("C-x w" . elfeed))

(use-package elfeed-org
  :config
  (elfeed-org)
  :custom
  ;; Keep your RSS feeds in an org file in your PhD directory
  (rmh-elfeed-org-files (list (expand-file-name "elfeed.org" san-phd-dir))))

(provide 'san-elfeed)

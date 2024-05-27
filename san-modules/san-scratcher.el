(use-package elfeed
    :custom
    (elfeed-db-directory
     (expand-file-name "elfeed" user-emacs-directory))
     (elfeed-show-entry-switch 'display-buffer)
    :bind
    ("C-c f" . elfeed))


;; Configure Elfeed with org mode
(use-package elfeed-org
  :config
  (elfeed-org)
  :custom
  (rmh-elfeed-org-files (list (expand-file-name "feeds.org" elfeed-db-directory))))


;; Easy insertion of weblinks
(use-package org-web-tools
  :bind
  (("C-c w w" . org-web-tools-insert-link-for-url)))


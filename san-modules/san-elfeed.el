;;; san-elfeed.el --- RSS feed reader -*- lexical-binding: t -*-

;;; Commentary:
;; elfeed, with feed subscriptions managed declaratively via an org
;; file in the Inbox, through elfeed-org.

;;; Code:

(require 'san-paths)

(use-package elfeed
  :ensure t
  :bind ("C-x w" . elfeed)
  :custom
  (elfeed-search-filter "@6-months-ago +unread"))

(use-package elfeed-org
  :ensure t
  :after elfeed
  :custom
  (rmh-elfeed-org-files (list (expand-file-name "elfeed.org" san-inbox-dir)))
  :config
  (elfeed-org))

(provide 'san-elfeed)
;;; san-elfeed.el ends here

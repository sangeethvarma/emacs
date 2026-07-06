;;; san-elfeed.el --- RSS Feed Reader & News Aggregator Layer -*- lexical-binding: t -*-

;;; Commentary:
;; This module configures the Elfeed RSS syndication reader. It parses academic
;; journals, policy newsletters, and site feeds asynchronously, anchoring active 
;; subscriptions within a structured Org-mode file layout.

;;; Code:

(require 'san-paths)

;;; Elfeed Core Aggregation Engine
;; ---------------------------------------------------------------------
;; Provisions the primary news and journal interface deck. Binds the core dashboard 
;; entry key globally and configures baseline chronological filtering rules.

(use-package elfeed
  :ensure t
  :bind (("C-x w" . elfeed))               ; Rapid dashboard invocation key
  :config
  (setq elfeed-search-filter "@6-months-ago +unread")) ; Restrict initial feed view to fresh, unread items

;;; Elfeed-Org Subscription Integration
;; ---------------------------------------------------------------------
;; Extends the database engine to manage feed URLs declaratively within an Org file 
;; structure located straight inside your PhD academic workspace directory.

(use-package elfeed-org
  :ensure t
  :after elfeed
  :custom
  ;; Anchor subscription configuration trees explicitly to your clean PhD area directory
  (rmh-elfeed-org-files (list (expand-file-name "elfeed.org" san-phd-dir)))
  :config
  (elfeed-org))

(provide 'san-elfeed)
;;; san-elfeed.el ends here

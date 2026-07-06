;;; san-elfeed.el --- RSS Feed Reader & News Aggregator Layer -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages the automated feed retrieval and aggregation workspace.
;; It seamlessly orchestrates:
;; 1. Elfeed: A database-driven high-performance feed client for Emacs.
;; 2. Elfeed-Org: Streamlines subscription parsing by pulling raw feed links 
;;    directly out of a cleanly managed Org document inside your PhD area.
;;
;; Keybindings:
;; C-x w -> Launches the central interactive Elfeed search interface.

;;; Code:

;; =============================================================================
;; 1. Elfeed Core Engine Configuration
;; =============================================================================

(use-package elfeed
  :ensure t
  :bind (("C-x w" . elfeed))            ; Defer loading until the interface dashboard is triggered
  :config
  ;; Initialize clean default search criteria (filters out older read logs by default)
  (setq elfeed-search-filter "@6-months-ago +unread"))

;; =============================================================================
;; 2. Elfeed-Org Subscription Integration (Siloed Feeds Mapping)
;; =============================================================================

(use-package elfeed-org
  :ensure t
  :after elfeed
  :custom
  ;; Safely anchors feed listings file inside your primary PARA academic storage root
  (rmh-elfeed-org-files (list (expand-file-name "elfeed.org" san-phd-dir)))
  :config
  ;; Initialize the layout transformation tree to intercept Elfeed synchronization passes
  (elfeed-org))

(provide 'san-elfeed)
;;; san-elfeed.el ends here

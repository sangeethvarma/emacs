;;; san-view-files.el --- Document Viewers & External File Renderers -*- lexical-binding: t -*-

;;; Commentary:
;; This module configures layout settings managing external rendering processes. 
;; It handles high-performance PDF rendering, large file warning safeguards, 
;; and markdown code formatting systems.

;;; Code:

(require 'use-package)

;;; PDF-Tools (Advanced Academic Reading Engine)
;; ---------------------------------------------------------------------
;; Overrides default doc-view behaviors for PDF extensions. Natively compiles pages into 
;; high-legibility buffer maps and enforces an automated midnight-mode color inversion hook 
;; to optimize reading comfort.

(use-package pdf-tools
  :ensure t
  :magic ("%PDF" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-view-midnight-minor-mode)
  :bind (:map pdf-view-mode-map
              ("C-s" . isearch-forward))   ; Bind predictable in-buffer search execution
  :config
  (pdf-tools-install :no-query)           ; Initialize underlying render binaries silently
  (setq-default pdf-view-display-size 'fit-page))

;;; Doc-View Core Settings (Fallback Document Handling)
;; ---------------------------------------------------------------------
;; Establishes high-resolution rendering variables for non-PDF media structures 
;; and configures memory protection thresholds to prevent crashing on large assets.

(use-package doc-view
  :ensure nil                             ; Core built-in component
  :custom
  (doc-view-resolution 300)               ; Enhance font clarity during document layout generation
  (large-file-warning-threshold (* 50 (expt 2 20)))) ; 50MB file warning safeguard boundary

;;; Markdown-Mode Ecosystem Configuration
;; ---------------------------------------------------------------------
;; Standardizes structural editing rules across Markdown files. Ensures that code blocks 
;; are fontified natively matching their respective major modes, and maps visibility cycles.

(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-header-scaling t)             ; Apply visual structural hierarchy to headers
  (markdown-fontify-code-blocks-natively t) ; Highlight block codes matching native syntax rules
  :hook (markdown-mode . markdown-cycle))  ; Map tab visibility folding triggers cleanly

(provide 'san-view-files)
;;; san-view-files.el ends here

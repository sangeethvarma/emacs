;;; san-view-files.el --- Document Viewers & External File Renderers -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages document and prose viewers outside standard text modes.
;; It seamlessly configures:
;; 1. Global history access mirrors.
;; 2. PDF-Tools: High-fidelity native PDF rendering engine with midnight mode.
;; 3. Doc-View: Core fallback handling parameters for heavy document assets.
;; 4. Markdown-Mode: Structured editing and syntax playbooks for GFM/Markdown files.

;;; Code:

;; =============================================================================
;; 1. Global Navigation Shortcuts Mirror
;; =============================================================================
;; Re-insures a reliable mnemonic path back into interactive historical files.
;; FIX: Corrected target function from 'recentf-open' to 'recentf-open-files'.
(keymap-global-set "C-c f r" #'recentf-open-files)

;; =============================================================================
;; 2. PDF-Tools Configuration (Advanced Academic Reading Engine)
;; =============================================================================
;; Replaces standard Doc-View scaling loops with vector abstractions. Includes 
;; automatic hooks to inject eyes-friendly midnight theme filters for reading.

(use-package pdf-tools
  :ensure t
  :magic ("%PDF" . pdf-view-mode)       ; Instantly trap PDF payloads by binary signature
  :hook (pdf-view-mode . pdf-view-midnight-minor-mode) ; Invert color ranges automatically
  :bind (:map pdf-view-mode-map
              ("C-s" . isearch-forward)) ; FIX: Declarative Emacs 29+ map alignment
  :config
  ;; Initialize the underlying epdfview binary compiler wrapper cleanly
  (pdf-tools-install :no-query)
  
  ;; Configure viewport layouts to default to page symmetry parameters
  (setq-default pdf-view-display-size 'fit-page))

;; =============================================================================
;; 3. Doc-View Core Settings (Fallback Document Handling)
;; =============================================================================

(use-package doc-view
  :ensure nil                           ; Core built-in component
  :custom
  (doc-view-resolution 300)             ; Enforce high text clarity during font rasterization
  ;; Upgrade warning boundaries to 50MB before alerting about heavy files
  (large-file-warning-threshold (* 50 (expt 2 20))))

;; =============================================================================
;; 4. Markdown-Mode Ecosystem Configuration
;; =============================================================================

(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)   ; Route common project sheets directly to Github Flavor
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-header-scaling t)           ; Scale headers proportionally to maximize outline scannability
  (markdown-fontify-code-blocks-natively t) ; Map absolute language coloring inside code snippet spaces
  :hook (markdown-mode . markdown-cycle)) ; FIX: Standardized declarative framework execution hook

(provide 'san-view-files)
;;; san-view-files.el ends here

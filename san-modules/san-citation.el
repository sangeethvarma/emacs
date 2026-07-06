;;; san-citation.el --- Academic Bibliography & Citation Architecture -*- lexical-binding: t -*-

;;; Commentary:
;; This module builds the bibliography reference manager for your doctoral research.
;; It seamlessly orchestrates:
;; 1. Org-Cite: Core Emacs bibliography parsing and export configurations.
;; 2. BibTeX: Built-in entry editing styles and dialect parameters.
;; 3. Citar: Interactive minibuffer citation insertions and asset lookups.
;; 4. Citar-Denote: Frictionless note mapping bridging citations to atomic note silos.
;; 5. WSL File Parser: Cross-platform translation converting absolute Zotero Windows 
;;    attachment paths into native WSL Linux storage paths on the fly.

;;; Code:

(require 'cl-lib)

;; =============================================================================
;; 1. Global Org-Mode Citation Layer Configuration
;; =============================================================================

;; Bind global citation references directly to your PhD Area bibliography file
(setq org-cite-global-bibliography (list (expand-file-name "references.bib" san-phd-dir)))

;; Configure modern BibLaTeX as the default target pipeline for LaTeX export layers
(setq org-cite-export-processors '((latex biblatex) (t basic)))

;; =============================================================================
;; 2. BibTeX Editor Preferences Configuration
;; =============================================================================

(use-package bibtex
  :ensure nil                           ; Core built-in component
  :custom
  (bibtex-dialect 'biblatex)            ; Enforce modern BibLaTeX field structures globally
  (bibtex-align-at-equal-sign t)        ; Maintain clean, uniform code alignment across entries
  (bibtex-user-optional-fields
   '(("keywords" "Keywords to describe the entry" "")
     ("file" "Link to a document file." "" ))))

;; =============================================================================
;; 3. Citar Core Engine (Interactive Reference Lookups)
;; =============================================================================

(use-package citar
  :ensure t
  :bind (("C-c n c" . citar-insert-citation)) ; Primary document citation insertion hook
  :custom
  (citar-bibliography org-cite-global-bibliography)
  (citar-notes-paths (list (expand-file-name "notes/" san-phd-dir)))
  (citar-file-note-extensions '("org"))
  (citar-library-paths (list (expand-file-name "PDFs/" san-phd-dir)))
  :config
  ;; --- NATIVE WSL CITAR PATH TRANSLATION PARSER ---
  ;; When running inside WSL2, Zotero's auto-generated absolute file paths point 
  ;; to Windows drive matrices (e.g., C:\Users\...\document.pdf). This parser intercepts
  ;; those fields, strips out the raw filename, and links it natively to PDFs directory.
  (when (and (eq system-type 'gnu/linux) (getenv "WSLENV"))
    (defun san/citar-wsl-file-parser (file-field)
      "Translate Windows-native citation attachment fields cleanly into WSL paths."
      (when file-field
        (let ((pdf-dir (expand-file-name "PDFs/" san-phd-dir)))
          (cl-loop for path in (split-string file-field ";")
                   for filename = (car (last (split-string path "[/\\\\]+")))
                   for full-path = (expand-file-name filename pdf-dir)
                   when (file-exists-p full-path)
                   collect full-path))))

    ;; Instruct Citar to bypass its default file locator and deploy our optimized parser
    (setq citar-file-parser-functions '(san/citar-wsl-file-parser))))

;; =============================================================================
;; 4. Citar-Denote Bridge Integration (Atomic Note Linking)
;; =============================================================================

(use-package citar-denote
  :ensure t
  :init
  (citar-denote-mode 1)
  :custom
  (citar-denote-keyword "bib")          ; Enforce uniform categorization tags for reference items
  (citar-denote-title-format nil)       ; Forces the raw citekey directly as the filename title
  :bind (("C-c n k" . citar-denote-add-reference)
         ("C-c n o" . citar-open))
  :config
  ;; Frictionless Capture Advice:
  ;; Automatically suppress confirmation prompts (`y-or-n-p`) when creating a new literature 
  ;; note for an asset. It defaults safely to creating the note immediately to preserve flow.
  (advice-add 'citar-denote-add-reference :around
              (lambda (orig-fun &rest args)
                (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) nil)))
                  (apply orig-fun args)))))

(provide 'san-citation)
;;; san-citation.el ends here

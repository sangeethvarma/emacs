;;; san-citation.el --- Academic Bibliography & Citation Architecture -*- lexical-binding: t -*-

;;; Commentary:
;; This module coordinates the bibliography and citation tracking layers supporting
;; doctoral academic prose research work. It configures:
;; - Global Org-mode citation processing styles (BibLaTeX engine targets).
;; - Local BibTeX file generation rules.
;; - Citar for vertical minibuffer reference lookups, filtered cleanly under WSL.
;; - A Citar-Denote bridge to enforce atomic note mapping for core references.

;;; Code:

(require 'cl-lib)
(require 'san-paths)

;;; Global Org-Mode Citation System
;; ---------------------------------------------------------------------
;; Specifies the target flat BibTeX reference database and establishes default 
;; export parsing rules for compiling academic manuscripts.

(setq org-cite-global-bibliography (list (expand-file-name "references.bib" san-phd-dir)))
(setq org-cite-export-processors '((latex biblatex) (t basic)))

;;; BibTeX Editor Preferences
;; ---------------------------------------------------------------------
;; Adjusts field tracking mechanics to maintain strict entry syntax uniformity.

(use-package bibtex
  :ensure nil                             ; Built-in core package primitive
  :custom
  (bibtex-dialect 'biblatex)              ; Force standard parsing constraints
  (bibtex-align-at-equal-sign t)          ; Clean visual database indentation blocks
  (bibtex-user-optional-fields
   '(("keywords" "Keywords to describe the entry" "")
     ("file" "Link to a document file." "" ))))

;;; Citar Reference Discovery Engine
;; ---------------------------------------------------------------------
;; Provides interactive lookup keys for browsing bibliographies. If running in WSL, 
;; it deploys a custom parsing function to automatically translate native Windows 
;; file locator markers back into valid guest Linux sub-paths.

(use-package citar
  :ensure t
  :bind (("C-c n c" . citar-insert-citation))
  :custom
  (citar-bibliography org-cite-global-bibliography)
  (citar-notes-paths (list (expand-file-name "notes/" san-phd-dir)))
  (citar-file-note-extensions '("org"))
  (citar-library-paths (list (expand-file-name "PDFs/" san-phd-dir)))
  :config
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

    (setq citar-file-parser-functions '(san/citar-wsl-file-parser))))

;;; Citar-Denote Bridge Integration
;; ---------------------------------------------------------------------
;; Automates academic link mapping. Includes an advice wrapper that intercepts 
;; the interactive confirmation dialog, automatically answering "yes" to prevent 
;; manual lookup prompt interruptions during note extraction steps.

(use-package citar-denote
  :ensure t
  :init
  (citar-denote-mode 1)
  :custom
  (citar-denote-keyword "bib")
  (citar-denote-title-format nil)
  :bind (("C-c n k" . citar-denote-add-reference)
         ("C-c n o" . citar-open))
  :config
  (advice-add 'citar-denote-add-reference :around
              (lambda (orig-fun &rest args)
                (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) t)))
                  (apply orig-fun args)))))

(provide 'san-citation)
;;; san-citation.el ends here

(setq org-cite-global-bibliography '("L:/references.bib"))

(setq org-cite-export-processors '((latex biblatex) (t basic)))

;; Managing Bibliographies
(use-package bibtex
  :custom
  (bibtex-dialect 'BibTeX)
  (bibtex-user-optional-fields
   '(("keywords" "Keywords to describe the entry" "")
     ("file" "Link to a document file." "" )))
  (bibtex-align-at-equal-sign t)
  (bibtex-set-dialect 'biblatex))

(use-package citar
  :bind (("C-c n c" . citar-insert-citation))
  :custom
  (citar-bibliography org-cite-global-bibliography)
  (setq citar-notes-path "L:/notes/")
  (setq citar-file-note-extensions '("org"))

  ;; Tells Citar where to find PDFs if you want to open them from Emacs
  (citar-library-paths '("L:/PDFs/")))

(use-package citar-denote
  :after (citar denote)
  :config
  (citar-denote-mode)
  (setq citar-denote-keyword "bib")
  :bind (("C-c n k" . citar-denote-add-citekey) ; Add a Zotero key to a note
	 ("C-c n o" . citar-denote-open-note))) ; Open the note for a specific paper

(use-package zotxt)

(provide 'san-citation)


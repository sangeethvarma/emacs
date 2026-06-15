(setq org-cite-global-bibliography (list (expand-file-name "references.bib" san-phd-dir)))

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
  (citar-notes-paths (list (expand-file-name "notes/" san-phd-dir)))
  (citar-file-note-extensions '("org"))
  (citar-library-paths (list (expand-file-name "PDFs/" san-phd-dir))))


(use-package citar-denote
  :init
  (citar-denote-mode 1)
  :custom
  (citar-denote-keyword "bib")
  (citar-denote-title-format nil) ; <-- Forces the citekey as the title
  :bind (("C-c n k" . citar-denote-add-reference)
         ("C-c n o" . citar-open))
  :config
  (advice-add 'citar-denote-add-reference :around
              (lambda (orig-fun &rest args)
                (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) nil)))
                  (apply orig-fun args)))))


;;; --- NATIVE WSL CITAR PARSER ---
(when (eq system-type 'gnu/linux)
  (defun san/citar-wsl-file-parser (file-field)
    "Bypass OS pathing entirely by extracting only the filename and appending it to san-phd-dir."
    (when file-field
      (let ((wsl-paths nil))
        ;; Split by semicolon in case BBT exports multiple attachments
        (dolist (path (split-string file-field ";")) 
          ;; Split the string by ANY sequence of forward or backward slashes
          (let* ((parts (split-string path "[/\\\\]+"))
                 ;; The very last piece is guaranteed to be the clean filename
                 (filename (car (last parts)))          
                 ;; Glue that filename natively to your WSL PDFs directory
                 (full-path (expand-file-name filename (expand-file-name "PDFs/" san-phd-dir))))
            ;; If the file exists, add it to the list Citar sees
            (when (file-exists-p full-path)
              (push full-path wsl-paths))))
        (nreverse wsl-paths))))

  ;; Instruct Citar to completely ignore its default behavior and exclusively use our parser
  (setq citar-file-parser-functions '(san/citar-wsl-file-parser)))

(use-package zotxt)

(provide 'san-citation)


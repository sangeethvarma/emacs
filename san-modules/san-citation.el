;;; san-citation.el --- Bibliography and citation workflow -*- lexical-binding: t -*-

;;; Commentary:
;; org-cite against a Better BibTeX-exported .bib, citar for lookup,
;; citar-denote to bridge citations to per-text Denote notes.

;;; Code:

(require 'cl-lib)
(require 'san-paths)

;; The classic `bibtex' binary can't reliably handle file paths containing
;; spaces (a decades-old limitation of the program itself, not org or
;; LaTeX) -- and every PARA area folder has one ("2 - PhD", etc). Point
;; at a space-free symlink instead of the real vault path; set it up with:
;;   mkdir -p ~/.local/share/bib
;;   ln -sf "/mnt/v/Vault/2 - PhD/Resources/references.bib" ~/.local/share/bib/references.bib
(setq org-cite-global-bibliography (list (expand-file-name "~/.local/share/bib/references.bib")))

;; diazessay uses classic \bibliographystyle{}+\bibliography{} (not
;; biblatex's \addbibresource/\printbibliography), so the LaTeX export
;; processor has to be 'bibtex to match, not 'biblatex. Make sure
;; Better BibTeX's Zotero export is set to "Better BibTeX" (not "Better
;; BibLaTeX") -- biblatex-only fields would confuse classic bibtex.
(setq org-cite-export-processors '((latex bibtex) (t basic)))

;; This Emacs's bundled org-cite (9.7.11) has no default bibliography
;; style -- org-cite-bibtex-export-bibliography only emits
;; \bibliographystyle{} when a style is explicitly passed in (e.g. via
;; #+print_bibliography: :style apalike on every document), otherwise
;; it's silently dropped and bibtex fails with "found no \bibstyle
;; command". Default to apalike rather than plain's numeric [1] style --
;; apalike.bst redefines \cite itself to print author-year, e.g.
;; "(Azevedo et al., 2013)", with no natbib needed; the diazessay class
;; loads the matching apalike.sty package to match (san-org-latex.el).
;; oc-bibtex loads lazily (only once a document actually exports via the
;; bibtex processor), so the advice has to wait for it too.
(with-eval-after-load 'oc-bibtex
  (advice-add 'org-cite-bibtex-export-bibliography :around
              (lambda (orig-fun keys files style &rest args)
                (apply orig-fun keys files (or style "apalike") args))))

(use-package bibtex
  :ensure nil
  :custom
  (bibtex-align-at-equal-sign t)
  (bibtex-user-optional-fields
   '(("keywords" "Keywords to describe the entry" "")
     ("file" "Link to a document file." ""))))

(defun san/citar-wsl-file-parser (file-field)
  "Resolve a Zotero FILE-FIELD (Windows-style paths, ;-separated) to WSL paths
under the PhD PDFs/ directory."
  (when file-field
    (let ((pdf-dir (expand-file-name "PDFs/" san-phd-dir)))
      (cl-loop for path in (split-string file-field ";")
               for filename = (car (last (split-string path "[/\\\\]+")))
               for full-path = (expand-file-name filename pdf-dir)
               when (file-exists-p full-path)
               collect full-path))))

(use-package citar
  :ensure t
  :bind ("C-c n c" . citar-insert-citation)
  :custom
  (citar-bibliography org-cite-global-bibliography)
  (citar-notes-paths (list (expand-file-name "notes/" san-phd-dir)))
  (citar-file-note-extensions '("org"))
  (citar-library-paths (list (expand-file-name "PDFs/" san-phd-dir)))
  :config
  (when (san/wsl-p)
    (setq citar-file-parser-functions '(san/citar-wsl-file-parser))))

;; citar-denote-create-note: start a new note for a reference, from
;; anywhere -- the everyday "I'm reading this, let me take notes" action.
;; citar-denote-add-reference: attach a reference to the *current* note
;; instead (e.g. a synthesis note touching multiple sources); it asks to
;; confirm the note title via y-or-n-p, auto-confirmed since the default
;; (citekey-derived) title is always fine here.
(use-package citar-denote
  :ensure t
  :init
  (citar-denote-mode 1)
  :custom
  (citar-denote-keyword "bib")
  (citar-denote-title-format nil)
  :bind (("C-c n k" . citar-denote-create-note)
         ("C-c n K" . citar-denote-add-reference)
         ("C-c n o" . citar-open))
  :config
  (advice-add 'citar-denote-add-reference :around
              (lambda (orig-fun &rest args)
                (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) t)))
                  (apply orig-fun args)))))

(provide 'san-citation)
;;; san-citation.el ends here

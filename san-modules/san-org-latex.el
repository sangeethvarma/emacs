;;; san-org-latex.el --- LaTeX and Org export configuration -*- lexical-binding: t; -*-

(with-eval-after-load 'ox-latex
  ;; Use latexmk for multi-pass compilation (handles BibTeX + cross-references automatically)
  (setq org-latex-pdf-process
        '("latexmk -f -pdf -interaction=nonstopmode -output-directory=%o %f"))

  ;; Register custom diazessay LaTeX class with Org
  (add-to-list 'org-latex-classes
               '("diazessay"
                 "\\documentclass[11pt]{diazessay}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))

;; Configure PDF viewer (SumatraPDF via WSL)
(with-eval-after-load 'org
  (setq org-file-apps
        '(("\\.pdf\\'" . "/mnt/c/Users/sangeeth/scoop/apps/sumatrapdf/current/SumatraPDF.exe %s"))))

(provide 'san-org-latex)

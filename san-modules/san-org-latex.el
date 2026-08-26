;;; san-org-latex.el --- LaTeX export -*- lexical-binding: t -*-

;;; Commentary:
;; latexmk-driven PDF export via the diazessay class. pdf-tools stays
;; the default PDF viewer everywhere (including org-mode links);
;; SumatraPDF is available on demand as a backup.

;;; Code:

(with-eval-after-load 'ox-latex
  (setq org-latex-pdf-process
        '("latexmk -f -pdf -interaction=nonstopmode -output-directory=%o %f"))
  (add-to-list 'org-latex-classes
               '("diazessay"
                 "\\documentclass[11pt]{diazessay}\n\\usepackage{apalike}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))

(defun san/open-pdf-with-sumatra (file)
  "Open FILE in SumatraPDF -- the current buffer's file, or the file at
point in Dired, by default. Backup to pdf-tools, not the default viewer."
  (interactive
   (list (or buffer-file-name
             (and (derived-mode-p 'dired-mode) (dired-get-filename nil t)))))
  (unless (and file (string-match-p "\\.pdf\\'" file))
    (user-error "Not a PDF file"))
  (let* ((win-user (san/get-windows-username))
         (sumatra (and win-user
                       (format "/mnt/c/Users/%s/scoop/apps/sumatrapdf/current/SumatraPDF.exe" win-user))))
    (unless (and sumatra (file-exists-p sumatra))
      (user-error "SumatraPDF not found"))
    ;; SumatraPDF.exe is a native Windows binary -- WSL interop hands it
    ;; argv as-is, with no path translation, so a raw /mnt/v/... path is
    ;; meaningless to it. Convert to a Windows path first.
    (let ((win-path (string-trim (shell-command-to-string
                                   (format "wslpath -w %s"
                                           (shell-quote-argument (expand-file-name file)))))))
      (start-process "sumatrapdf" nil sumatra win-path))))

(keymap-global-set "C-c o s" #'san/open-pdf-with-sumatra)

(provide 'san-org-latex)
;;; san-org-latex.el ends here

;;; screenshotting
;; (add-hook 'org-mode-hook #'org-indent-mode)
;; (add-hook 'org-mode-hook #'transient-mark-mode)

(keymap-global-set "C-c l" 'org-store-link)
(keymap-global-set "C-c a" 'org-agenda)
(keymap-global-set "C-c c" 'org-capture)

(setq org-special-ctrl-a/e t)
(setq org-special-ctrl-k t)
(setq org-ctrl-k-protect-subtree 'error)
(setq org-fold-catch-invisible-edits t)
(setq org-list-allow-alphabetical t)

(use-package org-tempo
  :ensure nil
  :config
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("kv" . "example kivy")))

(setq org-image-actual-width 800)
(setq org-startup-with-inline-images t)

(defun san/org-image-file-setup (filename-prefix)
  (interactive "sFilename Prefix: ")
  (let* ((dirname
          (concat (file-name-parent-directory
                   buffer-file-truename) "org-images/"))
	 (filename
          (concat dirname
                  (make-temp-name
		   (concat filename-prefix "-"
			   (format-time-string "%Y%m%d_%H%M%S-")))
	           ".png")))
    (when (not (file-exists-p dirname))
      (make-directory dirname t))
    (or filename)))

(defun san/save-clipboard-file (filename)
  (interactive "sSave Image As: ")
  (start-process "save-clipboard-file"
                 nil
                 "pwsh"
                 (file-truename "~/.config/emacs/san-modules/clipboard-save.ps1")
                 filename))

(defun snip () (interactive)
         (start-process "screenclip"
                        nil
                        "snippingtool"
                        "/clip"))

(defun san/insert-clipboard-file ()
  (interactive)
  (let* ((filename (san/org-image-file-setup (file-name-base buffer-file-name))))
    (progn (san/save-clipboard-file (file-truename filename))
      (insert (concat "[[file:" (file-relative-name filename) "]]\n\n")))))
                  
(provide 'san-org)

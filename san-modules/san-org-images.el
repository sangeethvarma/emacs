(setq org-image-actual-width 600)
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

(keymap-set org-mode-map "C-c i i" 'san/insert-clipboard-file)
(keymap-set org-mode-map "C-c i v" 'org-toggle-inline-images)


(provide 'san-org-images)

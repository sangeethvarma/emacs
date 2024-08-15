;;; screenshotting
(add-hook 'org-mode-hook #'org-indent-mode)
(add-hook 'org-mode-hook #'turn-on-font-lock)
(add-hook 'org-mode-hook #'transient-mark-mode)

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(defun san/org-image-file-setup (filename-prefix)
  (let* ((org-directory "~/OneDrive/org/")
	 (dirname  (concat (expand-file-name org-directory)
			   "images/"
			   (file-name-base buffer-file-name)))
	 (filename (concat dirname "/"
			   (make-temp-name
			    (concat filename-prefix "-"
				    (format-time-string "%Y%m%d_%H%M%S-")))
			   ".png")))
	 (when (not (file-exists-p dirname)) (make-directory dirname t)
	       (or filename))))

(defun san/save-clipboard-file (filename)
  (shell-command (concat
		  "Add-Type -AssemblyName System.Windows.Forms;"
		  "if ($([System.Windows.Forms.Clipboard]::ContainsImage()))"
		  "{$image = [System.Windows.Forms.Clipboard]::GetImage();"
		  "[System.Drawing.Bitmap]$image.Save('"
		  filename
		  "',[System.Drawing.Imaging.ImageFormat]::Png);"
		  "Write-Output 'clipboard content saved as file'}"
		  "else {Write-Output 'clipboard does not contain image data'}\"")))


(defun san/org-image-screenshot (&optional suspend ocr-paste)
  (interactive)
  (when suspend (suspend-frame))
  (shell-command "snippingtool /clip")
  (let ((filename (san/org-image-file-setup "ss")))
    (san/save-clipboard-file filename)
    (insert (concat "[[file:" filename "]]\n")))
  (when ocr-paste (san/clipboard-ocr) (org-yank))
  (make-frame-visible))

(provide 'san-org)

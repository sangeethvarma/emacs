;;; san-org-images.el --- Clipboard image capture -*- lexical-binding: t -*-

;;; Commentary:
;; WSL clipboard-to-PNG capture for org-download, plus a thumbnail
;; gallery for reviewing whiteboard photos synced in from the phone.

;;; Code:

(require 'subr-x)
(require 'san-paths)

(defun san/wsl-clipboard-to-file (filename)
  "Save an image from the Windows clipboard to FILENAME, via PowerShell."
  (let* ((win-path (shell-quote-argument
                     (string-trim (shell-command-to-string
                                   (format "wslpath -m %s" (shell-quote-argument (expand-file-name filename)))))))
         (ps-cmd (concat "Add-Type -AssemblyName System.Windows.Forms; "
                         "if ([System.Windows.Forms.Clipboard]::ContainsImage()) { "
                         (format "[System.Windows.Forms.Clipboard]::GetImage().Save('%s', [System.Drawing.Imaging.ImageFormat]::Png) " win-path)
                         "}")))
    (start-process "powershell-save-image" nil "powershell.exe" "-STA" "-NoProfile" "-Command" ps-cmd)))

(use-package org-download
  :ensure t
  :after org
  :custom
  (org-download-image-dir (expand-file-name "clipboard-images" san-inbox-dir))
  (org-download-screenshot-method #'san/wsl-clipboard-to-file)
  (org-download-heading-lvl nil)
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable))
  :bind ("C-c o y" . org-download-screenshot))

(defun san/review-whiteboard-photos ()
  "Browse whiteboard photos (synced in via Syncthing) as a thumbnail gallery."
  (interactive)
  (image-dired san-whiteboard-dir))

(keymap-global-set "C-c o w" #'san/review-whiteboard-photos)

(provide 'san-org-images)
;;; san-org-images.el ends here

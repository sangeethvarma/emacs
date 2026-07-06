;;; san-org-images.el --- Automated Image Ingestion & Clipboard Interop -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages graphic storage file ingestion pipelines. It leverages 
;; cross-system subshell commands to extract active image data directly from 
;; the host Windows 10 clipboard volume and write it directly into the storage vault.

;;; Code:

(require 'subr-x)
(require 'san-paths)

;;; Native Windows Host Clipboard Ingestion Bridge (WSL2 Specific)
;; ---------------------------------------------------------------------
;; Interrogates the host operating system shell. Calculates guest-to-host path mobility 
;; via 'wslpath -m', then dispatches an isolated PowerShell script to verify if an image 
;; structure is present on the host clipboard ring, saving it as an uncompressed PNG.

(defun san/wsl-clipboard-to-file (filename)
  "Extract graphic image sequences from the Windows clipboard and save them to FILENAME."
  (let* ((wslpath-cmd (format "wslpath -m %s" (shell-quote-argument filename)))
         (win-path (string-trim (shell-command-to-string wslpath-cmd)))
         (ps-cmd (concat "Add-Type -AssemblyName System.Windows.Forms; "
                         "Add-Type -AssemblyName System.Drawing; "
                         "if ([System.Windows.Forms.Clipboard]::ContainsImage()) { "
                         "  $img = [System.Windows.Forms.Clipboard]::GetImage(); "
                         "  $img.Save('" win-path "', [System.Drawing.Imaging.ImageFormat]::Png) "
                         "}")))
    (call-process "powershell.exe" nil nil nil 
                  "-STA" 
                  "-NoProfile" 
                  "-Command" 
                  ps-cmd)))

;;; Org-Download Architecture Configuration
;; ---------------------------------------------------------------------
;; Wireframe attachment engine. Routes captured file fragments natively into the 
;; universal catchment folder, mapping rapid screenshot capture commands directly 
;; onto the personal editing space.

(use-package org-download
  :ensure t
  :after org
  :custom
  ;; Enforce relative directory expansion matching the shared vault path root
  (org-download-image-dir (expand-file-name "clipboard-images" san-inbox-dir))
  (org-download-screenshot-method #'san/wsl-clipboard-to-file)
  (org-download-heading-lvl nil)         ; Organize folder storage independently of head levels
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable))
  :bind
  (("C-c o y" . org-download-screenshot))) ; High-speed screenshot capture trigger

(provide 'san-org-images)
;;; san-org-images.el ends here

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
       "Extract graphic image sequences from the Windows clipboard and save them to FILENAME asynchronously."
       (let* ((expanded-filename (expand-file-name filename))
              (win-path (shell-quote-argument 
                         (string-trim (shell-command-to-string 
                                       (format "wslpath -m %s" (shell-quote-argument expanded-filename))))))
              (ps-cmd (concat "Add-Type -AssemblyName System.Windows.Forms; "
                              "[System.Windows.Forms.Clipboard]::ContainsImage() | Out-Null; "
                              "if ([System.Windows.Forms.Clipboard]::ContainsImage()) { "
                              (format "  [System.Windows.Forms.Clipboard]::GetImage().Save('%s', [System.Drawing.Imaging.ImageFormat]::Png) " win-path)
                              "}")))
         (start-process "powershell-save-image" nil "powershell.exe" 
                        "-STA" "-NoProfile" "-Command" ps-cmd)))

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

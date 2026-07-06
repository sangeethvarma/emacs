;;; san-org-images.el --- Automated Image Ingestion & Clipboard Interop -*- lexical-binding: t -*-

;;; Commentary:
;; This module handles asset management for inline notes and documentation templates.
;; It hooks up `org-download` and implements an optimized WSL2 interoperability bridge.
;; When triggered, it crosses the Linux virtualization boundary to securely scrape 
;; graphic bitmap information directly out of the native Windows host clipboard 
;; using a silent PowerShell runtime context, saving the asset cleanly into your 
;; universal PARA Inbox storage layout.
;;
;; Keybindings:
;; C-c o y -> Intercept Windows clipboard image asset and paste layout link at point.

;;; Code:

(require 'subr-x)

;; =============================================================================
;; 1. Native Windows Host Clipboard Ingestion Bridge (WSL2 Specific)
;; =============================================================================

(defun san/wsl-clipboard-to-file (filename)
  "Extract graphic image sequences from the Windows clipboard and save them to FILENAME.
Utilizes the underlying 'wslpath' executable layer to map your guest Linux file 
arguments into absolute Windows drive references. Next, fires a non-interactive 
host PowerShell instance using a Single-Threaded Apartment (-STA) configuration 
to extract and compress the active clipboard state into a clean stream file."
  (let* ((wslpath-cmd (format "wslpath -m %s" (shell-quote-argument filename)))
         ;; PERFORMANCE: Swapped out slow regex matching loops for clean, native string trimming
         (win-path (string-trim (shell-command-to-string wslpath-cmd)))
         ;; Assemble the .NET Framework reflection script to map the visual clipboard matrix
         (ps-cmd (concat "Add-Type -AssemblyName System.Windows.Forms; "
                         "Add-Type -AssemblyName System.Drawing; "
                         "if ([System.Windows.Forms.Clipboard]::ContainsImage()) { "
                         "  $img = [System.Windows.Forms.Clipboard]::GetImage(); "
                         "  $img.Save('" win-path "', [System.Drawing.Imaging.ImageFormat]::Png) "
                         "}")))
    ;; Execute the host engine process via native, zero-shell process attachments
    (call-process "powershell.exe" nil nil nil 
                  "-STA" 
                  "-NoProfile" 
                  "-Command" 
                  ps-cmd)))

;; =============================================================================
;; 2. Org-Download Architecture Configuration
;; =============================================================================
(use-package org-download
  :ensure t
  :after org
  :custom
  ;; Funnel newly extracted visual capture data cleanly into your central PARA Intake directory
  (org-download-image-dir (expand-file-name "clipboard-images" san-inbox-dir))
  (org-download-heading-lvl nil)       ; Inject asset links inline flatly without outline nesting
  ;; Bind the image extraction engine directly to our optimized WSL path translator function
  (org-download-screenshot-method #'san/wsl-clipboard-to-file)
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable))
  :bind
  ;; Direct keyboard map into the ingestion pipeline. It automatically intercepts 
  ;; windows clipboard data, creates relative file assets, and handles buffer formatting.
  (("C-c o y" . org-download-screenshot)))

(provide 'san-org-images)
;;; san-org-images.el ends here

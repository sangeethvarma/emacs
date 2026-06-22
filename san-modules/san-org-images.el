;;; -*- lexical-binding: t -*-

(defun san/wsl-clipboard-to-file (filename)
  "Save the Windows clipboard natively to FILENAME using PowerShell."
  (let* ((win-path (replace-regexp-in-string "\n\\'" "" (shell-command-to-string (format "wslpath -m %s" (shell-quote-argument filename)))))
         (ps-cmd (format "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; if ([System.Windows.Forms.Clipboard]::ContainsImage()) { $img = [System.Windows.Forms.Clipboard]::GetImage(); $img.Save('%s', [System.Drawing.Imaging.ImageFormat]::Png) }" win-path)))
    (call-process "powershell.exe" nil nil nil "-STA" "-NoProfile" "-Command" ps-cmd)))

(use-package org-download
  :after org
  :custom
  (org-download-image-dir (expand-file-name "clipboard-images" san-inbox-dir))
  (org-download-heading-lvl nil)
  ;; Instruct org-download to use our PowerShell function as its underlying capture engine
  (org-download-screenshot-method #'san/wsl-clipboard-to-file)
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable))
  :bind
  ;; Bind directly to org-download-screenshot. It will trigger our function and handle the rest.
  (("C-c o y" . org-download-screenshot)))

(provide 'san-org-images)

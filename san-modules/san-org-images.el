;;; -*- lexical-binding: t -*-

(use-package org-download
  :after org
  :custom
  ;; Save all images to a centralized folder inside your notes directory
  (org-download-image-dir (expand-file-name "clipboard-images" san-inbox-dir))
  ;; Don't create sub-folders for every single heading
  (org-download-heading-lvl nil)
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable))
  :bind
  ;; Press C-c o y to instantly paste an image from your Windows clipboard
  (("C-c o y" . org-download-clipboard)))

(provide 'san-org-images)

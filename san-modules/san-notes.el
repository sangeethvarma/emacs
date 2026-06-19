;;; -*- lexical-binding: t -*-

;;; denote

(use-package denote
  :custom
  (denote-directory (expand-file-name "notes/" san-phd-dir))
  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n l" . denote-link-or-create)
   ("C-c n d" . denote)))

(use-package consult-denote
  :init
  (consult-denote-mode 1))

;; Start the Grasp Python backend silently
(unless (get-process "grasp-server")
  (start-process "grasp-server" 
                 "*grasp-server-log*" 
                 "/home/sangeeth/.tools/grasp/.venv/bin/python" 
                 "-m" "grasp_backend" "serve" 
                 "--path" "/mnt/c/Users/sangeeth/inbox/-grasp__inbox.org"))

(use-package org-noter
  :custom
  (org-noter-default-notes-file-names '("notes.org"))
  (org-noter-notes-search-path (list (expand-file-name "notes/" san-phd-dir)))
  (org-noter-doc-split-fraction 0.5)
  (org-noter-always-create-frame nil))

(provide 'san-notes)

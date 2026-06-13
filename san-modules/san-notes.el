;;; denote

(use-package denote
  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n l" . denote-link-or-create)
   ("C-c n d" . denote))
  :config
  (setq denote-directory (expand-file-name "notes/" san-phd-dir)))

;; Start the Grasp Python backend silently
(unless (get-process "grasp-server")
  (start-process "grasp-server" 
                 "*grasp-server-log*" 
                 "python3" 
                 "-m" "grasp_backend" "serve" 
                 "--path" (expand-file-name "notes/-grasp__inbox.org" san-phd-dir)))

(use-package org-noter
  :custom
  (org-noter-default-notes-file-names '("notes.org"))
  (org-noter-notes-search-path (list (expand-file-name "notes/" san-phd-dir)))
  (org-noter-doc-split-fraction 0.5)
  (org-noter-always-create-frame nil))

(provide 'san-notes)

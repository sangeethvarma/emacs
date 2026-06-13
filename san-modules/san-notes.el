;;; denote

(use-package denote
  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n l" . denote-link-or-create)
   ("C-c n d" . denote))
  :config
  (setq denote-directory "L:/notes/"))

;; Start the Grasp Python backend silently if it isn't already running
(unless (get-process "grasp-server")
  (start-process "grasp-server" 
                 "*grasp-server-log*" 
                 "python3" 
                 "-m" "grasp_backend" "serve" 
                 "--path" "L:/notes/-grasp__inbox.org"))

(use-package org-noter
  :custom
  ;; Tell org-noter to look for documents in your PhD PDF folder by default
  (org-noter-default-notes-file-names '("notes.org"))
  (org-noter-notes-search-path '("L:/notes/"))
  (org-noter-doc-split-fraction 0.5) ; Give the PDF 50% of the screen
  ;; Keep the notes window out of the way until you need it
  (org-noter-always-create-frame nil))

(provide 'san-notes)

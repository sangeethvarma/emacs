;;; -*- lexical-binding: t -*-

;;; denote

(use-package denote
  :custom
  ;; Your "Inbox" acts as the default catch-all for random notes
  (denote-directory (expand-file-name "notes/" san-inbox-dir))
  
  ;; Define your strict boundaries
  (denote-silos-extras-directories
   (list (expand-file-name "notes/" san-phd-dir)
         (expand-file-name "Startup/notes/" san-projects-dir)))
  
  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n i" . denote-link-or-create)
   ;; Use this new shortcut to instantly jump between your PhD and Startup silos
   ("C-c n s" . denote-silos-extras-select-silo)))

(use-package consult-denote
  :init
  (consult-denote-mode 1))

;; Start the Grasp Python backend silently
(unless (get-process "grasp-server")
  (start-process "grasp-server" 
                 "*grasp-server-log*" 
                 "/home/sangeeth/.emacs.d/tools/grasp/.venv/bin/python" 
                 "-m" "grasp_backend" "serve" 
                 "--path" (expand-file-name "-grasp__inbox.org" san-inbox-dir)))

(use-package org-noter
  :custom
  (org-noter-default-notes-file-names '("notes.org"))
  (org-noter-notes-search-path (list (expand-file-name "notes/" san-phd-dir)))
  (org-noter-doc-split-fraction 0.5)
  (org-noter-always-create-frame nil))

(provide 'san-notes)

;;; denote
(use-package denote
  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n l" . denote-link-or-create))
  :config
  (setq denote-directory "c:/Users/sangeeth/OneDrive/notes/"))

(use-package org-noter)

(provide 'san-notes)

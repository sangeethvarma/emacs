;; (add-hook 'org-mode-hook #'org-indent-mode)
;; (add-hook 'org-mode-hook #'transient-mark-mode)

;;; making a, e and k work better on org headings
(setq org-special-ctrl-a/e t)
(setq org-special-ctrl-k t)
(setq org-ctrl-k-protect-subtree 'error)
(setq org-fold-catch-invisible-edits t)
;; (org-fold-catch-invisible-edits 'error)
;; (org-fold-catch-invisible-edits 'show)

(setq org-startup-indented t)
;; (setq org-pretty-entities t)

(setq org-use-sub-superscripts "{}")
(setq org-id-link-to-org-use-id t)

(setq org-list-allow-alphabetical t)

(keymap-global-set "C-c l" 'org-store-link)
(keymap-global-set "C-c a" 'org-agenda)
;; (keymap-global-set "C-c c" 'org-capture)

(use-package org-tempo
  :ensure nil
  :config
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("kv" . "example kivy"))
  (add-to-list 'org-structure-template-alist '("go" . "src go")))

(keymap-set org-mode-map "C-c h h" 'consult-org-heading)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)))

(provide 'san-org)

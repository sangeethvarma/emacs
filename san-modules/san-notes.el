;;; -*- lexical-binding: t -*-
;;; san-modules/san-notes.el

(use-package denote
  :ensure t
  :custom
  ;; "Inbox" acts as the default catch-all for random notes
  (denote-directory (expand-file-name "notes/" san-inbox-dir))
  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n i" . denote-link-or-create)
   ("C-c n s" . san/switch-denote-silo)))

(defvar san-denote-silo-alist
  nil
  "Association list mapping Area names to their full physical paths.")

(setq san-denote-silo-alist
      `(("📥 Inbox" . ,(expand-file-name "notes/" san-inbox-dir))
        ("🎓 PhD" . ,(expand-file-name "notes/" san-phd-dir))
        ("🚀 Startup" . ,(expand-file-name "notes/" san-startup-dir))
        ("🏡 Personal Life & Health" . ,(expand-file-name "notes/" san-personal-dir))
        ("💻 Sandbox" . ,(expand-file-name "notes/" san-sandbox-dir))))

(defun san/switch-denote-silo ()
  "Frictionless silo selection engine."
  (interactive)
  (let* ((chosen-name (completing-read "Select Note Silo: " (mapcar #'car san-denote-silo-alist) nil t))
         (chosen-path (cdr (assoc chosen-name san-denote-silo-alist))))
    (setq denote-directory chosen-path)
    (message "Denote Context shifted to: %s" chosen-name)))


(use-package consult-denote
  :init
  (consult-denote-mode 1)
  :bind
  (("C-c n g" . consult-denote-grep)
   ("C-c n f" . consult-denote-find))

(unless (get-process "grasp-server")
  (start-process "grasp-server" 
                 "*grasp-server-log*" 
                 "~/.tools/grasp/.venv/bin/python" 
                 "-m" "grasp_backend" "serve" 
                 "--path" (expand-file-name "-grasp__inbox.org" san-inbox-dir)))

(use-package org-noter
  :custom
  (org-noter-default-notes-file-names '("notes.org"))
  (org-noter-notes-search-path (list (expand-file-name "notes/" san-phd-dir)))
  (org-noter-doc-split-fraction 0.5)
  (org-noter-always-create-frame nil))

(provide 'san-notes)

;;; san-notes.el --- Multi-Silo Note-Taking -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages the structural personal knowledge engine.
;; It coordinates:
;; - Denote: A minimalist file-naming note engine running under a multi-silo layout.
;; - Consult-Denote: High-speed minibuffer search and grep integration for notes.
;; - Grasp Server: Background orchestration for capturing browser clipping content.
;; - Org-Noter: Synchronized PDF reading and document annotation split layouts.

;;; Code:

;;; Denote Core Configuration (Silo-Aware Note Taking)
;; ---------------------------------------------------------------------

(use-package denote
  :ensure t
  :custom
  ;; Universal catch-all landing pad for unassigned and fleeting items
  (denote-directory (expand-file-name "notes/" san-inbox-dir))
  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n i" . denote-link-or-create)
   ("C-c n s" . san/switch-denote-silo)))

;; Definition of human-readable silo targets mapped to active paths.
;; Note: Emojis are uniformly mapped to enforce a consistent domain grammar across active frameworks.
(defvar san-denote-silo-alist nil
  "Association list mapping human-readable Area names to their physical note directories.")

(setq san-denote-silo-alist
      `(("📥 Inbox" . ,(expand-file-name "notes/" san-inbox-dir))
        ("🎓 PhD" . ,(expand-file-name "notes/" san-phd-dir))
        ("🚀 Startup" . ,(expand-file-name "notes/" san-startup-dir))
        ("🌱 Personal Life & Health" . ,(expand-file-name "notes/" san-personal-dir))
        ("🧪 Sandbox" . ,(expand-file-name "notes/" san-sandbox-dir))))

(defun san/switch-denote-silo ()
  "Frictionless note silo switching engine.
Prompts the minibuffer with clean, readable area descriptions. Upon selection, 
shifts Denote's primary working directory context and verifies the target path 
physically exists to ensure error-free file creation."
  (interactive)
  (let* ((chosen-name (completing-read "Select Note Silo: " (mapcar #'car san-denote-silo-alist) nil t))
         (chosen-path (cdr (assoc chosen-name san-denote-silo-alist))))
    ;; Defensive Verification: Build the note path directory if missing
    (unless (file-directory-p chosen-path)
      (condition-case err
	  (make-directory chosen-path t)
	(file-error (user-error "Failed to create note directory: %s" chosen-path))))
    (setq denote-directory chosen-path)
    (message "Denote context shifted to: %s" chosen-name)))

;;; Consult-Denote Integration (Minibuffer Searching & Grepping)
;; ---------------------------------------------------------------------

(use-package consult-denote
  :ensure t
  :init
  (consult-denote-mode 1)
  :bind
  (("C-c n g" . consult-denote-grep)    ; High-speed index search localized inside active silo
   ("C-c n f" . consult-denote-find)))   ; Locate specific note files via descriptive tokens

;;; Grasp Web-Capture Server Lifecycle Layer
;; ---------------------------------------------------------------------
;; Automatically provisions a long-lived Python backend service to 
;; listen for web browser markdown clips forwarded via the Grasp extension.

(let ((grasp-python-bin (expand-file-name "~/.tools/grasp/.venv/bin/python"))
      (grasp-target-inbox (expand-file-name "-grasp__inbox.org" san-inbox-dir)))
  ;; Guard check: Prevent starting duplicate instances or running if environment path is broken
  (when (and (file-exists-p grasp-python-bin)
             (not (get-process "grasp-server")))
    (start-process "grasp-server"
                   "*grasp-server-log*"
                   grasp-python-bin
                   "-m" "grasp_backend" "serve"
                   "--path" grasp-target-inbox)))

;;; Org-Noter Configuration (Synchronized Academic Annotation)
;; ---------------------------------------------------------------------

(use-package org-noter
  :ensure t
  :custom
  (org-noter-default-notes-file-names '("notes.org")) ; Standard unified annotation note file anchor
  (org-noter-notes-search-path (list (expand-file-name "notes/" san-phd-dir))) ; Anchor target search space
  (org-noter-doc-split-fraction 0.5)                  ; Perfect split symmetry balancing split screens
  (org-noter-always-create-frame nil))                ; Reuse active spatial windows instead of popups

(provide 'san-notes)
;;; san-notes.el ends here

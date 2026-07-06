;;; -*- lexical-binding: t -*-
;;; san-modules/san-project-mgmt.el --- Subdivided Context Isolation Engine

(use-package org
  :ensure nil
  :custom
  (org-todo-keywords '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "|" "DONE(d)" "CANC(c)")))
  (org-provide-todo-statistics t)
  (org-hierarchical-todo-statistics nil)
  (org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil))

(use-package org-agenda
  :ensure nil
  :custom
  (org-agenda-files
   (list (expand-file-name "inbox.org" san-inbox-dir)
         (expand-file-name "phd-todo.org" san-phd-dir)
         (expand-file-name "iterrate-todo.org" san-startup-dir)
         (expand-file-name "personal-todo.org" san-personal-dir)
         (expand-file-name "sandbox-todo.org" san-sandbox-dir)))

  (org-agenda-custom-commands
   '(("o" "🌍 Master Holistic Review"
      ((agenda "" ((org-agenda-span 7))) (alltodo "")))
     
     ("p" "🎓 PhD Academic Focus"
      ((tags-todo "research" ((org-agenda-overriding-header "🧠 Substantive Academic Work (Deep Focus)")))
       (tags-todo "admin" ((org-agenda-overriding-header "📋 Administrative Logistics & Correspondence")))
       (agenda "" ((org-agenda-span 1) (org-agenda-overriding-header "Daily Timeline"))))
      ((org-agenda-files (list (expand-file-name "phd-todo.org" san-phd-dir)))))
     
     ("s" "🚀 Iterrate Startup Context"
      ((agenda "" ((org-agenda-span 1))) (alltodo ""))
      ((org-agenda-files (list (expand-file-name "iterrate-todo.org" san-startup-dir)))))
     
     ("l" "🏡 Personal Life & Vitality Focus"
      ((tags-todo "health" ((org-agenda-overriding-header "💪 Physical Health, Nutrition & Energy Metrics")))
       (tags-todo "life" ((org-agenda-overriding-header "📋 Daily Life Logistics, Finances & Projects")))
       (agenda "" ((org-agenda-span 1) (org-agenda-overriding-header "Personal Schedule"))))
      ((org-agenda-files (list (expand-file-name "personal-todo.org" san-personal-dir))))))))

(keymap-global-set "C-c a" 'org-agenda)

(defvar san-resource-folder-alist nil
  "Association list mapping human-readable PARA areas to their specific Resource folders.")

(setq san-resource-folder-alist
      `(("💪 1 - Personal Resources" . ,(expand-file-name "Resources/" san-personal-dir))
        ("🎓 2 - PhD Resources"      . ,(expand-file-name "Resources/" san-phd-dir))
        ("🚀 3 - Iterrate Resources" . ,(expand-file-name "Resources/" san-startup-dir))
        ("🧪 Sandbox Resources"      . ,(expand-file-name "Resources/" san-sandbox-dir))))

(defun san/dired-refile-to-resource ()
  "Refile marked files (or the file at point) in Dired/Dirvish directly into a chosen PARA Resource directory."
  (interactive)
  ;; Ensure we are operating inside a true Dired or Dirvish context
  (unless (derived-mode-p 'dired-mode)
    (user-error "Not in a Dired or Dirvish buffer"))
  
  ;; dired-get-marked-files automatically fetches marked files, 
  ;; or falls back to the file under the cursor if no marks exist.
  (let* ((files (dired-get-marked-files))
         (count (length files)))
    (if (null files)
        (message "No files found to refile.")
      
      (let* ((prompt (if (= count 1)
                         (format "Refile '%s' to: " (file-name-nondirectory (car files)))
                       (format "Refile %d marked files to: " count)))
             (chosen-key (completing-read prompt
                                          (mapcar #'car san-resource-folder-alist)
                                          nil t))
             (target-dir (cdr (assoc chosen-key san-resource-folder-alist))))
        
        ;; Safety check: Build the resource folder if it doesn't physically exist yet
        (unless (file-directory-p target-dir)
          (make-directory target-dir t))
        
        ;; Iterate over the file list and execute cross-platform safe renames
        (dolist (file files)
          (let* ((short-name (file-name-nondirectory file))
                 (destination (expand-file-name short-name target-dir)))
            (rename-file file destination 1))) ; 1 ensures it prompts if a conflict occurs
        
        ;; Flush the Dired/Dirvish buffer cache so files visually vanish instantly
        (revert-buffer)
        (message "Successfully refiled %d file(s) ➔ %s" count chosen-key)))))

;; Bind the command to a mnemonic shortcut inside Dired/Dirvish maps
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c f R") #'san/dired-refile-to-resource))

(provide 'san-project-mgmt)

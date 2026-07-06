;;; san-project-mgmt.el --- Subdivided Context Isolation & Agenda Engine -*- lexical-binding: t -*-

;;; Commentary:
;; This module forms the task management and context-isolation engine of the system.
;; It hooks up Org-Mode and Org-Agenda around your specific flat PARA structure to:
;; 1. Establish custom TODO tracking workflows and state machines.
;; 2. Build siloed, deep-focus custom agenda views separating types of work.
;; 3. Implement an interactive refiling function to file Dired assets directly 
;;    into your targeted Area "Resources/" folders without manual navigation.

;;; Code:

(require 'org)
(require 'org-agenda)

;; =============================================================================
;; 1. Core Org-Mode Task Handling Configuration
;; =============================================================================

(use-package org
  :ensure nil                           ; Core built-in component
  :custom
  ;; Define a highly legible task tracking lifecycle sequence
  (org-todo-keywords '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "|" "DONE(d)" "CANC(c)")))
  (org-provide-todo-statistics t)       ; Track visual completion stats on main headers
  (org-hierarchical-todo-statistics nil) ; Aggregate recursive subtask metrics holistically
  
  ;; Configure rapid task refiling targets across all known active project todo logs
  (org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 'file)   ; Render target paths by starting at the file layer
  (org-outline-path-complete-in-steps nil)) ; Complete wide outline targets in a single pass

;; =============================================================================
;; 2. Org-Agenda Workspace & Context Isolation Matrix
;; =============================================================================

(use-package org-agenda
  :ensure nil                           ; Core built-in component
  :custom
  ;; Universal catchment array aggregating task items across all operational files
  (org-agenda-files
   (list (expand-file-name "inbox.org" san-inbox-dir)
         (expand-file-name "phd-todo.org" san-phd-dir)
         (expand-file-name "iterrate-todo.org" san-startup-dir)
         (expand-file-name "personal-todo.org" san-personal-dir)
         (expand-file-name "sandbox-todo.org" san-sandbox-dir)))

  ;; FIX: Converted from a static quote to a backtick structure to ensure 
  ;; local `org-agenda-files` constraints evaluate path strings properly.
  (org-agenda-custom-commands
   `(("o" "🌍 Master Holistic Review"
      ((agenda "" ((org-agenda-span 7))) (alltodo "")))
     
     ("p" "🎓 PhD Academic Focus"
      ((tags-todo "research" ((org-agenda-overriding-header "🧠 Substantive Academic Work (Deep Focus)")))
       (tags-todo "admin" ((org-agenda-overriding-header "📋 Administrative Logistics & Correspondence")))
       (agenda "" ((org-agenda-span 1) (org-agenda-overriding-header "Daily Timeline"))))
      ((org-agenda-files ,(list (expand-file-name "phd-todo.org" san-phd-dir)))))
     
     ("s" "🚀 Iterrate Startup Context"
      ((agenda "" ((org-agenda-span 1))) (alltodo ""))
      ((org-agenda-files ,(list (expand-file-name "iterrate-todo.org" san-startup-dir)))))
     
     ("l" "🏡 Personal Life & Vitality Focus"
      ((tags-todo "health" ((org-agenda-overriding-header "💪 Physical Health, Nutrition & Energy Metrics")))
       (tags-todo "life" ((org-agenda-overriding-header "📋 Daily Life Logistics, Finances & Projects")))
       (agenda "" ((org-agenda-span 1) (org-agenda-overriding-header "Personal Schedule"))))
      ((org-agenda-files ,(list (expand-file-name "personal-todo.org" san-personal-dir))))))))

;; Bind the primary operational view launcher to standard global mnemonics
(keymap-global-set "C-c a" #'org-agenda)

;; =============================================================================
;; 3. Dired Asset Refiling Engine (Automated PARA Filing)
;; =============================================================================

(defvar san-resource-folder-alist nil
  "Association list mapping human-readable PARA areas to their specific Resource folders.")

(setq san-resource-folder-alist
      `(("💪 1 - Personal Resources" . ,(expand-file-name "Resources/" san-personal-dir))
        ("🎓 2 - PhD Resources"      . ,(expand-file-name "Resources/" san-phd-dir))
        ("🚀 3 - Iterrate Resources" . ,(expand-file-name "Resources/" san-startup-dir))
        ("🧪 Sandbox Resources"      . ,(expand-file-name "Resources/" san-sandbox-dir))))

(defun san/dired-refile-to-resource ()
  "Refile marked files (or the file at point) instantly into a chosen PARA Resource vault.
Works fluidly inside both native Dired and advanced Dirvish layout instances. Flushes 
buffer caches immediately after moving data to update the visual tree."
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (user-error "Not in a Dired or Dirvish buffer"))
  
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
        
        ;; Ensure target directories physically exist before triggering renames
        (unless (file-directory-p target-dir)
          (make-directory target-dir t))
        
        ;; Iterate over selections and apply cross-platform file transfers
        (dolist (file files)
          (let* ((short-name (file-name-nondirectory file))
                 (destination (expand-file-name short-name target-dir)))
            (rename-file file destination 1))) ; 1 enforces built-in safety overwrite alerts
        
        ;; Flash the Dired frame buffer cache to visually confirm file transitions
        (revert-buffer)
        (message "Successfully refiled %d file(s) ➔ %s" count chosen-key)))))

;; Bind the file refiler to standard mnemonic keys using Emacs 29+ map conventions
(with-eval-after-load 'dired
  (keymap-set dired-mode-map "C-c f R" #'san/dired-refile-to-resource))

(provide 'san-project-mgmt)
;;; san-project-mgmt.el ends here

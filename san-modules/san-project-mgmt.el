;;; san-project-mgmt.el --- Subdivided Context Isolation & Agenda Engine -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages the task prioritization, tracking, and agenda construction engine.
;; It links Org-mode's task subsystem directly into your isolated PARA workflow, mapping
;; separate todo ledgers for PhD, Startup, Personal, Sandbox, and Inbox vectors.
;;
;; Keybindings:
;; C-c a -> Launch the master Org-Agenda choice view matrix.
;; C-c f R -> Inside Dired, refile selected files directly to a PARA Resource area.

;;; Code:

(require 'org)
(require 'org-agenda)
(require 'san-paths)

;;; Unified Domain Target Registries
;; ---------------------------------------------------------------------
;; Resolves absolute path definitions dynamically against the cross-platform variable
;; foundations established in `san-paths.el` to preserve cross-system compatibility.

(defvar san-inbox-agenda-file    (expand-file-name "inbox.org" san-inbox-dir)
  "Absolute file path to the universal catchment todo ledger.")

(defvar san-personal-agenda-file (expand-file-name "personal-todo.org" san-personal-dir)
  "Absolute file path to the personal life and health todo ledger.")

(defvar san-phd-agenda-file      (expand-file-name "phd-todo.org" san-phd-dir)
  "Absolute file path to the doctoral academic research todo ledger.")

(defvar san-iterrate-agenda-file (expand-file-name "iterrate-todo.org" san-startup-dir)
  "Absolute file path to the EdTech startup operational todo ledger.")

(defvar san-sandbox-agenda-file  (expand-file-name "sandbox-todo.org" san-sandbox-dir)
  "Absolute file path to the script playground and automation todo ledger.")

;;; Core Org-Mode Task Handling Configuration
;; ---------------------------------------------------------------------
;; Specifies global tracking mechanics, custom execution keywords, and hierarchical
;; statistics tracking properties across all processed headers.

(use-package org
  :ensure nil                             ; Core built-in component
  :custom
  ;; Define core development state transitions and single-key shortcut overrides
  (org-todo-keywords '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "|" "DONE(d)" "CANC(c)")))
  (org-provide-todo-statistics t)         ; Compute completed sub-task fractions in parent entries
  (org-hierarchical-todo-statistics nil)  ; Aggregate sub-tasks recursively down the full structural tree
  
  ;; Configure rapid heading refiling parameters across active file boundaries
  (org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 'file)     ; Present refile layouts as flat structured paths
  (org-outline-path-complete-in-steps nil)) ; Complete target locations in a single minibuffer prompt

;;; Org-Agenda Workspace & Context Isolation Matrix
;; ---------------------------------------------------------------------
;; Constructs custom agenda display commands. It leverages a dynamic backtick
;; configuration string wrapper to evaluate file pointers on execution, enforcing
;; strict context isolation when context switching between workspaces.

(use-package org-agenda
  :ensure nil                             ; Core built-in component
  :custom
  ;; The primary pool of active todo tracking files evaluated by the global agenda engine
  (org-agenda-files
   (list san-inbox-agenda-file
         san-phd-agenda-file
         san-iterrate-agenda-file
         san-personal-agenda-file
         san-sandbox-agenda-file))

  ;; Custom focus view structures. Emojis match the uniform visual taxonomy.
  (org-agenda-custom-commands
   `(("o" "📥 Master Holistic Review"
      ((agenda "" ((org-agenda-span 7))) (alltodo "")))
     
     ("p" "🎓 PhD Academic Focus View"
      ((tags-todo "research" ((org-agenda-overriding-header "Substantive Academic Work")))
       (tags-todo "admin" ((org-agenda-overriding-header "Administrative Logistics & Correspondence")))
       (agenda "" ((org-agenda-span 1) (org-agenda-overriding-header "Daily Timeline"))))
      ((org-agenda-files (,san-phd-agenda-file))))
     
     ("s" "🚀 Iterrate Startup Context View"
      ((agenda "" ((org-agenda-span 1))) (alltodo ""))
      ((org-agenda-files (,san-iterrate-agenda-file))))
     
     ("l" "🌱 Personal Life Focus View"
      ((tags-todo "health" ((org-agenda-overriding-header "Physical Health, Nutrition & Energy Metrics")))
       (tags-todo "life" ((org-agenda-overriding-header "Daily Life Logistics & Projects")))
       (agenda "" ((org-agenda-span 1) (org-agenda-overriding-header "Personal Schedule"))))
      ((org-agenda-files (,san-personal-agenda-file)))))))

(keymap-global-set "C-c a" #'org-agenda)

;;; Dired Asset Refiling Engine (Automated PARA Filing)
;; ---------------------------------------------------------------------
;; Custom asset-refiling framework. Interrogates marked files inside a Dired view
;; and moves them instantly into a designated target domain's relative `Resources/` folder,
;; keeping cross-platform storage synchronized and clean.

(defvar san-resource-folder-alist nil
  "Association list mapping human-readable PARA areas to their specific Resource folders.")

(setq san-resource-folder-alist
      `(("🌱 Personal Resources" . ,(expand-file-name "Resources/" san-personal-dir))
        ("🎓 PhD Resources"      . ,(expand-file-name "Resources/" san-phd-dir))
        ("🚀 Startup Resources" . ,(expand-file-name "Resources/" san-startup-dir))
        ("🧪 Sandbox Resources"  . ,(expand-file-name "Resources/" san-sandbox-dir))))

(defun san/dired-refile-to-resource ()
  "Refile marked files instantly into a chosen PARA Resource vault destination."
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
        
        ;; Defensive verification step: Safely generate the destination directory if missing
        (unless (file-directory-p target-dir)
          (make-directory target-dir t))
        
        ;; Relocate files sequentially
        (dolist (file files)
          (let* ((short-name (file-name-nondirectory file))
                 (destination (expand-file-name short-name target-dir)))
	    (condition-case err
		(rename-file file destination)
	      (file-already-exists
	       (if (yes-or-no-p (format "File %s exists. Overwrite? " 
					(file-name-nondirectory destination)))
		   (rename-file file destination t)
		 (message "Skipped: %s" (file-name-nondirectory file)))))))
	
        (revert-buffer)
        (message "Successfully refiled %d file(s) -> %s" count chosen-key)))))

(with-eval-after-load 'dired
  (keymap-set dired-mode-map "C-c f R" #'san/dired-refile-to-resource))

(provide 'san-project-mgmt)
;;; san-project-mgmt.el ends here

;;; san-project-mgmt.el --- Subdivided Context Isolation & Agenda Engine -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages the task prioritization, tracking, and agenda construction engine[cite: 1, 2].
;; It links Org-mode's task subsystem directly into your isolated PARA workflow, mapping
;; separate todo ledgers for PhD, Startup, Personal, Sandbox, and Inbox vectors[cite: 1, 2].
;;
;; Keybindings:
;; C-c a -> Launch the master Org-Agenda choice view matrix[cite: 1, 2].
;; C-c f R -> Inside Dired, refile selected files directly to a PARA Resource area[cite: 1, 2].

;;; Code:

(require 'org)
(require 'org-agenda)
(require 'san-paths)

;;; Unified Domain Target Registries
;; ---------------------------------------------------------------------
;; Resolves absolute path definitions dynamically against the cross-platform variable
;; foundations established in `san-paths.el` to preserve cross-system compatibility[cite: 1, 2].

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
;; statistics tracking properties across all processed headers[cite: 1, 2].

(use-package org
  :ensure nil                             ; Core built-in component
  :custom
  ;; Define core development state transitions and single-key shortcut overrides[cite: 1, 2]
  (org-todo-keywords '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "|" "DONE(d)" "CANC(c)")))
  (org-provide-todo-statistics t)         ; Compute completed sub-task fractions in parent entries[cite: 1, 2]
  (org-hierarchical-todo-statistics nil)  ; Aggregate sub-tasks recursively down the full structural tree[cite: 1, 2]
  
  ;; Configure rapid heading refiling parameters across active file boundaries[cite: 1, 2]
  (org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 'file)     ; Present refile layouts as flat structured paths[cite: 1, 2]
  (org-outline-path-complete-in-steps nil)) ; Complete target locations in a single minibuffer prompt[cite: 1, 2]

;;; Org-Agenda Workspace & Context Isolation Matrix
;; ---------------------------------------------------------------------
;; Constructs custom agenda display commands[cite: 1, 2]. It leverages a dynamic backtick
;; configuration string wrapper to evaluate file pointers on execution, enforcing
;; strict context isolation when context switching between workspaces[cite: 1, 2].

(use-package org-agenda
  :ensure nil                             ; Core built-in component
  :custom
  ;; The primary pool of active todo tracking files evaluated by the global agenda engine[cite: 1, 2]
  (org-agenda-files
   (list san-inbox-agenda-file
         san-phd-agenda-file
         san-iterrate-agenda-file
         san-personal-agenda-file
         san-sandbox-agenda-file))

  ;; Custom focus view structures. Emojis match the uniform visual taxonomy[cite: 1, 2].
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

(keymap-global-set "C-c a" #'org-agenda)[cite: 1, 2]

;;; Dired Asset Refiling Engine (Automated PARA Filing)
;; ---------------------------------------------------------------------
;; Custom asset-refiling framework[cite: 1, 2]. Interrogates marked files inside a Dired view
;; and moves them instantly into a designated target domain's relative `Resources/` folder,
;; keeping cross-platform storage synchronized and clean[cite: 1, 2].

(defvar san-resource-folder-alist nil
  "Association list mapping human-readable PARA areas to their specific Resource folders.")[cite: 1, 2]

(setq san-resource-folder-alist
      `(("🌱 Personal Resources" . ,(expand-file-name "Resources/" san-personal-dir))
        ("🎓 PhD Resources"      . ,(expand-file-name "Resources/" san-phd-dir))
        ("🚀 Startup Resources" . ,(expand-file-name "Resources/" san-startup-dir))
        ("🧪 Sandbox Resources"  . ,(expand-file-name "Resources/" san-sandbox-dir))))

(defun san/dired-refile-to-resource ()
  "Refile marked files instantly into a chosen PARA Resource vault destination[cite: 1, 2]."
  (interactive)
  (unless (derived-mode-p 'dired-mode)[cite: 1, 2]
    (user-error "Not in a Dired or Dirvish buffer"))[cite: 1, 2]
  
  (let* ((files (dired-get-marked-files))[cite: 1, 2]
         (count (length files)))[cite: 1, 2]
    (if (null files)[cite: 1, 2]
        (message "No files found to refile.")[cite: 1, 2]
      (let* ((prompt (if (= count 1)[cite: 1, 2]
                         (format "Refile '%s' to: " (file-name-nondirectory (car files)))[cite: 1, 2]
                       (format "Refile %d marked files to: " count)))[cite: 1, 2]
             (chosen-key (completing-read prompt[cite: 1, 2]
                                          (mapcar #'car san-resource-folder-alist)[cite: 1, 2]
                                          nil t))[cite: 1, 2]
             (target-dir (cdr (assoc chosen-key san-resource-folder-alist))))[cite: 1, 2]
        
        ;; Defensive verification step: Safely generate the destination directory if missing[cite: 1, 2]
        (unless (file-directory-p target-dir)[cite: 1, 2]
          (make-directory target-dir t))[cite: 1, 2]
        
        ;; Relocate files sequentially[cite: 1, 2]
        (dolist (file files)[cite: 1, 2]
          (let* ((short-name (file-name-nondirectory file))[cite: 1, 2]
                 (destination (expand-file-name short-name target-dir)))[cite: 1, 2]
            (rename-file file destination 1))) ; 1 breaks file locks by forcing an overwrite confirmation if a match occurs[cite: 1, 2]
        
        (revert-buffer)[cite: 1, 2]
        (message "Successfully refiled %d file(s) -> %s" count chosen-key)))))[cite: 1, 2]

(with-eval-after-load 'dired[cite: 1, 2]
  (keymap-set dired-mode-map "C-c f R" #'san/dired-refile-to-resource))[cite: 1, 2]

(provide 'san-project-mgmt)
;;; san-project-mgmt.el ends here

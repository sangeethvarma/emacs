;;; san-org-capture.el --- Streamlined Context-Aware Capture Templates -*- lexical-binding: t -*-


;;; Commentary:
;; This module manages the central intake funnel for ideas, tasks, notes, and web logs.
;; It hooks into `org-capture` and builds out target templates for every operational
;; boundary defined in your PARA structure (PhD, Startup, Personal, Sandbox, Inbox).
;;
;; Keybindings:
;; C-c c -> Triggers the master capture intercept selection buffer.

;;; Code:

(require 'org-capture)

;; =============================================================================
;; 1. Global Intercept Keybinding Configuration
;; =============================================================================
;; Replaces the legacy `global-set-key` command with Emacs 29+ bytecode optimizations.
(keymap-global-set "C-c c" #'org-capture)

;; =============================================================================
;; 2. Automated PARA Intake Template Matrix
;; =============================================================================
;; Evaluated using a backtick structure so that platform-specific directory vectors 
;; from `san-paths.el` resolve cleanly to absolute file locations on initial execution.

(setq org-capture-templates
      `(
        ;; ---------------------------------------------------------------------
        ;; 🎓 Area 2: PhD Doctoral Research Tasks & Logistics
        ;; ---------------------------------------------------------------------
        ("r" "PhD Research Task" entry
         (file ,(expand-file-name "phd-todo.org" san-phd-dir))
         "* TODO %^{Academic Reading/Writing Task} :research:\n%U\n%?" 
         :empty-lines 1)
        
        ("a" "PhD Administrative Chores" entry
         (file ,(expand-file-name "phd-todo.org" san-phd-dir))
         "* TODO %^{Admin/Email Chore} :admin:\n%U\n%?" 
         :empty-lines 1)

        ;; ---------------------------------------------------------------------
        ;; 🚀 Area 3: Iterrate EdTech Startup Action Items & Vaults
        ;; ---------------------------------------------------------------------
        ("s" "Startup Idea / Task" entry
         (file ,(expand-file-name "iterrate-todo.org" san-startup-dir))
         "* TODO %^{Startup Action}\n%U\n%?" 
         :empty-lines 1)
         
        ("i" "Idea Dock (Startup Notes)" entry
         (file ,(expand-file-name "notes/idea-dock.org" san-startup-dir))
         "* IDEA %^{Idea Title}\n%U\n%?\n" 
         :empty-lines 1)

        ;; ---------------------------------------------------------------------
        ;; 💪 Area 1: Personal Life Maintenance, Metrics, & Health
        ;; ---------------------------------------------------------------------
        ("h" "Health & Fitness tasks" entry
         (file ,(expand-file-name "personal-todo.org" san-personal-dir))
         "* TODO %^{Fitness/Health Task/Metric/Routine} :health:\n%U\n%?" 
         :empty-lines 1)

        ("l" "Life Maintenance Item" entry
         (file ,(expand-file-name "personal-todo.org" san-personal-dir))
         "* TODO %^{Logistical/Finance Task/Chore} :life:\n%U\n%?" 
         :empty-lines 1)

        ;; ---------------------------------------------------------------------
        ;; 🧪 Sandbox Area: Hobby Scripts, Snippets, & Automation Notes
        ;; ---------------------------------------------------------------------
        ("j" "Sandbox / Hobby Script" entry
         (file ,(expand-file-name "sandbox-todo.org" san-sandbox-dir))
         "* TODO %^{Experiment/Script Idea}\n%U\n%?" 
         :empty-lines 1)

        ;; ---------------------------------------------------------------------
        ;; 📥 Inbox Funnel: Fleet Thoughts & Web Capture Streams
        ;; ---------------------------------------------------------------------
        ("x" "Universal Inbox Funnel" entry
         (file ,(expand-file-name "inbox.org" san-inbox-dir))
         "* TODO %^{Fleeting Thought}\n%U\n%?" 
         :empty-lines 1)

        ("w" "Web Capture" entry
         (file ,(expand-file-name "-grasp__inbox.org" san-inbox-dir))
         "* %a\n%U\n#+BEGIN_QUOTE\n%i\n#+END_QUOTE\n%?" 
         :empty-lines 1)))

(provide 'san-org-capture)
;;; san-org-capture.el ends here

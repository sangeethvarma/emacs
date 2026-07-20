;;; san-project-mgmt.el --- Task & Project Management System -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages task prioritization, tracking, and agenda construction.
;; It links Org-mode's task subsystem directly into the PARA workflow.

;;; Code:

(require 'org)
(require 'org-agenda)
(unless (require 'san-paths nil t)
  (error "san-paths module not found"))

;;; Unified Task File Registries
;; ---------------------------------------------------------------------
(defvar san-inbox-agenda-file    (expand-file-name "inbox.org" san-inbox-dir)
  "Path to the universal catchment task file.")

(defvar san-personal-agenda-file (expand-file-name "personal-todo.org" san-personal-dir)
  "Path to the personal life and health task file.")

(defvar san-phd-agenda-file      (expand-file-name "phd-todo.org" san-phd-dir)
  "Path to the doctoral academic research task file.")

(defvar san-iterrate-agenda-file (expand-file-name "iterrate-todo.org" san-startup-dir)
  "Path to the startup operational task file.")

(defvar san-sandbox-agenda-file  (expand-file-name "sandbox-todo.org" san-sandbox-dir)
  "Path to the script playground and automation task file.")

(defconst san-agenda-files-list
  (list san-inbox-agenda-file
        san-phd-agenda-file
        san-iterrate-agenda-file
        san-personal-agenda-file
        san-sandbox-agenda-file)
  "List of all agenda files for the PARA system.")

;; Initialize agenda files globally
(setq org-agenda-files san-agenda-files-list)

;;; Enhanced Org-Super-Agenda Configuration
;; ---------------------------------------------------------------------
(use-package org-super-agenda
  :ensure t
  :after org-agenda
  :config
  (org-super-agenda-mode 1)
  (setq org-super-agenda-groups
        '((:name "🔥 Critical Priority"
           :priority "A")
          (:name "⏰ Due Soon"
           :deadline past
           :deadline today
           :deadline future)
          (:name "🏃 In Progress"
           :todo "STRT")
          (:name "⏳ Blocked"
           :todo "WAIT")
          (:name "📅 Recently Added" 
           :tag "recent")
          (:name "🎓 Academic Work"
           :tag "research"
           :tag "academic")
          (:name "🚀 Startup Projects"
           :tag "startup"
           :tag "business")
          (:name "🌱 Personal"
           :tag "health"
           :tag "life"
           :tag "personal")
          (:discard (:tag ("someday" "maybe"))))))

;;; Org-Mode Task System Configuration
;; ---------------------------------------------------------------------
(use-package org
  :ensure nil
  :custom
  (org-todo-keywords 
   '((sequence "TODO(t)" "STRT(s)" "WAIT(w@/!)" "|" "DONE(d!)" "CANC(c@)")))
  (org-todo-state-tags-triggers
   '(("CANC" ("CANCELLED" . t))
     ("DONE" ("CANCELLED" . nil))))
  (org-provide-todo-statistics t)
  (org-hierarchical-todo-statistics nil)
  (org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  (org-auto-archive-untagged-entries t))

;;; Agenda View Configuration
;; ---------------------------------------------------------------------
(use-package org-agenda
  :ensure nil
  :commands (org-agenda)
  :config
  ;; Custom agenda view definitions
  (setq org-agenda-custom-commands
        '((" " "🎯 Daily Dashboard"
           ((agenda "" ((org-agenda-span 1)
                        (org-agenda-start-on-weekday nil)
                        (org-agenda-show-all-dates nil)
                        (org-agenda-overriding-header "📅 Today's Schedule")))
            (todo "STRT" ((org-agenda-overriding-header "🔥 In Progress")))
            (tags-todo "WAIT" ((org-agenda-overriding-header "⏳ Waiting For")))
            (tags-todo "+PRIORITY=\"A\"" ((org-agenda-overriding-header "🔴 High Priority")))
            (tags "inbox" ((org-agenda-overriding-header "📥 Inbox Items")))))
          
          ("n" "🎯 Next Actions" 
           ((todo "TODO" ((org-agenda-overriding-header "📋 Ready to Start")))
            (todo "STRT" ((org-agenda-overriding-header "🏃 In Progress")))
            (tags-todo "WAIT" ((org-agenda-overriding-header "⏳ Blocked/Waiting")))
            (tags "+SCHEDULED<today" ((org-agenda-overriding-header "⏰ Scheduled Today")))))
          
          ("w" "💼 Work Context"
           ((tags-todo "research|admin" 
                      ((org-agenda-overriding-header "🎓 PhD Work")))
            (tags-todo "startup" 
                      ((org-agenda-overriding-header "🚀 Startup Tasks")))
            (todo "WAIT" ((org-agenda-overriding-header "⏳ Awaiting Response")))))
          
          ("l" "🌱 Personal Context"
           ((tags-todo "health" 
                      ((org-agenda-overriding-header "💪 Health & Fitness")))
            (tags-todo "life" 
                      ((org-agenda-overriding-header "🏠 Life Management")))
            (agenda "" ((org-agenda-span 3)
                       (org-agenda-start-on-weekday nil)
                       (org-agenda-overriding-header "📅 Personal Schedule")))))
          
          ("s" "📊 Status Overview"
           ((todo "STRT" ((org-agenda-overriding-header "🏃 Currently Working On")))
            (tags-todo "WAIT" ((org-agenda-overriding-header "⏳ Stuck/Waiting")))
            (todo "TODO" ((org-agenda-overriding-header "📋 Backlog")))
            (tags "+TIMESTAMP_IA>today-7" 
                  ((org-agenda-overriding-header "📆 Recently Added"))))
           ((org-agenda-sorting-strategy '(todo-state-up priority-down))))
          
          ;; Super Dashboard view
          ("S" "🔍 Super Dashboard"
           ((agenda "" ((org-agenda-span 1)))
            (alltodo "" ((org-super-agenda-groups org-super-agenda-groups)))))))

  ;; Agenda display configuration
  (setq org-agenda-block-separator ?─)
  (setq org-agenda-time-grid '((daily today require-timed) 
                              (800 1000 1200 1400 1600 1800 2000)
                              "......" 
                              "----------------"))
  (setq org-agenda-current-time-string "───────────── Now ─────────────")
  (setq org-agenda-show-current-time-in-grid t)
  (setq org-agenda-span 'week)
  (setq org-agenda-start-on-weekday 1)
  (setq org-agenda-sorting-strategy '(todo-state-down priority-down time-up))
  (setq org-agenda-window-setup 'current-window)
  (setq org-agenda-sticky t)
  (setq org-agenda-start-with-clockreport-mode t)
  (setq org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3 :fileskip0 t)))

;;; Workflow Enhancement Functions
;; ---------------------------------------------------------------------
(defun san/agenda-mark-and-refile ()
  "Mark current agenda item and refile immediately."
  (interactive)
  (org-agenda-todo "STRT")
  (org-agenda-refile))

(defun san/agenda-mark-done-and-archive ()
  "Mark current agenda item done and archive it."
  (interactive)
  (org-agenda-todo "DONE")
  (org-agenda-archive-default-with-confirmation))

(defun san/agenda-snooze-item ()
  "Snooze current agenda item for 1 day."
  (interactive)
  (org-agenda-schedule nil "+1d"))

;; Enhanced workflow keybindings
(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "C-c r") 'san/agenda-mark-and-refile)
  (define-key org-agenda-mode-map (kbd "C-c d") 'san/agenda-mark-done-and-archive)
  (define-key org-agenda-mode-map (kbd "C-c z") 'san/agenda-snooze-item))

;; Dired Resource Refiling System
;; ---------------------------------------------------------------------
(defvar san-resource-folder-alist nil
  "Association list mapping PARA areas to their Resource folders.")

(setq san-resource-folder-alist
      `(("🌱 Personal Resources" . ,(expand-file-name "Resources/" san-personal-dir))
        ("🎓 PhD Resources"      . ,(expand-file-name "Resources/" san-phd-dir))
        ("🚀 Startup Resources"  . ,(expand-file-name "Resources/" san-startup-dir))
        ("🧪 Sandbox Resources"  . ,(expand-file-name "Resources/" san-sandbox-dir))))

(defun san/dired-refile-to-resource ()
  "Refile marked files into a chosen PARA Resource folder."
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (user-error "Not in a Dired buffer"))
  
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
        
        ;; Create destination directory if needed
        (unless (file-directory-p target-dir)
          (message "Creating resource directory: %s" target-dir)
          (make-directory target-dir t))
        
        ;; Move files to target directory
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
        (message "Refiled %d file(s) to %s" count chosen-key)))))

;; Dired integration
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c f R") #'san/dired-refile-to-resource))

;; Global keybinding
(keymap-global-set "C-c a" #'org-agenda)

(provide 'san-project-mgmt)
;;; san-project-mgmt.el ends here

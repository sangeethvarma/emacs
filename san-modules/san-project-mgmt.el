;;; san-project-mgmt.el --- Org-agenda task system for the PARA areas -*- lexical-binding: t -*-

;;; Commentary:
;; TODO workflow, agenda dashboards, refiling, and auto-archiving on
;; completion.

;;; Code:

(require 'org)
(require 'org-agenda)
(require 'san-paths)

;;; Agenda files
(defvar san-inbox-agenda-file    (expand-file-name "inbox.org" san-inbox-dir))
(defvar san-personal-agenda-file (expand-file-name "personal-todo.org" san-personal-dir))
(defvar san-phd-agenda-file      (expand-file-name "phd-todo.org" san-phd-dir))
(defvar san-iterrate-agenda-file (expand-file-name "iterrate-todo.org" san-startup-dir))
(defvar san-sandbox-agenda-file  (expand-file-name "sandbox-todo.org" san-sandbox-dir))

(defconst san-agenda-files-list
  (list san-inbox-agenda-file san-phd-agenda-file san-iterrate-agenda-file
        san-personal-agenda-file san-sandbox-agenda-file)
  "All PARA area task files.")

(setq org-agenda-files (seq-filter #'file-exists-p san-agenda-files-list))

;;; Org-Super-Agenda
(use-package org-super-agenda
  :ensure t
  :after org-agenda
  :init
  (org-super-agenda-mode 1)
  :custom
  (org-super-agenda-groups
   '((:discard (:tag ("someday" "maybe")))
     (:name "🔥 Critical Priority" :priority "A")
     (:name "⏰ Due Soon" :deadline past :deadline today :deadline future)
     (:name "🏃 In Progress" :todo "STRT")
     (:name "⏳ Blocked" :todo "WAIT")
     (:name "🎓 Academic Work" :tag "research" :tag "academic")
     (:name "🚀 Startup Projects" :tag "startup" :tag "business")
     (:name "🌱 Personal" :tag "health" :tag "life" :tag "personal"))))

;;; Org task system
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
  (org-outline-path-complete-in-steps nil))

;; A "project" is a headline tagged :project: with TODO/STRT children;
;; one with none is "stuck" and surfaced in the dashboard below.
(setq org-stuck-projects '("+project-someday-maybe" ("TODO" "STRT") nil ""))

;;; Agenda dashboards
(use-package org-agenda
  :ensure nil
  :commands (org-agenda)
  :custom
  (org-agenda-custom-commands
   '((" " "🎯 Daily Dashboard"
      ((agenda "" ((org-agenda-span 1)
                   (org-agenda-start-on-weekday nil)
                   (org-agenda-show-all-dates nil)
                   (org-agenda-overriding-header "📅 Today's Schedule")))
       (stuck "" ((org-agenda-overriding-header "🚧 Stuck Projects")))
       (todo "STRT" ((org-agenda-overriding-header "🔥 In Progress")))
       (todo "WAIT" ((org-agenda-overriding-header "⏳ Waiting For")))
       (tags-todo "+PRIORITY=\"A\"" ((org-agenda-overriding-header "🔴 High Priority")))
       (todo "TODO" ((org-agenda-overriding-header "📥 Inbox Items")
                     (org-agenda-files (list san-inbox-agenda-file)))))
      ((org-super-agenda-groups nil)))

     ("p" "📁 Active Projects"
      ((tags "+project-someday-maybe" ((org-agenda-overriding-header "📁 All Active Projects"))))
      ((org-super-agenda-groups nil)))

     ("R" "🔎 Weekly Review"
      ((agenda "" ((org-agenda-span 14)
                   (org-agenda-start-on-weekday nil)
                   (org-agenda-overriding-header "📅 Next 2 Weeks (Deadlines & Scheduled)")))
       (stuck "" ((org-agenda-overriding-header "🚧 Stuck Projects")))
       (todo "TODO" ((org-agenda-overriding-header "📥 Unprocessed Inbox")
                     (org-agenda-files (list san-inbox-agenda-file))))
       (tags "+TIMESTAMP_IA<today-14" ((org-agenda-overriding-header "🧪 Sandbox: Needs Triage (14+ days untouched)")
                                        (org-agenda-files (list san-sandbox-agenda-file)))))
      ((org-super-agenda-groups nil)))

     ("n" "🎯 Next Actions"
      ((todo "TODO" ((org-agenda-overriding-header "📋 Ready to Start")))
       (todo "STRT" ((org-agenda-overriding-header "🏃 In Progress")))
       (todo "WAIT" ((org-agenda-overriding-header "⏳ Blocked/Waiting")))
       (tags "+SCHEDULED<today" ((org-agenda-overriding-header "⏰ Scheduled Today"))))
      ((org-super-agenda-groups nil)))

     ("w" "💼 Work Context"
      ((tags-todo "research|admin" ((org-agenda-overriding-header "🎓 PhD Work")))
       (tags-todo "startup" ((org-agenda-overriding-header "🚀 Startup Tasks")))
       (todo "WAIT" ((org-agenda-overriding-header "⏳ Awaiting Response"))))
      ((org-super-agenda-groups nil)))

     ("l" "🌱 Personal Context"
      ((tags-todo "health" ((org-agenda-overriding-header "💪 Health & Fitness")))
       (tags-todo "life" ((org-agenda-overriding-header "🏠 Life Management")))
       (agenda "" ((org-agenda-span 3)
                   (org-agenda-start-on-weekday nil)
                   (org-agenda-overriding-header "📅 Personal Schedule"))))
      ((org-super-agenda-groups nil)))

     ("s" "📊 Status Overview"
      ((todo "STRT" ((org-agenda-overriding-header "🏃 Currently Working On")))
       (todo "WAIT" ((org-agenda-overriding-header "⏳ Stuck/Waiting")))
       (todo "TODO" ((org-agenda-overriding-header "📋 Backlog")))
       (tags "+TIMESTAMP_IA>today-7" ((org-agenda-overriding-header "📆 Recently Added"))))
      ((org-agenda-sorting-strategy '(todo-state-up priority-down))
       (org-super-agenda-groups nil)))

     ("S" "🔍 Super Dashboard"
      ((agenda "" ((org-agenda-span 1)))
       (alltodo "" ((org-super-agenda-groups org-super-agenda-groups)))))))
  (org-agenda-block-separator ?─)
  (org-agenda-time-grid '((daily today require-timed)
                          (800 1000 1200 1400 1600 1800 2000)
                          "......" "----------------"))
  (org-agenda-current-time-string "───────────── Now ─────────────")
  (org-agenda-show-current-time-in-grid t)
  (org-agenda-span 'week)
  (org-agenda-start-on-weekday 1)
  (org-agenda-sorting-strategy '(todo-state-down priority-down time-up))
  (org-agenda-window-setup 'current-window)
  (org-agenda-sticky t)
  (org-agenda-start-with-clockreport-mode t)
  (org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3 :fileskip0 t)))

;;; Agenda workflow commands
(defun san/agenda-mark-and-refile ()
  "Mark the item at point STRT and refile it."
  (interactive)
  (org-agenda-todo "STRT")
  (org-agenda-refile))

(defun san/agenda-mark-done-and-archive ()
  "Mark the item at point DONE and archive it."
  (interactive)
  (org-agenda-todo "DONE")
  (org-agenda-archive-default-with-confirmation))

(defun san/agenda-snooze-item ()
  "Reschedule the item at point one day forward."
  (interactive)
  (org-agenda-schedule nil "+1d"))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "C-c r") #'san/agenda-mark-and-refile)
  (define-key org-agenda-mode-map (kbd "C-c d") #'san/agenda-mark-done-and-archive)
  (define-key org-agenda-mode-map (kbd "C-c z") #'san/agenda-snooze-item))

;;; Auto-archive on completion
(defun san/auto-archive-on-done ()
  "Archive the current subtree when it's marked DONE or CANC."
  (when (member (org-get-todo-state) '("DONE" "CANC"))
    (org-archive-subtree)
    (goto-char (org-log-beginning))))

(add-hook 'org-after-todo-state-change-hook #'san/auto-archive-on-done)

;;; Dired -> PARA Resources refiling
(defvar san-resource-folder-alist
  `(("🌱 Personal Resources" . ,(expand-file-name "Resources/" san-personal-dir))
    ("🎓 PhD Resources"      . ,(expand-file-name "Resources/" san-phd-dir))
    ("🚀 Startup Resources"  . ,(expand-file-name "Resources/" san-startup-dir))
    ("🧪 Sandbox Resources"  . ,(expand-file-name "Resources/" san-sandbox-dir)))
  "PARA area name -> its Resources/ folder.")

(defun san/dired-refile-to-resource ()
  "Move the marked files in this Dired buffer into a chosen PARA Resources folder."
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (user-error "Not in a Dired buffer"))
  (let* ((files (dired-get-marked-files))
         (count (length files)))
    (when (null files)
      (user-error "No files marked"))
    (let* ((prompt (if (= count 1)
                        (format "Refile '%s' to: " (file-name-nondirectory (car files)))
                      (format "Refile %d marked files to: " count)))
           (chosen-key (completing-read prompt (mapcar #'car san-resource-folder-alist) nil t))
           (target-dir (cdr (assoc chosen-key san-resource-folder-alist))))
      (unless (file-directory-p target-dir)
        (make-directory target-dir t))
      (dolist (file files)
        (let ((destination (expand-file-name (file-name-nondirectory file) target-dir)))
          (condition-case nil
              (rename-file file destination)
            (file-already-exists
             (if (yes-or-no-p (format "%s exists. Overwrite? " (file-name-nondirectory destination)))
                 (rename-file file destination t)
               (message "Skipped: %s" (file-name-nondirectory file)))))))
      (revert-buffer)
      (message "Refiled %d file(s) to %s" count chosen-key))))

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c f R") #'san/dired-refile-to-resource))

(keymap-global-set "C-c a" #'org-agenda)

(provide 'san-project-mgmt)
;;; san-project-mgmt.el ends here

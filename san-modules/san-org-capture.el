;;; san-org-capture.el --- PARA capture templates -*- lexical-binding: t -*-

;;; Commentary:
;; org-capture templates for each PARA area. C-c c to trigger.

;;; Code:

(require 'org-capture)
(require 'san-paths)
(require 'san-project-mgmt)   ; for san-agenda-files-list

(keymap-global-set "C-c c" #'org-capture)

(defvar san-review-log-file (expand-file-name "review-log.org" san-vault-root)
  "Weekly review checklist entries, across all PARA areas.")

(defvar san-project-area-alist
  `(("PhD"      . (,(expand-file-name "phd-todo.org" san-phd-dir) "research"))
    ("Startup"  . (,(expand-file-name "iterrate-todo.org" san-startup-dir) "startup"))
    ("Personal" . (,(expand-file-name "personal-todo.org" san-personal-dir) "life"))
    ("Sandbox"  . (,(expand-file-name "sandbox-todo.org" san-sandbox-dir) "sandbox")))
  "PARA area -> (todo-file default-tag), for the cross-area \"P\" template.")

(defvar san-capture-project-tag nil
  "Area tag for the project being captured; set by `san/capture-project-target'.")

(defun san/capture-project-target ()
  "Prompt for a PARA area and jump to the end of its todo file."
  (let* ((choice (completing-read "Area: " (mapcar #'car san-project-area-alist) nil t))
         (entry (cdr (assoc choice san-project-area-alist)))
         (file (car entry)))
    (setq san-capture-project-tag (cadr entry))
    (set-buffer (org-capture-target-buffer file))
    (goto-char (point-max))))

(defvar san-capture-child-level 2
  "Heading level for the next capture; set by `san/capture-task-target'.")

(defun san/list-projects ()
  "Return an alist of (DISPLAY . (FILE . POINT)) for every :project: headline
across the PARA area files."
  (let (result)
    (dolist (file san-agenda-files-list)
      (when (file-exists-p file)
        (with-current-buffer (find-file-noselect file)
          (org-map-entries
           (lambda ()
             (push (cons (format "%s  [%s]" (org-get-heading t t t t) (file-name-nondirectory file))
                         (cons file (point)))
                   result))
           "+project"))))
    (nreverse result)))

(defun san/capture-task-target ()
  "Prompt for an existing project and position point to add a child task."
  (let* ((projects (san/list-projects))
         (choice (and projects (completing-read "Add task to project: " (mapcar #'car projects) nil t))))
    (unless projects
      (user-error "No projects found -- capture one with C-c c P first"))
    (pcase-let ((`(,file . ,pos) (cdr (assoc choice projects))))
      (set-buffer (org-capture-target-buffer file))
      (goto-char pos)
      (setq san-capture-child-level (1+ (org-outline-level)))
      (org-end-of-subtree t t))))

(setq org-capture-templates
      `(("P" "📌 New Project (any area)" entry
         (function san/capture-project-target)
         "* %^{Project outcome} :project:%(identity san-capture-project-tag):\nDEADLINE: %^{Target date}t\n%U\n** TODO %^{First next action}\n%?"
         :empty-lines 1)

        ("t" "✅ Add Task to Existing Project" entry
         (function san/capture-task-target)
         "%(make-string san-capture-child-level ?*) TODO %^{Task}\n%U\n%?"
         :empty-lines 1)

        ("R" "🔎 Weekly Review Log" entry
         (file ,(expand-file-name "review-log.org" san-vault-root))
         "* Weekly Review %U\n%(san/phd-notes-status-line)\n- [ ] Stuck projects addressed\n- [ ] Sandbox triaged (promote, someday, or delete)\n- [ ] Inbox cleared\n- [ ] Upcoming deadlines checked\n%?"
         :empty-lines 1)

        ("r" "🎓 PhD Research Task" entry
         (file ,(expand-file-name "phd-todo.org" san-phd-dir))
         "* TODO %^{Academic Reading/Writing Task} :research:\n%U\n%?"
         :empty-lines 1)

        ("a" "🎓 PhD Administrative Chores" entry
         (file ,(expand-file-name "phd-todo.org" san-phd-dir))
         "* TODO %^{Admin/Email Chore} :admin:\n%U\n%?"
         :empty-lines 1)

        ("s" "🚀 Startup Idea / Task" entry
         (file ,(expand-file-name "iterrate-todo.org" san-startup-dir))
         "* TODO %^{Startup Action} :startup:\n%U\n%?"
         :empty-lines 1)

        ("i" "🚀 Idea Dock (Startup Notes)" entry
         (file ,(expand-file-name "notes/idea-dock.org" san-startup-dir))
         "* IDEA %^{Idea Title} :startup:\n%U\n%?\n"
         :empty-lines 1)

        ("h" "🌱 Health & Fitness Tasks" entry
         (file ,(expand-file-name "personal-todo.org" san-personal-dir))
         "* TODO %^{Fitness/Health Task/Metric/Routine} :health:\n%U\n%?"
         :empty-lines 1)

        ("l" "🌱 Life Maintenance Item" entry
         (file ,(expand-file-name "personal-todo.org" san-personal-dir))
         "* TODO %^{Logistical/Finance Task/Chore} :life:\n%U\n%?"
         :empty-lines 1)

        ("j" "🧪 Sandbox / Hobby Script" entry
         (file ,(expand-file-name "sandbox-todo.org" san-sandbox-dir))
         "* TODO %^{Experiment/Script Idea}\n%U\n%?"
         :empty-lines 1)

        ("x" "📥 Universal Inbox Funnel" entry
         (file ,(expand-file-name "inbox.org" san-inbox-dir))
         "* TODO %^{Fleeting Thought}\n%U\n%?"
         :empty-lines 1)

        ("w" "📥 Web Capture" entry
         (file ,(expand-file-name "-grasp__inbox.org" san-inbox-dir))
         "* %a\n%U\n#+BEGIN_QUOTE\n%i\n#+END_QUOTE\n%?"
         :empty-lines 1)))

(provide 'san-org-capture)
;;; san-org-capture.el ends here

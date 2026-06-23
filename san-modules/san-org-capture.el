;;; -*- lexical-binding: t -*-
;;; san-modules/san-org-capture.el --- Streamlined Capture Templates

(require 'org-capture)
(global-set-key (kbd "C-c c") 'org-capture)

(setq org-capture-templates
      `(
        ("r" "PhD Research Task" entry
         (file ,(expand-file-name "phd-todo.org" san-phd-dir))
         "* TODO %^{Academic Reading/Writing Task} :research:\n%U\n%?" :empty-lines 1)
        
        ("a" "PhD Administrative Chores" entry
         (file ,(expand-file-name "phd-todo.org" san-phd-dir))
         "* TODO %^{Admin/Email Chore} :admin:\n%U\n%?" :empty-lines 1)

        ("s" "Startup Idea / Task" entry
         (file ,(expand-file-name "iterrate-todo.org" san-startup-dir))
         "* TODO %^{Startup Action}\n%U\n%?" :empty-lines 1)
         
        ("i" "Idea Dock (Startup Notes)" entry
         (file ,(expand-file-name "notes/idea-dock.org" san-startup-dir))
         "* IDEA %^{Idea Title}\n%U\n%?\n" :empty-lines 1)

        ;; Integrated Personal Area templates pointing to the same file with separate tags
        ("h" "Health & Fitness Target" entry
         (file ,(expand-file-name "personal-todo.org" san-personal-dir))
         "* TODO %^{Fitness Metric/Routine} :health:\n%U\n%?" :empty-lines 1)

        ("l" "Life Maintenance Item" entry
         (file ,(expand-file-name "personal-todo.org" san-personal-dir))
         "* TODO %^{Logistical/Finance Task} :life:\n%U\n%?" :empty-lines 1)

        ("j" "Sandbox / Hobby Script" entry
         (file ,(expand-file-name "sandbox-todo.org" san-sandbox-dir))
         "* TODO %^{Experiment/Script Idea}\n%U\n%?" :empty-lines 1)

        ("x" "Universal Inbox Funnel" entry
         (file ,(expand-file-name "inbox.org" san-inbox-dir))
         "* TODO %^{Fleeting Thought}\n%U\n%?" :empty-lines 1)

        ("w" "Web Capture" entry
         (file ,(expand-file-name "-grasp__inbox.org" san-inbox-dir))
         "* %a\n%U\n#+BEGIN_QUOTE\n%i\n#+END_QUOTE\n%?" :empty-lines 1)))

(provide 'san-org-capture)

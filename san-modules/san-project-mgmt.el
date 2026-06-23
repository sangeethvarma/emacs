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

(provide 'san-project-mgmt)

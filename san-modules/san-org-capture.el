;;; -*- lexical-binding: t -*-

(require 'org-capture)
(require 'denote)
(require 'org-protocol)

;; Define what the inside of the note looks like upon capture. 
;; "%?" just drops your cursor right below the front-matter so you can start typing immediately.
(setq denote-org-capture-specifiers "%?")

(global-set-key (kbd "C-c c") 'org-capture)

(setq org-capture-templates
      `(
        ;; 1. The Idea Dock (Startup/Coding ideas go to Projects)
        ("i" "Idea Dock (Startup)" entry
         (file ,(expand-file-name "Startup/notes/idea-dock.org" san-projects-dir))
         "* IDEA %^{Idea Title}\n%U\n%?\n" :empty-lines 1)

        ;; 2. Standard PhD Tasks (Academic work goes to PhD)
        ("t" "PhD Task" entry
         (file ,(expand-file-name "todo.org" san-phd-dir))
         "* TODO %^{Task}\n%U\n%?" :empty-lines 1)

        ;; 3. Universal Inbox (Random tasks go to Inbox)
        ("x" "Inbox Task" entry
         (file ,(expand-file-name "todo.org" san-inbox-dir))
         "* TODO %^{Task}\n%U\n%?" :empty-lines 1)

        ;; 4. Org-Protocol Web Capture (Fired from Windows Browser into Inbox)
        ("w" "Web Capture" entry
         (file ,(expand-file-name "-grasp__inbox.org" san-inbox-dir))
         "* %a\n%U\n#+BEGIN_QUOTE\n%i\n#+END_QUOTE\n%?" :empty-lines 1)))

(provide 'san-org-capture)

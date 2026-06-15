(require 'org-capture)
(require 'denote)

;; Define what the inside of the note looks like upon capture. 
;; "%?" just drops your cursor right below the front-matter so you can start typing immediately.
(setq denote-org-capture-specifiers "%?")

(global-set-key (kbd "C-c c") 'org-capture)

;; The Frictionless Capture Menu
(setq org-capture-templates
      `(
        ;; Define a group key "i" for "Ideas"
        ("i" "Ideas & Brainstorms")

        ;; Template: Startup Idea
        ("is" "Startup Idea" plain
         (file denote-last-path)
         #'(lambda () 
             (let ((denote-prompts '(title))
                   (denote-use-keywords '("startup" "idea")))
               (denote-org-capture)))
         :no-save t
         :immediate-finish nil
         :kill-buffer t
         :prepend t)

        ;; Template: PhD Idea
        ("ip" "PhD Idea" plain
         (file denote-last-path)
         #'(lambda () 
             (let ((denote-prompts '(title))
                   (denote-use-keywords '("phd" "idea")))
               (denote-org-capture)))
         :no-save t
         :immediate-finish nil
         :kill-buffer t
         :prepend t)

        ;; Template: Life OS Idea
        ("il" "Life OS Idea" plain
         (file denote-last-path)
         #'(lambda () 
             (let ((denote-prompts '(title))
                   (denote-use-keywords '("lifeos" "idea")))
               (denote-org-capture)))
         :no-save t
         :immediate-finish nil
         :kill-buffer t
         :prepend t)

        ;; Template: Random Idea
        ("ir" "Random Idea" plain
         (file denote-last-path)
         #'(lambda () 
             (let ((denote-prompts '(title))
                   (denote-use-keywords '("random" "idea")))
               (denote-org-capture)))
         :no-save t
         :immediate-finish nil
         :kill-buffer t
         :prepend t)

	;; TODOs
	("t" "Task / TODO" entry (file ,(expand-file-name "notes/todo.org" san-phd-dir))
         "* TODO %?\n  Captured: %U\n  Context: %a\n  %i"
         :empty-lines 1)))

(provide 'san-org-capture)

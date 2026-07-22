;;; san-completions.el --- Keyboard-Driven Completion Stack -*- lexical-binding: t -*-

;;; Code:

;;; Jinx High-Performance Spell Checker
;; ---------------------------------------------------------------------
;; Deploys the modern Jinx compiler-driven spelling overlay system. 
;; It checks words on-the-fly purely within visible viewport boundaries to prevent background 
;; I/O processing blocks over massive data logs or academic texts.
(use-package jinx
  :ensure t
  :hook ((text-mode . jinx-mode)
         (prog-mode . jinx-mode))           ; Also enable in programming modes for comments
  :commands (jinx-mode jinx-correct jinx-languages)
  :bind (("M-$" . jinx-correct)             ; Prompt minibuffer dropdown for word corrections at point
         ("C-M-$" . jinx-languages))        ; Dynamically switch or overlay multi-lingual dictionaries
  :custom
  (jinx-delay 0.5)                         ; Delay before starting spell check
  (jinx-idle-delay 1.0))                   ; Idle delay for automatic checking

;;; Vertico Vertical Minibuffer UI
(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  (vertico-resize t)
  (vertico-sort-function #'vertico-sort-history-alpha)
  :init
  (vertico-mode 1))

;; Path Traversal Cleansing Extension
(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("C-<backspace>" . vertico-directory-up)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;;; Corfu In-Buffer Autocompletion Engine
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-quit-no-match always)
  (corfu-preselect-first t)
  (corfu-on-exact-match nil)
  (corfu-cycle nil)
  (corfu-auto-commands '(self-insert-command))
  :init
  (global-corfu-mode 1))

;;; Orderless Pattern Matching Engine
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Marginalia Minibuffer Rich Annotations
(use-package marginalia
  :ensure t
  :custom
  (marginalia-align 'center)
  :init
  (marginalia-mode 1))

;; Monochrome UI Icons for Completions
(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :init
  (nerd-icons-completion-mode 1)
  :hook (marginalia-mode-hook . nerd-icons-completion-marginalia-setup))

;;; Consult Search & Navigation Utilities
(use-package consult
  :ensure t
  :bind (("M-s M-g" . consult-ripgrep)
         ("M-s M-f" . consult-find)
         ("M-s M-o" . consult-outline)
         ("M-s M-l" . consult-line)
         ("M-s M-b" . consult-buffer)
         ("C-x M-b" . consult-buffer)))

;;; Embark Context Actions Menu & Pipelines
(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

(use-package embark-consult
  :ensure t
  :after (embark consult))

;;; Meow Integration
(with-eval-after-load 'meow
  (setq meow-mode-state-list
        (append '((vertico-buffer-mode . motion)
                  (embark-collect-mode . motion)
                  (embark-export-mode  . motion)
                  (consult-preview-mode . motion))
                meow-mode-state-list))
  (add-hook 'minibuffer-setup-hook #'meow-insert-mode))

(with-eval-after-load 'embark
  (add-hook 'embark-pre-action-hook #'meow-indicator-update)
  (advice-add 'embark-act :after (lambda (&rest _) (meow-indicator-update))))

(with-eval-after-load 'corfu
  (add-hook 'corfu-mode-hook
            (lambda ()
              (if corfu-mode
                  (when (boundp 'meow-insert-xdg-workaround)
                    (setq-local meow-insert-xdg-workaround nil))
                (kill-local-variable 'meow-insert-xdg-workaround)))))


;;; WSL2 Ripgrep Optimization
(with-eval-after-load 'consult
  (setq consult-async-input-debounce 0.8
        consult-async-input-throttle 1.2
        consult-async-min-input 3)
  ;; More restrictive file exclusions for WSL
  (when (san/wsl-p)
    (setq consult-ripgrep-args
          (concat "rg --null --line-buffered --color=never --max-columns=300 "
                  "--path-separator / --smart-case --no-heading --with-filename "
                  "--line-number --no-follow --max-filesize=500K "
                  "--glob '!*/.git/*' "
                  "--glob '!*/node_modules/*' "
                  "--glob '!*/__pycache__/*' "
                  "--glob '!*/Archive/*' "
                  "--glob '!*/elpa/*' "
                  "--glob '!*.pdf' "
                  "--glob '!*.png' "
                  "--glob '!*.jpg' "
                  "--glob '!*.jpeg' "
                  "--glob '!*.svg' "
                  "--glob '!*.ico'"))))


(provide 'san-completions)
;;; san-completions.el ends here

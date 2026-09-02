;;; san-completions.el --- Completion stack -*- lexical-binding: t -*-

;;; Commentary:
;; Vertico/corfu/orderless/marginalia/consult/embark, plus the bits that
;; make them play nicely with Meow.

;;; Code:

(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  (vertico-resize t)
  (vertico-sort-function #'vertico-sort-history-alpha)
  :init
  (vertico-mode 1))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("C-<backspace>" . vertico-directory-up)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-quit-no-match t)
  (corfu-preselect-first t)
  (corfu-on-exact-match nil)
  (corfu-cycle nil)
  (corfu-auto-commands '(self-insert-command))
  :init
  (global-corfu-mode 1)
  :config
  ;; Some major modes (e.g. markdown-mode) add ispell-completion-at-point
  ;; to their own buffer-local completion-at-point-functions regardless of
  ;; the global default, and it errors out on this system (no plain word
  ;; list at the default ispell-alternate-dictionary location) -- strip it
  ;; per-buffer, after that buffer's mode setup has already run.
  (add-hook 'corfu-mode-hook
            (lambda ()
              (setq-local completion-at-point-functions
                          (remove 'ispell-completion-at-point completion-at-point-functions)))))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :custom
  (marginalia-align 'center)
  :init
  (marginalia-mode 1))

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :init
  (nerd-icons-completion-mode 1)
  :hook (marginalia-mode-hook . nerd-icons-completion-marginalia-setup))

(defun san/wsl-ripgrep-path-fix (path)
  "Normalize a /mnt/<drive>/... PATH so ripgrep doesn't choke on it under WSL."
  (if (string-match "\\`/mnt/\\([a-z]\\)/" path)
      (format "/mnt/%s%s" (match-string 1 path) (substring path (match-end 0)))
    path))

(use-package consult
  :ensure t
  :bind (("M-s M-g" . consult-ripgrep)
         ("M-s M-f" . consult-find)
         ("M-s M-o" . consult-outline)
         ("M-s M-l" . consult-line)
         ("M-s M-b" . consult-buffer)
         ("C-x M-b" . consult-buffer))
  :custom
  (consult-async-input-debounce 0.8)
  (consult-async-input-throttle 1.2)
  (consult-async-min-input 3)
  :config
  (when (san/wsl-p)
    (advice-add 'consult-ripgrep :around
                (lambda (orig-fun &rest args)
                  (let ((default-directory (san/wsl-ripgrep-path-fix default-directory)))
                    (apply orig-fun args))))
    ;; consult splits this string with `split-string-and-unquote', which
    ;; understands double-quoted (Lisp-style) spans, NOT shell single
    ;; quotes -- so every glob below is bare, and only the one glob with
    ;; an embedded space needs the double-quote span to stay one token.
    (setq consult-ripgrep-args
          (concat "rg --null --line-buffered --color=never --max-columns=300 "
                  "--path-separator / --smart-case --no-heading --with-filename "
                  "--line-number --no-follow --max-filesize=500K "
                  "--glob !*/.git/* "
                  "--glob !*/node_modules/* "
                  "--glob !*/__pycache__/* "
                  "--glob !*/Archive/* "
                  "--glob !*/elpa/* "
                  "--glob !*.pdf "
                  "--glob !*.png "
                  "--glob !*.jpg "
                  "--glob !*.jpeg "
                  "--glob !*.svg "
                  "--glob !*.ico "
                  "--glob \"!*/System Volume Information\" "
                  "--glob !*/$Recycle.Bin"))))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

(use-package embark-consult
  :ensure t
  :after (embark consult))

;;; Meow integration
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

(provide 'san-completions)
;;; san-completions.el ends here

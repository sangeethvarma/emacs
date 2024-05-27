(use-package python
  :ensure t
  :bind (:map python-ts-mode-map
              ("<f5>" . recompile)
              ("<f6>" . eglot-format))
  :hook ((python-ts-mode . eglot-ensure)
         (python-ts-mode . company-mode))
  :mode (("\\.py\\'" . python-ts-mode)))

(use-package elpy
  :ensure t)

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 1))



(use-package eglot
  :ensure t
  :bind (:map eglot-mode-map
              ("C-c d" . eldoc)
              ("C-c a" . eglot-code-actions)
              ("C-c f" . flymake-show-buffer-diagnostics)
              ("C-c r" . eglot-rename)))

(desktop-save-mode 1)

;; require melpa
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(use-package conda
  :ensure t
  :config
  (setq conda-env-home-directory
        (expand-file-name "~/mambaforge")))

(use-package highlight-indent-guides
  :ensure t
  :hook (python-ts-mode . highlight-indent-guides-mode)
  :config
  (set-face-foreground 'highlight-indent-guides-character-face "white")
  (setq highlight-indent-guides-method 'character))

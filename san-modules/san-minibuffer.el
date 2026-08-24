;;; san-minibuffer.el --- History persistence & minibuffer tweaks -*- lexical-binding: t -*-

;;; Commentary:
;; Recentf, savehist, and case-insensitive/backspace behavior for the
;; minibuffer.

;;; Code:

(use-package recentf
  :ensure nil
  :custom
  (recentf-max-saved-items 100)
  (recentf-exclude
   '("\\.gpg\\'" "\\.gz\\'" "-autoloads\\.el\\'" "~\\'"
     "/elpa/" "/pck/" "/.emacs.d/cache/" "/no-littering/" "/\\.git/"))
  :bind ("C-c f r" . recentf-open-files)
  :init
  (recentf-mode 1))

(use-package savehist
  :ensure nil
  :custom
  (savehist-additional-variables
   '(search-ring regexp-search-ring comint-process-echoes
     comint-input-ring compile-history register-alist))
  (savehist-file (expand-file-name "savehist" no-littering-var-directory))
  :init
  (savehist-mode 1))

(use-package minibuffer
  :ensure nil
  :custom
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (completion-ignore-case t)
  :init
  (keymap-set minibuffer-local-completion-map "C-<backspace>" 'minibuffer-complete-and-exit)
  (keymap-set minibuffer-local-completion-map "C-w" 'minibuffer-complete-word))

;; DEL/C-h delete backward instead of opening help in every minibuffer flavor
(with-eval-after-load 'minibuffer
  (dolist (map '(minibuffer-local-map
                 minibuffer-local-completion-map
                 minibuffer-local-must-match-map
                 minibuffer-local-ns-map))
    (keymap-set (symbol-value map) "C-h" 'backward-delete-char-untabify)
    (keymap-set (symbol-value map) "DEL" 'backward-delete-char-untabify)))

(provide 'san-minibuffer)
;;; san-minibuffer.el ends here

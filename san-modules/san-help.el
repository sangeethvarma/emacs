;;; san-help.el --- Help and key discovery -*- lexical-binding: t -*-

;;; Commentary:
;; which-key for in-progress keybinding hints, helpful for richer
;; documentation buffers.

;;; Code:

(use-package which-key
  :ensure nil
  :init
  (which-key-mode 1))

(use-package helpful
  :ensure t
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-h F" . helpful-function)
         ("C-c C-d" . helpful-at-point)))

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c n" "notes"
    "C-c n n" "open/create"
    "C-c n i" "link/create"
    "C-c n s" "switch silo"
    "C-c n g" "grep notes"
    "C-c n f" "find notes"
    "C-c g" "AI/LLM"
    "C-c g g" "new chat"
    "C-c g s" "send"
    "C-c g m" "menu"
    "C-c g l" "load conversation"
    "C-c g w" "save conversation"))

(provide 'san-help)
;;; san-help.el ends here

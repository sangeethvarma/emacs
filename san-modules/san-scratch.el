;;; san-scratch.el --- Persistent Multi-Mode Scratch Sandbox Architecture -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages volatile scratch environments, converting them into 
;; long-lived persistent code sandboxes. It orchestrates:
;; - Persistent-Scratch: Auto-saving buffer states to disk regularly.
;; - Multi-Mode Switcher: Instant provisioning of syntax-focused scratchpads
;;   (Elisp, Org-mode, Markdown, Python) without polluting storage vaults.

;;; Code:

;;; Persistent Scratch Engine Configuration
;; ---------------------------------------------------------------------

(defun san/persistent-scratch-buffer-p ()
  "Evaluate whether the current buffer qualifies for persistent serialization.
Called with no arguments by persistent-scratch. Returns non-nil if the current
buffer name starts with '*scratch'."
  (string-prefix-p "*scratch" (buffer-name)))

(use-package persistent-scratch
  :ensure t
  :config
  ;; Configure serialization rules and specify metadata parameters to track
  (setq persistent-scratch-scratch-buffer-p-function #'san/persistent-scratch-buffer-p
        persistent-scratch-what-to-save '(major-mode point))
  
  ;; Defer baseline file restoration out of the use-package initialization block.
  ;; This ensures the file-saving mechanics do not execute until the master file loader
  ;; scope goes out of context, preventing dynamic scope conflicts.
  (add-hook 'emacs-startup-hook
            (lambda ()
              (persistent-scratch-setup-default)
              (when (get-buffer "*scratch*")
                (with-current-buffer "*scratch*"
                  (persistent-scratch-mode 1))))))

;;; Multi-Mode Scratch Environment Manager
;; ---------------------------------------------------------------------

(defvar san-scratch-buffers
  '(("elisp"  . lisp-interaction-mode)
    ("org"    . org-mode)
    ("md"     . markdown-mode)
    ("python" . python-mode))
  "Association list mapping short-token descriptors to target language major modes.")

(defun san/open-scratch-buffer (type)
  "Jump to or spawn a persistent configuration scratch sandbox of the chosen TYPE.
Provides dynamic minibuffer tab-completion via `san-scratch-buffers`."
  (interactive
   (list (completing-read "🧪 Select Scratch Language Environment: " (mapcar #'car san-scratch-buffers) nil t)))
  (let* ((mode (cdr (assoc type san-scratch-buffers)))
         (buf-name (if (string= type "elisp") "*scratch*" (format "*scratch-%s*" type)))
         (buf (get-buffer-create buf-name)))
    
    (with-current-buffer buf
      (unless (eq major-mode mode)
        (funcall mode))
      (when (and (fboundp 'persistent-scratch-mode) (not persistent-scratch-mode))
        (persistent-scratch-mode 1)))
    
    (switch-to-buffer buf)))

;;; Global Multi-Mode Sandbox Keybinding Configuration
;; ---------------------------------------------------------------------
(keymap-global-set "C-c s" #'san/open-scratch-buffer)

(provide 'san-scratch)
;;; san-scratch.el ends here

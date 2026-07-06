;;; san-scratch.el --- Persistent Multi-Mode Scratch Sandbox Architecture -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages volatile scratch environments, converting them into 
;; long-lived persistent code sandboxes. It orchestrates:
;; 1. Persistent-Scratch: Auto-saving buffer states to disk regularly.
;; 2. Multi-Mode Switcher: Instant provisioning of syntax-focused scratchpads
;;    (Elisp, Org-mode, Markdown, Python) without polluting storage vaults.
;;
;; Keybindings:
;; C-c s -> Prompts the minibuffer to jump to or spawn a specific scratchpad type.

;;; Code:

;; =============================================================================
;; 1. Persistent Scratch Engine Configuration
;; =============================================================================

(defun san/persistent-scratch-buffer-p ()
  "Evaluate whether the target buffer's namespace qualifies for persistent serialization.
Matches the default '*scratch*' target along with all custom multi-mode scratch pads
prefixed with '*scratch-'."
  (string-prefix-p "*scratch" (buffer-name)))

(use-package persistent-scratch
  :ensure t
  :config
  ;; Initialize structural save states and write timers
  (persistent-scratch-setup-default)
  
  ;; Configure serialization rules and specify metadata parameters to track
  (setq persistent-scratch-scratch-buffer-p-function #'san/persistent-scratch-buffer-p
        persistent-scratch-what-to-save '(major-mode point))
  
  ;; Ensure the system-default scratch buffer inherits persistence immediately upon load
  (when (get-buffer "*scratch*")
    (with-current-buffer "*scratch*"
      (persistent-scratch-mode 1))))

;; =============================================================================
;; 2. Multi-Mode Scratch Environment Manager
;; =============================================================================

(defvar san-scratch-buffers
  '(("elisp"  . lisp-interaction-mode)
    ("org"    . org-mode)
    ("md"     . markdown-mode)
    ("python" . python-mode))
  "Association list mapping short-token descriptors to target language major modes.")

(defun san/open-scratch-buffer (type)
  "Jump to or spawn a persistent configuration scratch sandbox of the chosen TYPE.
Provides dynamic minibuffer tab-completion via `san-scratch-buffers`. If the 
requested buffer does not exist, provisions it dynamically, links its evaluation 
major mode, and registers it with the data backup engine."
  (interactive
   (list (completing-read "Scratch buffer language type: " (mapcar #'car san-scratch-buffers) nil t)))
  (let* ((mode (cdr (assoc type san-scratch-buffers)))
         ;; Retain default naming string rules for Lisp interactive testing
         (buf-name (if (string= type "elisp") "*scratch*" (format "*scratch-%s*" type)))
         (buf (get-buffer-create buf-name)))
    
    (with-current-buffer buf
      ;; Initialize minor mode layer properties if the target buffer is brand new
      (unless (eq major-mode mode)
        (funcall mode))
      ;; Bind the buffer cleanly inside the background write lifecycle
      (when (and (fboundp 'persistent-scratch-mode) (not persistent-scratch-mode))
        (persistent-scratch-mode 1)))
    
    ;; Bring the target scratch buffer directly to front split focus
    (switch-to-buffer buf)))

;; =============================================================================
;; 3. Global Multi-Mode Sandbox Keybinding Configuration
;; =============================================================================
(keymap-global-set "C-c s" #'san/open-scratch-buffer)

(provide 'san-scratch)
;;; san-scratch.el ends here

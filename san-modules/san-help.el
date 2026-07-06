;;; san-help.el --- Help, Documentation & Key Discovery Configuration -*- lexical-binding: t -*-

;;; Commentary:
;; This module optimizes key discovery and context-rich help interfaces.
;; It coordinates:
;; - Which-Key for automatic, structural keybinding reminder layouts.
;; - Helpful for detailed documentation symbols, caller graphs, and source code loops.
;; - Interactivity functions to inspect background diagnostic logs.

;;; Code:

;;; Interactive Key Discovery Framework
;; ---------------------------------------------------------------------
;; Automatically generates a descriptive popup overlay array at the lower frame edge
;; when input sequences stop mid-way through a multi-key binding combination.

(use-package which-key
  :ensure nil                             ; Built-in package core primitive
  :init
  (which-key-mode 1))

;;; Rich Contextual Documentation Pages
;; ---------------------------------------------------------------------
;; Replaces default doc panels with detailed Helpful nodes that render literal source code 
;; definitions, track property evaluations, and expose execution loops at point.

(use-package helpful
  :ensure t
  :bind (("C-h f" . helpful-callable)     ; Interrogate functions, macros, or byte-code primitives
         ("C-h v" . helpful-variable)     ; Interrogate local/global configuration variables
         ("C-h k" . helpful-key)          ; Track a literal keyboard shortcut to its exact source block
         ("C-h x" . helpful-command)      ; Inspect interactive command statements
         ("C-h F" . helpful-function)     ; Filter strictly by formal function declarations
         ("C-c C-d" . helpful-at-point))) ; Context-aware symbol investigation under point

;;; System Health Diagnostics & Log Inspection
;; ---------------------------------------------------------------------
;; Provisions an automated utility function to split windows and tail background 
;; backup server events directly without forcing manual file navigation workflows.

(defun san/view-backup-log ()
  "Instantly open the background system file backup log inside an adjacent window pane."
  (interactive)
  (let ((log-file (expand-file-name "~/.config/logs/backup.log")))
    (if (file-exists-p log-file)
        (find-file-other-window log-file)
      (user-error "The target backup log file does not exist at path: %s" log-file))))

(keymap-global-set "C-c h b" #'san/view-backup-log)

(provide 'san-help)
;;; san-help.el ends here

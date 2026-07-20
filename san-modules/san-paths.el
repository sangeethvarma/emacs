;;; san-paths.el ---  Cross-Platform Directory Mappings -*- lexical-binding: t -*-

;;; Commentary:
;; Platform-agnostic workspace directory foundations for PARA system layout.

;;; Code:

;;; Global Vault Root Definition
(defvar san-vault-root
  (if (eq system-type 'windows-nt)
      "L:/"
    "/mnt/l/")
  "Root mount point for the shared master storage vault.")

(defun san/validate-vault-root ()
  "Verify that the vault root directory is accessible."
  (condition-case err
      (unless (file-directory-p san-vault-root)
        (display-warning 'san-paths 
                        (format "Vault root not found: %s. Please check drive mounting." 
                                san-vault-root)
                        :warning))
    (error (display-warning 'san-paths 
                           (format "Vault validation failed: %s" (error-message-string err))
                           :error))))

(add-hook 'emacs-startup-hook #'san/validate-vault-root)

;;; Structured PARA Area Directory Registry
(defvar san-personal-dir (expand-file-name "1 - Personal/" san-vault-root)
  "Path to personal logs, journal items, health records, and life tracking ledger.")

(defvar san-phd-dir (expand-file-name "2 - PhD/" san-vault-root)
  "Path to doctoral research workspace, literature notes, and reference PDFs.")

(defvar san-startup-dir (expand-file-name "3 - Iterrate/" san-vault-root)
  "Path to EdTech startup operational task tracking environment and brand assets.")

(defvar san-inbox-dir (expand-file-name "Inbox/" san-vault-root)
  "Path to universal catch-all folder for manual entries and browser text captures.")

(defvar san-sandbox-dir (expand-file-name "Sandbox/" san-vault-root)
  "Path to code snippet playbooks, script playgrounds, and automation tasks.")

(defvar san-archive-dir (expand-file-name "Archive/" san-vault-root)
  "Path to cold historical records, entirely filtered from active search indexes.")

;;; Interactive Directory Accessors (Dired Integration)
(defmacro san/define-dir-opener (name dir-var &optional docstring)
  "Create an interactive function to open a PARA directory in Dired.
NAME is the function name suffix.
DIR-VAR is the directory variable to use.
DOCSTRING is optional documentation."
  (let ((func-name (intern (format "san/open-%s-dir" name))))
    `(defun ,func-name ()
       ,(or docstring (format "Open the %s directory in Dired." name))
       (interactive)
       (find-file ,dir-var))))

(san/define-dir-opener personal san-personal-dir
  "Open the Personal Area folder in Dired.")
(san/define-dir-opener phd san-phd-dir
  "Open the PhD Academic Area folder in Dired.")
(san/define-dir-opener startup san-startup-dir
  "Open the Iterrate Startup Area folder in Dired.")
(san/define-dir-opener inbox san-inbox-dir
  "Open the Universal Inbox folder in Dired.")
(san/define-dir-opener sandbox san-sandbox-dir
  "Open the Sandbox scripting folder in Dired.")

;;; Global Navigation Keybindings
(keymap-global-set "C-c d p" #'san/open-phd-dir)
(keymap-global-set "C-c d m" #'san/open-personal-dir)
(keymap-global-set "C-c d i" #'san/open-startup-dir)
(keymap-global-set "C-c d d" #'san/open-inbox-dir)
(keymap-global-set "C-c d r" #'san/open-sandbox-dir)

(provide 'san-paths)
;;; san-paths.el ends here

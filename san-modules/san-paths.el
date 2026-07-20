;;; san-paths.el --- Dynamic Cross-Platform Directory Mappings -*- lexical-binding: t -*-

;;; Commentary:
;; This module establishes the core workspace directory foundations for the
;; PARA system layout. It dynamically detects whether the current Emacs
;; instance is executing on a native Windows host or inside a WSL2 guest 
;; container, mapping the central storage partition fluidly without breaking 
;; absolute path mobility.

;;; Code:

;;; Global Vault Root Definition
;; The central storage partition (L drive) is mounted across both operating system
;; landscapes. Windows addresses it natively as a block drive, whereas WSL2
;; mounts it via the 9p/drvfs filesystem layer under the linux guest mount directory.

(defvar san-vault-root
  (if (eq system-type 'windows-nt)
      "L:/"
    "/mnt/l/")
  "The platform-agnostic root mount point for the shared master storage vault.")

(defun san/validate-vault-root ()
  "Verify that the vault root directory is accessible."
  (unless (file-directory-p san-vault-root)
    (display-warning 'san-paths 
                     (format "Vault root not found: %s. Please check drive mounting." san-vault-root)
                     :warning)))

(add-hook 'emacs-startup-hook #'san/validate-vault-root)

;;; Structured PARA Area Directory Registry
;; Absolute paths to the isolated operational domains within the vault.
;; Workspace hooks, file generation functions, and asset managers must evaluate
;; directly against these variables to maintain cross-platform runtime mobility.

(defvar san-personal-dir (expand-file-name "1 - Personal/" san-vault-root)
  "Path to the personal logs, journal items, health records, and life tracking ledger.")

(defvar san-phd-dir (expand-file-name "2 - PhD/" san-vault-root)
  "Path to the doctoral research workspace, literature notes, and reference PDFs.")

(defvar san-startup-dir (expand-file-name "3 - Iterrate/" san-vault-root)
  "Path to the EdTech startup operational task tracking environment and brand assets.")

(defvar san-inbox-dir (expand-file-name "Inbox/" san-vault-root)
  "Path to the universal catch-all folder for manual entries and browser text captures.")

(defvar san-sandbox-dir (expand-file-name "Sandbox/" san-vault-root)
  "Path to code snippet playbooks, script playgrounds, and automation tasks.")

(defvar san-archive-dir (expand-file-name "Archive/" san-vault-root)
  "Path to cold historical records, entirely filtered from active search indexes.")

;;; Interactive Directory Accessors (Dired Integration)
;; Quick navigation entry-points that wrap directory paths into localized Dired buffers.
;; Bypasses standard file-finding prompts for core active domains.

(defmacro san/define-dir-opener (name dir-var &optional docstring)
  "Create an interactive function to open a PARA directory in Dired.
NAME is the function name suffix (e.g., 'personal' -> san/open-personal-dir).
DIR-VAR is the directory variable to use.
DOCSTRING is optional documentation."
  (let ((func-name (intern (format "san/open-%s-dir" name))))
    `(defun ,func-name ()
       ,(or docstring (format "Open the %s directory in Dired." name))
       (interactive)
       (find-file ,dir-var))))

(san/define-dir-opener personal san-personal-dir
  "Instantly open the Personal Area folder inside a Dired buffer.")
(san/define-dir-opener phd san-phd-dir
  "Instantly open the PhD Academic Area folder inside a Dired buffer.")
(san/define-dir-opener startup san-startup-dir
  "Instantly open the Iterrate Startup Area folder inside a Dired buffer.")
(san/define-dir-opener inbox san-inbox-dir
  "Instantly open the Universal Inbox folder inside a Dired buffer.")
(san/define-dir-opener sandbox san-sandbox-dir
  "Instantly open the Sandbox scripting folder inside a Dired buffer.")

;;; Global Navigation Mnemonic Keybindings
;; Evaluated using modern Emacs 29+ primitives. Placed under the personal 
;; 'C-c d' (directory) prefix map for high-speed touch-typing execution.

(keymap-global-set "C-c d p" #'san/open-phd-dir)
(keymap-global-set "C-c d m" #'san/open-personal-dir)
(keymap-global-set "C-c d i" #'san/open-startup-dir)
(keymap-global-set "C-c d d" #'san/open-inbox-dir)
(keymap-global-set "C-c d r" #'san/open-sandbox-dir)

(provide 'san-paths)
;;; san-paths.el ends here

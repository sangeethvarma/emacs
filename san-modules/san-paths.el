;;; san-paths.el --- Dynamic Cross-Platform Directory Mappings -*- lexical-binding: t -*-

;;; Commentary:
;; This module sets up the fundamental path architecture for the entire Emacs configuration.
;; It dynamically handles cross-platform path resolution between native Windows 10
;; and WSL2 (Ubuntu) to ensure a shared configuration can run seamlessly on both.
;; All directories are organized around a centralized flat PARA-style layout.

;;; Code:

;; =============================================================================
;; 1. Global Vault Root Definition
;; =============================================================================

(defvar san-vault-root
  (if (eq system-type 'windows-nt)
      "L:/"
    "/mnt/l/")
  "The platform-agnostic root mount point for the master vault partition.
Resolves to 'L:/' under Windows host environments and '/mnt/l/' under WSL2 Linux.")

;; =============================================================================
;; 2. Structured PARA Area Directory Mappings
;; =============================================================================

(defvar san-personal-dir (expand-file-name "1 - Personal/" san-vault-root)
  "Path to Area 1 (Personal).
Houses physical fitness logs, financial trackers, life maintenance items, and chores.")

(defvar san-phd-dir (expand-file-name "2 - PhD/" san-vault-root)
  "Path to Area 2 (PhD Academic).
Houses doctoral research data, academic literature, bibliography indexes, admin documents, degree milestones, etc..")

(defvar san-startup-dir (expand-file-name "3 - Iterrate/" san-vault-root)
  "Path to Area 3 (Iterrate Startup).
Houses business incubation notes, core product codebases, etc.")

(defvar san-inbox-dir (expand-file-name "Inbox/" san-vault-root)
  "Path to the Universal Inbox Funnel.
Acts as a high-speed intake layer for browser captures, mobile sync logs, and raw downloads.")

(defvar san-sandbox-dir (expand-file-name "Sandbox/" san-vault-root)
  "Path to the Sandbox Area.
Reserved for non-production scripting, unaligned code playgrounds, and package testing.")

(defvar san-archive-dir (expand-file-name "Archive/" san-vault-root)
  "Path to the Archive Root.
Stores records and completed projects to keep them isolated from active search rings.")

;; =============================================================================
;; 3. Interactive Directory Accessors (Dired Integration)
;; =============================================================================

(defun san/open-personal-dir ()
  "Instantly open the Personal Area folder inside a Dired buffer."
  (interactive)
  (find-file san-personal-dir))

(defun san/open-phd-dir ()
  "Instantly open the PhD Academic Area folder inside a Dired buffer."
  (interactive)
  (find-file san-phd-dir))

(defun san/open-startup-dir ()
  "Instantly open the Iterrate Startup Area folder inside a Dired buffer."
  (interactive)
  (find-file san-startup-dir))

(defun san/open-inbox-dir ()
  "Instantly open the Universal Inbox folder inside a Dired buffer."
  (interactive)
  (find-file san-inbox-dir))

(defun san/open-sandbox-dir ()
  "Instantly open the Sandbox scripting folder inside a Dired buffer."
  (interactive)
  (find-file san-sandbox-dir))

;; =============================================================================
;; 4. Global Mnemonic Keybindings
;; =============================================================================
;; Uses Emacs 29+ `keymap-global-set` for standardized, modern key configuration.
;; Structure: C-c d [target prefix] -> "Control-c Directory [Target]"

(keymap-global-set "C-c d p" #'san/open-phd-dir)
(keymap-global-set "C-c d m" #'san/open-personal-dir)
(keymap-global-set "C-c d i" #'san/open-startup-dir)
(keymap-global-set "C-c d d" #'san/open-inbox-dir)
(keymap-global-set "C-c d r" #'san/open-sandbox-dir)

(provide 'san-paths)
;;; san-paths.el ends here

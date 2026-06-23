;;; -*- lexical-binding: t -*-
;;; san-modules/san-paths.el --- Dynamic Cross-Platform Directory Mappings

(defvar san-vault-root
  (if (eq system-type 'windows-nt)
      "L:/"
    "/mnt/l/")
  "The cross-platform root mount point for the master vault partition.")

;; Structural Area Mappings

(defvar san-personal-dir (expand-file-name "1 - Personal/" san-vault-root)
  "Area: Fitness, Personal finances, Life chores and tasks.")

(defvar san-phd-dir (expand-file-name "2 - PhD/" san-vault-root)
  "Area: Doctoral research, academic literature, and degree logistics.")

(defvar san-startup-dir (expand-file-name "3 - Iterrate/" san-vault-root)
  "Area: startup incubation, validation experiments, and core codebases.")

(defvar san-inbox-dir (expand-file-name "Inbox/" san-vault-root)
  "The universal intake funnel for web captures, notes, and raw downloads.")

(defvar san-sandbox-dir (expand-file-name "Sandbox/" san-vault-root)
  "Area: Unaligned coding experiments, custom scripting, and technical play.")

(defvar san-archive-dir (expand-file-name "Archive/" san-vault-root)
  "The root directory for Archive - Old files to keep out of your search results.")

;; Direct Dired Accessors
(defun san/open-personal-dir () (interactive) (find-file san-personal-dir))
(defun san/open-phd-dir () (interactive) (find-file san-phd-dir))
(defun san/open-startup-dir () (interactive) (find-file san-startup-dir))
(defun san/open-inbox-dir () (interactive) (find-file san-inbox-dir))
(defun san/open-sandbox-dir () (interactive) (find-file san-sandbox-dir))


(keymap-global-set "C-c d p" 'san/open-phd-dir)
(keymap-global-set "C-c d m" 'san/open-personal-dir)
(keymap-global-set "C-c d i" 'san/open-startup-dir)
(keymap-global-set "C-c d d" 'san/open-inbox-dir)
(keymap-global-set "C-c d r" 'san/open-sandbox-dir)

(provide 'san-paths)

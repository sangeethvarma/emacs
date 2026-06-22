;;; -*- lexical-binding: t -*-

(defvar san-phd-dir "/mnt/l/PhD/"
  "The root directory for all academic research and literature.")

(defvar san-inbox-dir "/mnt/l/Inbox/"
  "The universal intake funnel for web captures, mobile notes, and downloads.")

(defvar san-projects-dir "/mnt/l/Projects/"
  "The root directory for startup development and codebases.")

(defvar san-archive-dir "/mnt/l/Archive/"
  "The root directory for Archive - Old files to keep out of your search results.")

(defun san/open-phd-dir ()
  "Instantly open the base PhD directory in Dired."
  (interactive)
  (find-file san-phd-dir))

;; Bind it to a convenient, globally accessible key chord
(keymap-global-set "C-c d p" 'san/open-phd-dir)

(provide 'san-paths)

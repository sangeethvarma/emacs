;;; san-paths.el --- PARA vault directory layout -*- lexical-binding: t -*-

;;; Commentary:
;; Defines the PARA area directories under the vault mount and dired
;; openers for them. WSL-only: this Emacs never runs natively on Windows.

;;; Code:

(defvar san-vault-root "/mnt/v/Vault/"
  "Root of the shared PARA vault (Windows V: drive, mounted by WSL).")

(defvar san-personal-dir (expand-file-name "1 - Personal/" san-vault-root)
  "Personal logs, journal, health, and life-tracking area.")

(defvar san-phd-dir (expand-file-name "2 - PhD/" san-vault-root)
  "Doctoral research workspace: literature notes and reference PDFs.")

(defvar san-startup-dir (expand-file-name "3 - Iterrate/" san-vault-root)
  "Iterrate (EdTech startup) operational area.")

(defvar san-inbox-dir (expand-file-name "Inbox/" san-vault-root)
  "Catch-all for manual entries and browser captures.")

(defvar san-sandbox-dir (expand-file-name "Sandbox/" san-vault-root)
  "Scripts, snippets, and automation experiments.")

(defvar san-archive-dir (expand-file-name "Archive/" san-vault-root)
  "Cold storage, excluded from active search indexes.")

(defvar san-whiteboard-dir (expand-file-name "whiteboard-photos/" san-inbox-dir)
  "Drop folder for phone photos of the desk/bedroom/living-room whiteboards
(synced in via Syncthing), reviewed and transcribed into the inbox.")

(defun san/windows-home-dir ()
  "Windows user home directory, reachable from WSL."
  (format "/mnt/c/Users/%s/" (or (san/get-windows-username) "sangeeth")))

(defun san/validate-vault-root ()
  "Warn if the vault mount isn't there (V: drive not mounted, WSL not up yet, etc)."
  (unless (file-directory-p san-vault-root)
    (display-warning 'san-paths
                      (format "Vault root not found: %s" san-vault-root)
                      :warning)))

(defun san/validate-para-directories ()
  "Create any PARA area directories that don't exist yet."
  (dolist (dir (list san-personal-dir san-phd-dir san-startup-dir
                     san-inbox-dir san-sandbox-dir san-whiteboard-dir))
    (unless (file-directory-p dir)
      (make-directory dir t))))

(add-hook 'emacs-startup-hook #'san/validate-vault-root)
(add-hook 'emacs-startup-hook #'san/validate-para-directories)

;;; Dired openers
(defmacro san/define-dir-opener (name dir-var docstring)
  "Define `san/open-NAME-dir', an interactive command opening DIR-VAR in dired."
  (let ((func-name (intern (format "san/open-%s-dir" name))))
    `(defun ,func-name ()
       ,docstring
       (interactive)
       (find-file ,dir-var))))

(san/define-dir-opener personal san-personal-dir "Open the Personal area in Dired.")
(san/define-dir-opener phd san-phd-dir "Open the PhD area in Dired.")
(san/define-dir-opener startup san-startup-dir "Open the Iterrate area in Dired.")
(san/define-dir-opener inbox san-inbox-dir "Open the Inbox in Dired.")
(san/define-dir-opener sandbox san-sandbox-dir "Open the Sandbox in Dired.")
(san/define-dir-opener whiteboard san-whiteboard-dir "Open the whiteboard-photo drop folder in Dired.")
(san/define-dir-opener windows (san/windows-home-dir) "Open the Windows home folder in Dired.")
(san/define-dir-opener emacs-config user-emacs-directory "Open the Emacs config directory in Dired.")

(keymap-global-set "C-c d p" #'san/open-phd-dir)
(keymap-global-set "C-c d m" #'san/open-personal-dir)
(keymap-global-set "C-c d i" #'san/open-startup-dir)
(keymap-global-set "C-c d d" #'san/open-inbox-dir)
(keymap-global-set "C-c d r" #'san/open-sandbox-dir)
(keymap-global-set "C-c d b" #'san/open-whiteboard-dir)
(keymap-global-set "C-c d w" #'san/open-windows-dir)
(keymap-global-set "C-c d e" #'san/open-emacs-config-dir)

(provide 'san-paths)
;;; san-paths.el ends here

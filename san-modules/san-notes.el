;;; san-notes.el --- Denote note-taking across the PARA silos -*- lexical-binding: t -*-

;;; Commentary:
;; Denote (multi-silo) + consult-denote for search, a reading/idea
;; template pair to cut blank-page friction, and the grasp web-capture
;; server.

;;; Code:

(use-package denote
  :ensure t
  :custom
  (denote-directory (expand-file-name "notes/" san-inbox-dir))
  (denote-templates
   '((reading . "* Core Argument\n\n* Key Quotes\n\n* Connections\n\n* My Response / Questions\n\n")
     (idea . "* Idea\n\n* Why It Matters\n\n* Related\n\n")))
  :config
  (add-to-list 'denote-prompts 'template)
  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n i" . denote-link-or-create)
   ("C-c n s" . san/switch-denote-silo)))

(defvar san-denote-silo-alist
  `(("📥 Inbox" . ,(expand-file-name "notes/" san-inbox-dir))
    ("🎓 PhD" . ,(expand-file-name "notes/" san-phd-dir))
    ("🚀 Startup" . ,(expand-file-name "notes/" san-startup-dir))
    ("🌱 Personal Life & Health" . ,(expand-file-name "notes/" san-personal-dir))
    ("🧪 Sandbox" . ,(expand-file-name "notes/" san-sandbox-dir)))
  "Area name -> its notes/ directory.")

(defun san/ensure-denote-silo-directories ()
  "Create any silo notes/ directories that don't exist yet."
  (dolist (silo san-denote-silo-alist)
    (unless (file-directory-p (cdr silo))
      (make-directory (cdr silo) t))))

(add-hook 'emacs-startup-hook #'san/ensure-denote-silo-directories)

(defun san/switch-denote-silo ()
  "Switch Denote's active directory to a chosen PARA area's notes/."
  (interactive)
  (let* ((chosen-name (completing-read "Select Note Silo: " (mapcar #'car san-denote-silo-alist) nil t))
         (chosen-path (cdr (assoc chosen-name san-denote-silo-alist))))
    (unless (file-directory-p chosen-path)
      (make-directory chosen-path t))
    (setq denote-directory chosen-path)
    (message "Denote context shifted to: %s" chosen-name)))

;; denote-open-or-create's candidate sort (denote-sort-modified-time-greaterp)
;; stat()s every file on *every* comparison during the sort -- an O(n log n)
;; sort turns into that many filesystem round-trips, each paying the DrvFS
;; latency tax on the vault mount (profiled: ~30% of the whole command's
;; time on this alone, even with under 100 notes). Denote filenames already
;; embed a creation timestamp, so compare that substring instead -- zero
;; stat() calls. Trade-off: orders by creation time, not last-edited time.
(defun san/denote-sort-identifier-greaterp (file1 file2)
  "Fast, stat()-free replacement for `denote-sort-modified-time-greaterp'."
  (string> (denote-retrieve-filename-identifier file1)
           (denote-retrieve-filename-identifier file2)))

(advice-add 'denote-sort-modified-time-greaterp :override #'san/denote-sort-identifier-greaterp)

;; Same disease, different function: denote-directories (used to compute
;; each candidate's display path) calls file-directory-p with zero caching,
;; and gets called once PER CANDIDATE FILE during denote-file-prompt --
;; another stat() per file for a value (denote-directory) that essentially
;; never changes mid-session. Memoize it, keyed on denote-directory's
;; current value so switching silos still invalidates correctly.
(defvar san--denote-directories-cache nil
  "Cons of (denote-directory value . cached result) for `denote-directories'.")

(defun san/denote-directories-cached (orig-fun &rest args)
  (if (equal (car san--denote-directories-cache) denote-directory)
      (cdr san--denote-directories-cache)
    (let ((result (apply orig-fun args)))
      (setq san--denote-directories-cache (cons denote-directory result))
      result)))

(advice-add 'denote-directories :around #'san/denote-directories-cached)

(use-package consult-denote
  :ensure t
  :init
  (consult-denote-mode 1)
  :bind
  (("C-c n g" . consult-denote-grep)
   ("C-c n f" . consult-denote-find)))

;;; PhD note-activity signal, referenced by the Weekly Review Log
;;; capture template (san-org-capture.el).
(defun san/days-since-last-file-in (dir)
  "Days since the most recently modified .org file under DIR, or nil if none."
  (when (file-directory-p dir)
    (let (newest)
      (dolist (file (directory-files-recursively dir "\\.org\\'"))
        (let ((mtime (float-time (file-attribute-modification-time (file-attributes file)))))
          (when (or (null newest) (> mtime newest))
            (setq newest mtime))))
      (when newest
        (floor (/ (- (float-time) newest) 86400))))))

(defun san/phd-notes-status-line ()
  "One-line summary of PhD note activity."
  (let ((days (san/days-since-last-file-in (expand-file-name "notes/" san-phd-dir))))
    (format "PhD notes: last activity %s"
            (cond ((null days) "never")
                  ((zerop days) "today")
                  ((= days 1) "1 day ago")
                  (t (format "%d days ago" days))))))

;;; Grasp: background service listening for browser markdown clips
;;; forwarded by the Grasp extension.
(let ((grasp-python-bin (expand-file-name "~/.tools/grasp/.venv/bin/python"))
      (grasp-target-inbox (expand-file-name "-grasp__inbox.org" san-inbox-dir)))
  (when (and (file-exists-p grasp-python-bin)
             (not (get-process "grasp-server")))
    (start-process "grasp-server" "*grasp-server-log*"
                   grasp-python-bin "-m" "grasp_backend" "serve" "--path" grasp-target-inbox)))

(provide 'san-notes)
;;; san-notes.el ends here

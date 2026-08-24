;;; san-scratch.el --- Persistent multi-mode scratch buffers -*- lexical-binding: t -*-

;;; Commentary:
;; Auto-saves *scratch* buffers to disk (persistent-scratch) and adds
;; C-c s for jumping between per-language scratch buffers.

;;; Code:

(defun san/persistent-scratch-buffer-p ()
  "Return non-nil for any buffer whose name starts with \"*scratch\"."
  (string-prefix-p "*scratch" (buffer-name)))

(use-package persistent-scratch
  :ensure t
  :commands (persistent-scratch-mode persistent-scratch-setup-default)
  :custom
  (persistent-scratch-scratch-buffer-p-function #'san/persistent-scratch-buffer-p)
  (persistent-scratch-what-to-save '(major-mode point)))

(defun san/initialize-persistent-scratch ()
  "Restore saved scratch buffers and turn persistent-scratch-mode on for each."
  (persistent-scratch-setup-default)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (san/persistent-scratch-buffer-p)
                 (not (eq major-mode 'fundamental-mode)))
        (persistent-scratch-mode 1)))))

(add-hook 'emacs-startup-hook #'san/initialize-persistent-scratch)

(defvar san-scratch-buffers
  '(("elisp"  . lisp-interaction-mode)
    ("org"    . org-mode)
    ("md"     . markdown-mode)
    ("python" . python-mode))
  "Scratch-buffer type name -> major mode.")

(defun san/open-scratch-buffer (type)
  "Switch to (creating if needed) the persistent scratch buffer for TYPE."
  (interactive
   (list (completing-read "Scratch buffer: " (mapcar #'car san-scratch-buffers) nil t)))
  (let* ((mode (cdr (assoc type san-scratch-buffers)))
         (buf-name (if (string= type "elisp") "*scratch*" (format "*scratch-%s*" type)))
         (buf (get-buffer-create buf-name)))
    (with-current-buffer buf
      (unless (eq major-mode mode)
        (funcall mode))
      (persistent-scratch-mode 1))
    (switch-to-buffer buf)))

(keymap-global-set "C-c s" #'san/open-scratch-buffer)

(provide 'san-scratch)
;;; san-scratch.el ends here

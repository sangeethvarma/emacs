;;; -*- lexical-binding: t -*-

;;; persistent scratch and multiple scratch buffers

(defun san-persistent-scratch-scratch-buffer-p ()
  "Return non-nil if the current buffer's name starts with '*scratch'."
  (string-prefix-p "*scratch" (buffer-name)))

(use-package persistent-scratch
  :config
  (persistent-scratch-setup-default)
  (setq persistent-scratch-scratch-buffer-p-function #'san-persistent-scratch-scratch-buffer-p)
  (setq persistent-scratch-what-to-save '(major-mode point))
  
  ;; Retroactively enable the minor mode in the default startup *scratch* buffer
  (when (get-buffer "*scratch*")
    (with-current-buffer "*scratch*"
      (persistent-scratch-mode 1))))

;;; Multiple Scratch Buffer Manager

(defvar san-scratch-buffers
  '(("elisp"  . lisp-interaction-mode)
    ("org"    . org-mode)
    ("md"     . markdown-mode)
    ("python" . python-mode))
  "Alist of scratch buffer types and their major modes.")

(defun san-open-scratch-buffer (type)
  "Open a scratch buffer of the given TYPE.
Automatically sets the major mode and enables `persistent-scratch-mode'
so that `C-x C-s' saves directly to the persistent file."
  (interactive
   (list (completing-read "Scratch buffer type: "
                          (mapcar #'car san-scratch-buffers)
                          nil t)))
  (let* ((mode (cdr (assoc type san-scratch-buffers)))
         (buf-name (if (string= type "elisp")
                       "*scratch*"
                     (format "*scratch-%s*" type)))
         (buf (get-buffer-create buf-name)))
    
    (with-current-buffer buf
      ;; Set the major mode if it's not already set
      (unless (eq major-mode mode)
        (funcall mode))
      ;; Enable the minor mode so manual saves work immediately
      (when (and (fboundp 'persistent-scratch-mode)
                 (not persistent-scratch-mode))
        (persistent-scratch-mode 1)))
    
    (switch-to-buffer buf)))

(global-set-key (kbd "C-c s") 'san-open-scratch-buffer)

(provide 'san-scratch)

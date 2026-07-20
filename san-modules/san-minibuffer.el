;;; san-minibuffer.el --- Persistent History & Telemetry Tracking -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages internal editor persistence and session caching. It hooks into 
;; the minibuffer and file-handling layers to record across system restarts:
;; - Recently opened file matrices via Recentf.
;; - Comprehensive search loops, register structures, and command histories via Savehist.

;;; Code:

;;; Recent Files Tracking (Recentf Engine)
;; Maintains a persistent cache of recently visited files for rapid access.

(use-package recentf
  :ensure nil
  :custom
  (recentf-max-saved-items 100)
  :bind
  (("C-c f r" . recentf-open-files))
  :config
  ;; Exclude patterns to prevent internal files from cluttering the list
  (setq recentf-exclude
        '("\\.gpg\\'"
          "\\.gz\\'"
          "-autoloads\\.el\\'"
          "~\\'"
          "/elpa/"
          "/pck/"
          "/.emacs.d/cache/"
          "/no-littering/"
          "/\\.git/"))
  (recentf-mode 1))

;;; Persistent Input History Serialization (Savehist Engine)
;; Records minibuffer histories to survive Emacs restarts.

(use-package savehist
  :ensure nil
  :custom
  ;; Capture various history variables
  (savehist-additional-variables
   '(search-ring
     regexp-search-ring
     comint-process-echoes
     comint-input-ring
     compile-history
     register-alist))
  (savehist-file (expand-file-name "savehist" no-littering-var-directory))
  :init
  (savehist-mode 1))

(provide 'san-minibuffer)
;;; san-minibuffer.el ends here

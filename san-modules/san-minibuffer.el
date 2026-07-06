;;; san-minibuffer.el --- Persistent History & Telemetry Tracking -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages internal editor persistence and session caching. It hooks into 
;; the minibuffer and file-handling layers to record across system restarts:
;; - Recently opened file matrices via Recentf.
;; - Comprehensive search loops, register structures, and command histories via Savehist.

;;; Code:

;;; Recent Files Tracking (Recentf Engine)
;; ---------------------------------------------------------------------
;; Maintains a persistent, serialized cache of the most recently visited file objects, 
;; allowing rapid access through completion systems like Consult.

(use-package recentf
  :ensure nil                             ; Built-in core Emacs primitive
  :custom
  (recentf-max-saved-items 100)           ; Balance lookup depth without degrading boot speeds
  :bind
  (("C-c f r" . recentf-open-files))      ; Direct terminal file history menu toggle
  :config
  ;; Exclude pattern array to prevent populating search histories with internal runtime noise,
  ;; temporary byte-compilations, auto-saves, or encrypted security volumes.
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
;; ---------------------------------------------------------------------
;; Records active ring states and variable histories to a flat storage file on disk. 
;; Guarantees that search strings, execution loops, and code registers survive full 
;; workstation power cycles.

(use-package savehist
  :ensure nil                             ; Built-in core Emacs primitive
  :custom
  ;; Capture rich metadata arrays alongside basic minibuffer inputs
  (savehist-additional-variables
   '(search-ring                          ; Active text search entries
     regexp-search-ring                   ; Regular expression execution histories
     comint-process-echoes                ; Terminal interface echo markers
     comint-input-ring                    ; Subshell and PowerShell interactive text pools
     compile-history                      ; Build compiler flags and run arrays
     register-alist))                     ; Persistent structural clip boards and point markers
  (savehist-file (expand-file-name "savehist" no-littering-var-directory))
  :init
  (savehist-mode 1))

(provide 'san-minibuffer)
;;; san-minibuffer.el ends here

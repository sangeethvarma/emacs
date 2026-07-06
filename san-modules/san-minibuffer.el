;;; san-minibuffer.el --- Persistent History & Telemetry Tracking  -*- lexical-binding: t -*-

;;; Commentary:
;; This module manages the telemetry tracking layer of the minibuffer.
;; It preserves context and state transitions across different Emacs editing
;; sessions. It configures:
;; 1. Recentf: Tracks recently accessed files while filtering out internal clutter.
;; 2. Savehist: Serializes minibuffer history, search rings, and command chains.

;;; Code:

;; =============================================================================
;; 1. Recent Files Tracking (Recentf Engine)
;; =============================================================================

(use-package recentf
  :ensure nil                           ; Built-in core Emacs component
  :custom
  (recentf-max-saved-items 100)         ; Ceiling threshold for tracked historical files
  :bind
  (("C-c f r" . recentf-open-files))    ; Modern interactive selection menu mapping
  :config
  ;; Clean Up Filters: Prevent automated system paths, lockfiles, package trees,
  ;; and no-littering scratch components from polluting active search registries.
  (setq recentf-exclude
        '( "\\.gpg\\'"                  ; Exclude encrypted secret vectors
           "\\.gz\\'"                   ; Exclude compressed assets
           "-autoloads\\.el\\'"         ; Exclude package installation scaffolding
           "~\\'"                       ; Exclude volatile autosave points
           "/elpa/"                     ; Exclude external package listings
           "/pck/"                      ; Exclude localized pin layouts
           "/.emacs.d/cache/"           ; Exclude explicit session caches
           "/no-littering/"             ; Exclude automated isolated states
           "/\\.git/"))                 ; Exclude internal version control structures
  
  (recentf-mode 1))

;; =============================================================================
;; 2. Persistent Minibuffer Input Serialization (Savehist Engine)
;; =============================================================================

(use-package savehist
  :ensure nil                           ; Built-in core Emacs component
  :custom
  (savehist-additional-variables
   '(search-ring
     regexp-search-ring
     comint-input-ring                  ; Retain structural PowerShell/Bash history
     compile-history                    ; Retain localized background execution codes
     register-alist))                   ; Preserve register markers across reboots
  (savehist-file (expand-file-name "savehist" var-defaults-dir)) ; Cohesively routed via no-littering
  :init
  (savehist-mode 1))

(provide 'san-minibuffer)
;;; san-minibuffer.el ends here

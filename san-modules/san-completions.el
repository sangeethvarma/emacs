;;; san-completions.el --- Keyboard-Driven Completion Stack -*- lexical-binding: t -*-

;;; Commentary:
;; This module implements a modern, Unix-style minimalist completion architecture.
;; Rather than relying on heavy monolithic completion systems, it orchestrates 
;; lightweight, focused packages that integrate natively with standard Emacs APIs:
;; 1. Vertico: Clean, vertical completion UI for the minibuffer.
;; 2. Corfu: High-speed, in-buffer interactive popup completion.
;; 3. Orderless: Out-of-order regular expression pattern matching engine.
;; 4. Marginalia: Context-rich annotations alongside completion targets.
;; 5. Consult & Embark: Advanced context searches and situational action menus.

;;; Code:

;; =============================================================================
;; 1. Vertico (Vertical Minibuffer Completion UI)
;; =============================================================================

(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)                      ; Wrap around cleanly when reaching list boundaries
  (vertico-resize t)                     ; Dynamically resize the minibuffer window layout
  (vertico-sort-function #'vertico-sort-history-alpha) ; Sort via historical frequency & alphabet
  :init
  (vertico-mode 1))

;; Clean directory traversal overrides inside the Vertico minibuffer
(use-package vertico-directory
  :ensure nil                            ; Component ships natively inside the Vertico extension path
  :after vertico
  :bind (:map vertico-map
              ("DEL" . vertico-directory-up)             ; Step backward out of directory paths instantly
              ("M-DEL" . vertico-directory-delete-word)) ; Drop path components up to previous delimiter
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; =============================================================================
;; 2. Corfu (Fast, In-Buffer Popup Autocompletion Engine)
;; =============================================================================

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)                         ; Auto-trigger suggestions while actively typing code blocks
  (corfu-quit-no-match t)                ; Instantly dismiss the popup frame if search space becomes nil
  :init
  (global-corfu-mode 1))

;; =============================================================================
;; 3. Orderless (Advanced Regex-Free Pattern Matching)
;; =============================================================================

(use-package orderless
  :ensure t
  :custom
  ;; Enable space-separated out-of-order search terms (e.g., "init san path" matches "san-paths.el")
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; =============================================================================
;; 4. Marginalia (Minibuffer Metadata Rich Annotations)
;; =============================================================================

(use-package marginalia
  :ensure t
  :custom
  (marginalia-align 'center)             ; Anchor descriptions cleanly in the center of the UI
  :init
  (marginalia-mode 1))

;; Colorful modern icons mapping inside the Marginalia metadata window
(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :init
  (nerd-icons-completion-mode 1)
  :hook (marginalia-mode-hook . nerd-icons-completion-marginalia-setup))

;; =============================================================================
;; 5. Consult (Context-Rich Advanced Search & Navigation Utilities)
;; =============================================================================

(use-package consult
  :ensure t
  :bind (("M-s M-g" . consult-ripgrep)   ; Blazing fast project-wide text lookups via Ripgrep
         ("M-s M-f" . consult-find)      ; System file search utility routing
         ("M-s M-o" . consult-outline)   ; Dynamic jump menus maps for Org/Markdown outline tags
         ("M-s M-l" . consult-line)      ; High-speed interactive in-buffer text grep tracking
         ("M-s M-b" . consult-buffer)    ; Unified buffer, recent file, and bookmark manager
         ("C-x M-b" . consult-buffer)))  ; Alternate muscle-memory mirror fallback mapping

;; =============================================================================
;; 6. Embark (Context Actions Menu & Export Pipeline)
;; =============================================================================

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)            ; Fire context-aware actions relative to current point state
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)    ; Snapshot current selection set into a static layout buffer
         ("C-c C-e" . embark-export)))   ; Feed active search outputs straight into writable Dired lists

(use-package embark-consult
  :ensure t
  :after (embark consult))

(provide 'san-completions)
;;; san-completions.el ends 

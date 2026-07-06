;;; san-completions.el --- Keyboard-Driven Completion Stack -*- lexical-binding: t -*-

;;; Commentary:
;; This module orchestrates a minimalist, keyboard-driven completion stack.
;; It coordinates modern modular engines built strictly on top of standard 
;; Emacs completion primitives to handle:
;; - Vertico (vertical minibuffer selection UI).
;; - Corfu (high-speed, in-buffer popup autocompletion).
;; - Orderless (out-of-order regular expression pattern matching).
;; - Marginalia (metadata-rich minibuffer annotations).
;; - Consult (context-rich advanced search and navigation utilities).
;; - Embark (contextual action menus and export pipelines).

;;; Code:

;;; Vertico Vertical Minibuffer UI
;; ---------------------------------------------------------------------
;; Replaces the default horizontal or grid-based completion display with an efficient, 
;; vertical selection matrix that scales dynamically to fit available candidate outputs.

(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)                       ; Cycle back to top when reaching end of list
  (vertico-resize t)                      ; Adjust minibuffer size dynamically to match list
  (vertico-sort-function #'vertico-sort-history-alpha) ; Sort via historical lookup and alphabet
  :init
  (vertico-mode 1))

;; Path Traversal Cleansing Extension
;; Refines directory navigation inside the minibuffer. Pressing Backspace over a directory
;; delimiter drops back an entire directory tier cleanly rather than deleting individual bytes.
(use-package vertico-directory
  :ensure nil                             ; Built-in part of the vertico package bundle
  :after vertico
  :bind (:map vertico-map
              ("DEL" . vertico-directory-up)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;;; Corfu In-Buffer Autocompletion Engine
;; ---------------------------------------------------------------------
;; Renders inline dropdown candidate popups directly at point while typing in standard buffers, 
;; providing non-intrusive completion overlays that drop out instantly upon word breaks.

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)                          ; Automatically trigger popups without keystroke delays
  (corfu-quit-no-match t)                 ; Drop the popup overlay instantly if no metrics align
  :init
  (global-corfu-mode 1))

;;; Orderless Pattern Matching Engine
;; ---------------------------------------------------------------------
;; Overhauls string filtering behavior by treating user input terms as isolated, space-separated
;; regex fragments. Allows out-of-order matching across minibuffer items for rapid lookups.

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  ;; Force standard file-finding lookups to respect partial completion boundaries
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Marginalia Minibuffer Rich Annotations
;; ---------------------------------------------------------------------
;; Appends descriptive metadata columns to the right margin of minibuffer items (e.g., file sizes,
;; permissions, command keybindings, or documentation strings).

(use-package marginalia
  :ensure t
  :custom
  (marginalia-align 'center)              ; Keep columns systematically balanced
  :init
  (marginalia-mode 1))

;; Monochrome UI Icons for Completions
;; Embeds visually balanced file and folder icons next to candidates inside the minibuffer vector.
(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :init
  (nerd-icons-completion-mode 1)
  :hook (marginalia-mode-hook . nerd-icons-completion-marginalia-setup))

;;; Consult Search & Navigation Utilities
;; ---------------------------------------------------------------------
;; Provisions an array of asynchronous text search lookups, line jumpers, and project-wide
;; line grepping tools that pass results to the vertical minibuffer.

(use-package consult
  :ensure t
  :bind (("M-s M-g" . consult-ripgrep)    ; Asynchronous, project-wide text grepping
         ("M-s M-f" . consult-find)       ; High-speed indexed file location lookups
         ("M-s M-o" . consult-outline)    ; Structural heading jump matrix
         ("M-s M-l" . consult-line)       ; Interactive line filter inside current buffer
         ("M-s M-b" . consult-buffer)     ; Integrated buffer, recent-file, and bookmark list
         ("C-x M-b" . consult-buffer)))

;;; Embark Context Actions Menu & Pipelines
;; ---------------------------------------------------------------------
;; Acts as a keyboard-driven right-click menu. Interrogates whatever object exists at point 
;; (file, buffer, URL, function symbol) and spawns an action matrix, or exports minibuffer 
;; lists directly into editable project snapshots.

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)             ; Execute contextual action grid over item at point
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)     ; Snatch current live candidates into a static buffer
         ("C-c C-e" . embark-export)))    ; Turn active file search lists directly into a Dired buffer

(use-package embark-consult
  :ensure t
  :after (embark consult))

(provide 'san-completions)
;;; san-completions.el ends here

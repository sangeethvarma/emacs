;;; scratch buffer

;"scratch.org#CV:L2:C9"

(use-package vimish-fold
  :config (vimish-fold-global-mode t))

(use-package use-package-ensure-system-package
  :demand t
  :custom
  (system-packages-package-manager 'scoop))

(use-package wgrep
  :bind ( :map grep-mode-map
          (\"e\" . wgrep-change-to-wgrep-mode)
          (\"C-x C-q\" . wgrep-change-to-wgrep-mode)
          (\"C-c C-c\" . wgrep-finish-edit)))

;;; encoding - utf-8 everything
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-charset-priority 'unicode)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-16-le)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

(use-package spacious-padding
  :config
    (setq spacious-padding-widths
        '( :internal-border-width 15
           :header-line-width 4
           :mode-line-width 6
           :right-divider-width 1
           :left-fringe-width 20
           :right-fringe-width 20)))

(spacious-padding-mode 0)
(spacious-padding-mode 1)

(setq spacious-padding-subtle-mode-line nil)
(setq spacious-padding-subtle-mode-line t)

weak-holders of asset - govt.s and middle class

(use-package yeetube
  :init (define-prefix-command 'my/yeetube-map)
  :config
  (setf yeetube-mpv-disable-video t) ;; Disable video output
  :bind (("C-c y" . 'my/yeetube-map)
         :map my/yeetube-map
	 ("s" . 'yeetube-search)
	 ("b" . 'yeetube-play-saved-video)
	 ("d" . 'yeetube-download-videos)
	 ("p" . 'yeetube-mpv-toggle-pause)
	 ("v" . 'yeetube-mpv-toggle-video)
	 ("V" . 'yeetube-mpv-toggle-no-video-flag)
	 ("k" . 'yeetube-remove-saved-video)))


(cl-case system-type
  ((gnu gnu/linux gnu/kfreebsd)
   (message "~/.mozilla/firefox/*.default/places.sqlite"))
  (windows-nt (message "Mozilla/Firefox/Profiles/*/places.sqlite")))

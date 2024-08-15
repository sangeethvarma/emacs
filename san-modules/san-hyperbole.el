(use-package hyperbole)
  
(unbind-key (kbd "M-o") 'hyperbole-mode-map)
(bind-key (kbd "C-x M-o") 'hkey-operate 'hyperbole-mode-map)
(setq org-enable-smart-keys nil)
(provide 'san-hyperbole)

; "${hyperb:dir}/FAST-DEMO:L415:C63"
; <(demo)>


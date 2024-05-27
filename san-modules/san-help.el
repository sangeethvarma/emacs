(use-package which-key
  :config
  (which-key-mode))

(use-package helpful
  :ensure t
  :bind (("C-h f" . helpful-callable)
	 ("C-h v" . helpful-variable)
	 ("C-h k" . helpful-key)
	 ("C-h x" . helpful-command)
	 ("C-h F" . helpful-function)
	 ("C-c C-d" . helpful-at-point)))

(provide 'san-help)

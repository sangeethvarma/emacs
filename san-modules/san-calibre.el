(use-package calibredb
  :defer t
  :config
  (setq calibredb-root-dir "~/Calibre")
  (setq calibredb-db-dir (expand-file-name "metadata.db" calibredb-root-dir)))

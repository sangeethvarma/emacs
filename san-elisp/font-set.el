;; Valid font families are 'material 'wicon 'octicon 'faicon 'fileicon and 'alltheicon

(insert (all-the-icons-octicon "file-binary"))  ;; GitHub Octicon for Binary File
(insert (all-the-icons-faicon  "cogs"))         ;; FontAwesome icon for cogs
(insert (all-the-icons-wicon   "tornado"))      ;; Weather Icon for tornado

(all-the-icons-insert-icons-for 'alltheicon)   ;; Prints all the icons for `alltheicon' font set
(all-the-icons-insert-icons-for 'octicon 10)   ;; Prints all the icons for the `octicon' family and makes the icons height 10
(all-the-icons-insert-icons-for 'faicon 1 0.5) ;; Prints all the icons for the `faicon' family and also waits 0.5s between printing each one

(defun insert-character-with-font (char font)
  "Insert CHAR into the current buffer with FONT."
  (let ((start (point)))
    (insert char)
    (add-text-properties start (point)
                         `(face (:family ,font)))))

(defun print-all-fonts ()
  "Print details of all installed fonts."
  (interactive)
  (font-lock-mode -1)
  (set-fontset-font t 'symbol nil)
  (set-fontset-font t 'emoji nil)
  (let ((fonts (font-family-list)))
    (dolist (font fonts)
      (insert-character-with-font "🔁" font)  ; 01F501 - Segoe UI Symbol is best
      (insert " ")
      (insert-character-with-font "🧗" font)  ; 01F9D7 - only in Segoe UI Emoji
      (insert (prin1-to-string font))
      (insert "\n"))))

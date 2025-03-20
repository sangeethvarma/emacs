(defun clean-stash-md ()
  (interactive)
  (progn
    (replace-regexp "💤 " "" nil (point-min) (point-max)) ;remove discarded-tab icon
    (replace-regexp "([0-9]+) \\(.*]\\)" "\\1" nil (point-min) (point-max)) ;remove notification-based tab title - to make duplicates identifiable
    (replace-regexp "\\[\\(\\\\>\\)+ " "[" nil (point-min) (point-max)) ;remove indentation indicator added by tabstash
    (delete-duplicate-lines (point-min) (point-max) nil nil t t)
    (replace-regexp "- \\[\\(Subscriptions - \\)*YouTube\\](.*)\n" "" nil (point-min) (point-max)) ;remove youtube homepages from list
    (replace-regexp "- \\[.*](.*github.com/\\(sangeethvarma.*\\)*)\n" "" nil (point-min) (point-max)) ;remove youtube homepages from list
    ))

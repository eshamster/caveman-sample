(in-package :cl-user)
(defpackage caveman-sample.templates.index
  (:use :cl)
  (:import-from :caveman-sample.templates.utils
                :with-markup-to-string)
  (:import-from :cl-markup
                :html5
                :markup)
  (:export :index-html))
(in-package caveman-sample.templates.index)

(defun index-html (&key (t-str nil) (f-str nil))
  (with-markup-to-string
    (html5
     (:head
      (:title "test")
      (:link :rel "stylesheet" :type "text/css" :href "css/main.css"))
     (:body
      (:ul
       (:li (:a :href "test-angular" "Test Angular.js")))
      (:table
       (dotimes (i 20)
         (markup (:tr (:td (if (evenp i) t-str f-str))))))))))

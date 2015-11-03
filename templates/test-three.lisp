(in-package :cl-user)
(defpackage caveman-sample.templates.test-three
  (:use :cl)
  (:import-from :caveman-sample.templates.utils
                :with-markup-to-string)
  (:import-from :cl-markup
                :html5
                :markup)
  (:import-from :caveman-sample.js.utils
                :load-ps)
  (:export :test-three-html))
(in-package caveman-sample.templates.test-three)

(defun test-three-html ()
  (with-markup-to-string
    (html5 :ng-app "testApp"
           (:head
            (:title "Test ThreeJs")
            (:script :src "https://cdnjs.cloudflare.com/ajax/libs/three.js/r73/three.min.js" nil)
            (:script :src (load-ps "test-three") nil))
           (:body
            (:div (:a :href "/" "Top"))
            (:br)))))

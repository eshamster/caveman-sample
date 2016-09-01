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
    (html5 (:head
            (:title "Test ThreeJs")
            (:meta :charset "UTF-8")
            (:script :src "https://cdnjs.cloudflare.com/ajax/libs/three.js/r73/three.min.js" nil)
            (:script :src "js/copied/threex.keyboardstate.js" nil)
            (:script :src (load-ps "test-three") nil)
            (:link :rel "stylesheet" :type "text/css" :href "css/test-three.css"))
           (:body
            (:div (:a :href "/" "Top"))
            (:br)
            (:div :id "renderer" nil)
            (:div :id "debug" "Debug用領域")
            (:br)
            (:div "Entityのリスト"
                  (:dl :id "entity-tree"))))))

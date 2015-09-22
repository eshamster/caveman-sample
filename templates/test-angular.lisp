(in-package :cl-user)
(defpackage caveman-sample.templates.test-angular
  (:use :cl)
  (:import-from :caveman-sample.templates.utils
                :with-markup-to-string)
  (:import-from :cl-markup
                :html5
                :markup)
  (:export :test-angular-html))
(in-package caveman-sample.templates.test-angular)

(defun test-angular-html ()
  (with-markup-to-string
    (html5 :ng-app "testApp"
           (:head
            (:title "Test AngularJS")
            (:script :src "https://ajax.googleapis.com/ajax/libs/angularjs/1.2.27/angular.min.js" nil)
            (:script :src "https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js" nil)
            (:script :src "js/test-angular.js" nil)
            (:link :rel "stylesheet" :type "text/css" :href "css/main.css"))
           (:body
            (:div (:a :href "/" "Top"))
            (:div :ng-controller "testController"
                  "{{test}}" (:br)
                  "selected-id = {{selectedId}}" (:br)
                  (:button :ng-click "getTestData()" "Get test data") (:br)
                  (:dl
                   (:dt :ng-click "toggleSelected($index)" :ng-repeat-start "item in items" "{{item.name}}")
                   (:dd :ng-class "{'not-selected': !isSelected($index)}" :ng-repeat-end nil "{{item.mail}}")))))))

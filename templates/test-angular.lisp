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
    (html5 :ng-app ""
           (:head
            (:title "Test AngularJS")
            (:script :src "http://code.angularjs.org/angular-1.0.0rc3.min.js" nil)
            (:script :src "js/test-angular.js" nil)
            (:link :rel "stylesheet" :type "text/css" :href "css/main.css"))
           (:body
            (:div (:a :href "/" "Top"))
            (:div :ng-controller "TestControl"
                  "{{test}}" (:br)
                  (:button :ng-click "getTestData()" "Get test data") (:br)
                  (:table
                   (:tr (:th "name") (:th "email"))
                   (:tr :ng-repeat "item in items" 
                        (:td "{{item.name}}") (:td "{{item.mail}}"))))))))

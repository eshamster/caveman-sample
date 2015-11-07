(in-package :cl-user)
(defpackage caveman-sample.js.test-angular
  (:use :cl
        :cl-ppcre
        :parenscript)
  (:shadow :sb-debug
           :var)
  (:import-from :caveman-sample.js.utils
                :setf-with
                :ps.))
(in-package :caveman-sample.js.test-angular)

(defun js-main ()
  (ps.
    (chain
     (angular.module "testApp" '())
     (controller
      "testController"
      (lambda ($scope $http)
        (setf-with $scope
          test 100
          items '()
          get-test-data (lambda ()
                          (chain ($http (create :method "GET"
                                                :url "test.json"))
                                 (success (lambda (data status headers config)
                                            (dolist (elem data)
                                              ($scope.items.push elem))
                                            (console.log status)
                                            (console.log data)))
                                 (error (lambda (data status headers config)
                                          (console.log status)))))
          toggle-selected (lambda (index)
                            (setf $scope.selected-id
                                  (if (not (= $scope.selected-id index)) index -1)))
          is-selected (lambda (index)
                        (= $scope.selected-id index)))))))) 

(in-package :cl-user)
(defpackage caveman-sample-test-asd
  (:use :cl :asdf))
(in-package :caveman-sample-test-asd)

(defsystem caveman-sample-test
  :author ""
  :license ""
  :depends-on (:caveman-sample
               :prove)
  :components ((:module "t"
                :components
                ((:file "caveman-sample"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))

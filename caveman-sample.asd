(in-package :cl-user)
(defpackage caveman-sample-asd
  (:use :cl :asdf))
(in-package :caveman-sample-asd)

(defsystem caveman-sample
  :version "0.1"
  :author ""
  :license ""
  :depends-on (:clack
               :lack
               :caveman2
               :envy
               :cl-ppcre
               :uiop

               ;; for @route annotation
               :cl-syntax-annot

               ;; HTML Template
               :djula
               :cl-markup

               ;; for DB
               :datafly
               :sxql)
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "config"))
                :depends-on ("templates"))
               (:module "templates"
                :components
                ((:file "utils")
                 (:file "index" :depends-on ("utils"))
                 (:file "test-angular" :depends-on ("utils")))))
  :description ""
  :in-order-to ((test-op (load-op caveman-sample-test))))

(in-package :cl-user)
(defpackage caveman-sample.web
  (:use :cl
        :caveman2
        :caveman-sample.config
        :caveman-sample.view
        :caveman-sample.db
        :datafly
        :sxql)
  (:export :*web*))
(in-package :caveman-sample.web)

(defmacro call-template (name &rest rest)
  `(,(intern (string-upcase
              (format nil "~A-html" name))
             (string-upcase
              (format nil "caveman-sample.templates.~A" name)))
     ,@rest))

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules

(defroute "/" ()
  (call-template index
   :t-str "true"
   :f-str "false"))

(defroute "/test-angular" ()
  (call-template test-angular))

(defroute "/test-three" ()
  (call-template test-three))

(defroute "/test.json" ()
  (render-json `((:name "esh" :mail "hamgoostar@gmail.com")
                 (:name "ham" :mail "hamster@example.com"))))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))

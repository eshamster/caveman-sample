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

(import 'cl-markup:html5)
(import 'cl-markup:markup)

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
  (render #P"index.html"))

(defroute "/test" ()
  (render #P"test.html"
          `(:test-var 1234
            :test-list (1 2 3))))

(defmacro with-markup-to-string (&body body)
  (let ((str (gensym)))
    `(with-output-to-string (,str)
       (let ((cl-markup:*output-stream* ,str))
         ,@body))))

(defun test (t-str f-str)
  (with-markup-to-string
    (html5
     (:head
      (:title "test"))
     (:body
      (dotimes (i 20)
        (markup (:div (if (evenp i) t-str f-str))))))))

(defroute "/test-who" ()
  (test "a" "b"))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))

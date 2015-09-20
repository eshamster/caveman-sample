(in-package :cl-user)
(defpackage caveman-sample.templates.utils
  (:use :cl
        :cl-markup)
  (:export :with-markup-to-string))
(in-package :caveman-sample.templates.utils)

(defmacro with-markup-to-string (&body body)
  (let ((str (gensym)))
    `(with-output-to-string (,str)
       (let ((cl-markup:*output-stream* ,str))
         ,@body))))

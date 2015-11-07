(in-package :cl-user)
(defpackage caveman-sample.js.utils
  (:use :cl
        :cl-ppcre
        :parenscript)
  (:shadow :sb-debug
           :var)
  (:export :load-ps))
(in-package :caveman-sample.js.utils)

(defun make-js-path (name &key (for-load nil))
  (format nil "~Ajs/_~A.js"
          (if for-load "" "static/")
          name))

(defun make-cl-path (name)
  (format nil "static/js/~A.lisp" name))

(defun is-js-older (name)
  (let ((js-path (make-js-path name)))
    (or (not (probe-file js-path))
        (< (file-write-date js-path)
           (file-write-date (make-cl-path name))))))

(defun load-ps (name)
  (print (is-js-older name))
  (if (is-js-older name)
      (with-open-file (out (make-js-path name)
                           :direction :output
                           :if-exists :supersede
                           :if-does-not-exist :create)
        (format t "(re-)load js: ~A" name)
        (format out (funcall (intern "JS-MAIN"
                                     (string-upcase
                                      (format nil "~A.js.~A"
                                              (car (split "\\."
                                                          (package-name #.*package*)))
                                              name)))))))
  (make-js-path name :for-load t))

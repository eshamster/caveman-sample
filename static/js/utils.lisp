(in-package :cl-user)
(defpackage caveman-sample.js.utils
  (:use :cl
        :cl-ppcre
        :parenscript)
  (:shadow :sb-debug
           :var)
  (:export :setf-with
           :load-ps
           :defun+ps
           :with-import-ps-func))
(in-package :caveman-sample.js.utils)

(defmacro+ps setf-with (target &body rest)
  (unless (evenp (length rest))
    (error "odd number of args to SETF-WITH"))
  (labels ((extract-slots (result rest)
             (if rest
                 (extract-slots (cons (car rest) result)
                                (cddr rest))
                 (nreverse result))))
    `(with-slots ,(extract-slots nil rest) ,target
       (setf ,@rest))))

(defun intern-ub (sym)
  (intern (format nil "~A_" (symbol-name sym))))

(defmacro defun+ps (name args &body body)
  (let ((name_ (intern-ub name)))
    `(defun ,name_ ()
       (ps:ps
         (defun ,name ,args
           ,@body)))))

(defun interleave (lst delim)
  (labels ((rec (result rest)
             (if (null rest)
                 result
                 (rec (append result (list (car rest) delim))
                      (cdr rest)))))
    (rec nil lst)))

(defmacro with-import-ps-def (ps-lst &body body)
  `(concatenate 'string
                ,@ (interleave (mapcar (lambda (elem) (list (intern-ub elem)))
                                       ps-lst)
                                                             "
")
                                   (ps:ps ,@body)))


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
        (format out (funcall (intern "JS-MAIN"
                                     (string-upcase
                                      (format nil "~A.js.~A"
                                              (car (split "\\."
                                                          (package-name #.*package*)))
                                              name)))))))
  (make-js-path name :for-load t))

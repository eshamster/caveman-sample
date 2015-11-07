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
           :defun.ps
           :with-import-ps-func
           :ps.
           :defmacro.ps))
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


(defun replace-dot-sep (elem)
  (if (symbolp elem)
      (let ((name (symbol-name elem))
            (pack-name (package-name (symbol-package elem))))
        (cond ((and (> (length name) 1)
                    (string= name "!!" :start1 0 :end1 2))
               (intern (subseq name 2) pack-name))
              ((ppcre:scan "\\." name)
               `(@ ,@(mapcar (lambda (x) (intern x pack-name))
                                (ppcre:split "\\." name))))
              (t elem)))
      elem))

(defun replace-dot-in-tree (tree)
  (labels ((rec (rest)
             (let (result)
               (when rest
                 (dolist (elem rest)
                   (push (if (listp elem)
                             (rec elem)
                             (replace-dot-sep elem))
                         result)))
               (nreverse result))))
    (rec tree)))

(defmacro ps. (&body body)
  `(ps ,@(replace-dot-in-tree body)))

(defmacro defmacro.ps (name args &body body)
  `(defmacro+ps ,name ,args
     ,@(replace-dot-in-tree body)))


(defun intern-ub (sym)
  (intern (format nil "~A_" (symbol-name sym))))

(defmacro defun+ps (name args &body body)
  (let ((name_ (intern-ub name)))
    `(defun ,name_ ()
       (ps
         (defun ,name ,args
           ,@body)))))

(defmacro defun.ps (name args &body body)
  `(defun+ps ,name ,args
     ,@(replace-dot-in-tree body)))

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
                                   (ps ,@body)))


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

(in-package :cl-user)
(defpackage caveman-sample.js.test-ecs-input
  (:use :cl
        :cl-ppcre
        :ps-experiment
        :cl-ps-ecs
        :parenscript
        :caveman-sample.js.test-ecs-tools))
(in-package :caveman-sample.js.test-ecs-input)

(enable-ps-experiment-syntax)

(defvar.ps keyboard (new (#j.THREEx.KeyboardState#)))
(defvar.ps key-status (make-hash-table))

(defun.ps is-key-down (keyname)
  (let ((value (gethash (keyboard.keyname-to-keycode keyname) key-status)))
    (and (not (null value))
         (or (eq value :down) (eq value :now-down)))))

(defun.ps process-input ()
  (let ((div (document.query-selector "#debug")))
    (setf #j.div.innerHTML# "")
    (maphash (lambda (k v)
               (symbol-macrolet ((value (gethash k key-status)))
                 (if v
                     (case value
                       (:now-down (setf value :down))
                       (:down)
                       (t (setf value :now-down)))
                     (case value
                       (:now-up (setf value :up))
                       (:up)
                       (t (setf value :now-up))))))
             keyboard.key-codes)
    (div.append-child (create-html-element "div" :html (concatenate 'string "Is 'B' pressed: " (is-key-down :b))))))

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
  "Return if the key is down"
  (let ((value (gethash (keyboard.keyname-to-keycode keyname) key-status)))
    (and (not (null value))
         (or (eq value :down) (eq value :down-now)))))

(defun.ps is-key-down-now (keyname)
  "Return if the key is down just in this frame"
  (let ((value (gethash (keyboard.keyname-to-keycode keyname) key-status)))
    (and (not (null value))
         (eq value :down-now))))

(defun.ps is-key-up-now (keyname)
  "Return if the key is down just in this frame"
  (let ((value (gethash (keyboard.keyname-to-keycode keyname) key-status)))
    (and (not (null value))
         (eq value :up-now))))

(defun.ps process-input ()

  (maphash (lambda (k v)
             (symbol-macrolet ((value (gethash k key-status)))
               (if v
                   (case value
                     (:down-now (setf value :down))
                     (:down)
                     (t (setf value :down-now)))
                   (case value
                     (:up-now (setf value :up))
                     (:up)
                     (t (setf value :up-now))))))
           keyboard.key-codes))


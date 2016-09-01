(in-package :cl-user)
(defpackage caveman-sample.js.test-ecs-tools
  (:use :cl
        :cl-ppcre
        :ps-experiment
        :cl-ps-ecs
        :parenscript)
  (:export :create-html-element)
  (:import-from :ps-experiment
                :defmacro.ps
                :defmacro.ps+
                :defun.ps
                :enable-ps-experiment-syntax))
(in-package :caveman-sample.js.test-ecs-tools)

(enable-ps-experiment-syntax)

(defmacro.ps create-html-element (tag &key id html class)
  `(let ((element (document.create-element ,tag)))
     ,(when id
            `(setf element.id ,id))
     ,(when class
            (if (atom class)
                `(element.class-list.add ,class)
                `(dolist (cls ,class)
                   (element.class-list.add cls))))
     ,(when html
            `(setf #j.element.innerHTML# ,html))
     element))

(defun.ps refresh-entity-display ()
  (let ((tree (document.query-selector "#entity-tree"))
        (test-obj (make-point-2d)))
    (do-ecs-entities entity
      (let* ((id (ecs-entity-id entity))
             (entity-div (create-html-element
                          "dt"
                          :id (concatenate 'string "Entity" id)
                          :html (concatenate 'string "Entity (ID: " id ")")
                          :class '("entity" "tree"))))
        (tree.append-child entity-div)
        (do-ecs-components-of-entity (component entity)
          (let ((component-div (create-html-element
                                "dd"
                                :html component.constructor.name
                                :class '("component" "tree"))))
            (tree.append-child component-div)))))))

(defstruct.ps fps-stats
  (clock-store '())
  (store-size 30)
  (pointer 0)
  (frame-count 0))

(defun.ps update-fps-stats (stat)
  (with-slots (clock-store store-size pointer frame-count) stat
    (setf (aref clock-store pointer) (-date.now))
    (incf pointer)
    (when (>= pointer store-size)
      (setf pointer 0))
    (incf frame-count)))

(defun.ps calc-average-fps (stat)
  (with-slots (clock-store pointer store-size frame-count) stat
    (if (>= frame-count store-size)
        (let ((newest-pointer (1- pointer)))
          (/ 1000.0
             (/ (- (aref clock-store (if (>= newest-pointer 0) newest-pointer (1- store-size)))
                 (aref clock-store pointer))
                store-size)))
        -1)))

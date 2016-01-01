(in-package :cl-user)
(defpackage caveman-sample.js.test-ecs-tools
  (:use :cl
        :cl-ppcre
        :ps-experiment
        :cl-ps-ecs
        :parenscript)
  (:import-from :ps-experiment
                :defmacro.ps+
                :defun.ps
                :enable-ps-experiment-syntax))
(in-package :caveman-sample.js.test-ecs-tools)

(enable-ps-experiment-syntax)

(defun.ps refresh-entity-display ()
  (let ((tree (document.query-selector "#entity-tree"))
        (test-obj (make-point-2d)))
    (do-ecs-entities entity
      (let ((entity-div (document.create-element "dt")))
        (tree.append-child entity-div)
        (setf #j.entity-div.innerHTML# (concatenate 'string
                                                    "Entity (ID: "
                                                    (ecs-entity-id entity)
                                                    ")"))
        (entity-div.class-list.add "entity" "tree")
        (do-ecs-components-of-entity (component entity)
          (let ((component-div (document.create-element "dd")))
            (component-div.class-list.add "component" "tree")
            (setf #j.component-div.innerHTML# component.constructor.name)
            (tree.append-child component-div)))))))

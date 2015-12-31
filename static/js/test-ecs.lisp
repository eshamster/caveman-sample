(in-package :cl-user)
(defpackage caveman-sample.js.test-ecs
  (:use :cl
        :cl-ppcre
        :ps-experiment
        :cl-ps-ecs
        :parenscript)
  (:import-from :ps-experiment
                :defmacro.ps+
                :defun.ps
                :enable-ps-experiment-syntax))
(in-package :caveman-sample.js.test-ecs)

(enable-ps-experiment-syntax)

;; --- components --- ;;

(defstruct.ps+ (vector-2d (:include ecs-component)) (x 0) (y 0))
(defstruct.ps+ (point-2d (:include vector-2d)))
(defstruct.ps+ (speed-2d (:include vector-2d)))

(defstruct.ps (model-2d (:include ecs-component)) model depth)

(defun.ps+ calc-abs-position (entity)
  (labels ((rec (result parent)
             (if parent
                 (let ((pos (get-ecs-component 'point-2d parent)))
                   (when pos
                     (incf (point-2d-x result) (point-2d-x pos))
                     (incf (point-2d-y result) (point-2d-y pos)))
                   (rec result (ecs-entity-parent parent)))
                 result)))
    (unless (get-ecs-component 'point-2d entity)
      (error "The entity ~A doesn't have point-2d" entity))
    (rec (make-vector-2d :x 0 :y 0) entity)))

;; --- systems --- ;;

;; [WIP]
(defstruct.ps
    (draw-model-system
     (:include ecs-system
               (target-component-types '(point-2d model-2d))
               (process (lambda (entity)
                          (with-ecs-components (model-2d) entity
                            (let ((new-pos (calc-abs-position entity)))
                              (model-2d.model.position.set
                               (point-2d-x new-pos)
                               (point-2d-y new-pos)
                               (model-2d-depth model-2d)))))))))

(defun.ps register-draw-model-system (scene)
  (register-ecs-system "draw2d"
                       (make-draw-model-system
                        :add-entity-hook (lambda (entity)
                                           (with-ecs-components (model-2d) entity
                                             (scene.add (model-2d-model model-2d))))
                        :delete-entity-hook (lambda (entity)
                                           (with-ecs-components (model-2d) entity
                                             (scene.remove (model-2d-model model-2d)))))))

(defstruct.ps+
    (move-system
     (:include ecs-system
               (target-component-types '(model-2d))
               (process (lambda (entity)
                          (with-ecs-components (point-2d speed-2d) entity
                            (incf (point-2d-x point-2d) (speed-2d-x speed-2d))
                            (incf (point-2d-y point-2d) (speed-2d-y speed-2d))))))))

(def-top-level-form.ps
    "register test systems"
  (register-ecs-system "move2d" (make-move-system)))

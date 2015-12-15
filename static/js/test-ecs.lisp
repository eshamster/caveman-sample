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

(defstruct.ps (vector-2d (:include ecs-component)) x y)
(defstruct.ps (point-2d (:include vector-2d)))
(defstruct.ps (speed-2d (:include vector-2d)))

(defstruct.ps (model-2d (:include ecs-component)) model enabled)


;; --- systems --- ;;

;; [WIP]
(defstruct.ps
    (draw-model-system
     (:include ecs-system
               (target-component-types '(point-2d speed-2d))
               (process (lambda (entity))))))


;; [WIP]
(defstruct.ps
    (move-system
     (:include ecs-system
               (target-component-types '(model-2d))
               (process (lambda (entity))))))

(def-top-level-form.ps
    "register test systems"
  (register-ecs-system "draw2d" (make-draw-model-system))
  (register-ecs-system "move2d" (make-move-system)))

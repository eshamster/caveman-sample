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

(defstruct.ps+ (rotate-2d (:include ecs-component)) (speed 0) (angle 0) (r 0))

(defstruct.ps (model-2d (:include ecs-component)) model depth (center (make-vector-2d)))

(defun.ps+ vector-abs (vector)
  (sqrt (+ (expt (vector-2d-x vector) 2)
           (expt (vector-2d-y vector) 2))))

(defun.ps+ vector-angle (vector)
  (with-slots (x y) vector
    (if (= x 0)
        0
        (atan (/ y x)))))

(defun.ps+ incf-vector (target-vec diff-vec)
  (incf (vector-2d-x target-vec) (vector-2d-x diff-vec))
  (incf (vector-2d-y target-vec) (vector-2d-y diff-vec))
  target-vec)

(defun.ps+ calc-abs-position (entity)
  (labels ((rec (result parent)
             (if parent
                 (let ((pos (get-ecs-component 'point-2d parent)))
                   (when pos
                     (incf-vector result pos))
                   (rec result (ecs-entity-parent parent)))
                 result)))
    (unless (get-ecs-component 'point-2d entity)
      (error "The entity ~A doesn't have point-2d" entity))
    (rec (make-vector-2d :x 0 :y 0) entity)))

;; --- systems --- ;;

(defstruct.ps
    (draw-model-system
     (:include ecs-system
               (target-component-types '(point-2d model-2d))
               (process (lambda (entity)
                          (with-ecs-components (model-2d) entity
                            (let ((new-pos (calc-abs-position entity)))
                              (with-slots (model center) model-2d
                                (model.position.set
                                 (- (point-2d-x new-pos) (vector-2d-x center))
                                 (- (point-2d-y new-pos) (vector-2d-y center))
                                 (model-2d-depth model-2d))))))))))

(defstruct.ps+
    (move-system
     (:include ecs-system
               (target-component-types '(point-2d speed-2d))
               (process (lambda (entity)
                          (with-ecs-components (point-2d speed-2d) entity
                            (incf-vector point-2d speed-2d)))))))

(defun.ps+ incf-rotate-diff (vector r now-angle diff-angle &key (increase t))
  (macrolet ((f (place value increase)
               `(if ,increase
                    (incf ,place ,value)
                    (decf ,place ,value))))
    (let ((cos-now (cos now-angle))
          (sin-now (sin now-angle))
          (cos-diff (cos diff-angle))
          (sin-diff (sin diff-angle)))
      (f (vector-2d-x vector) (- (* r cos-now cos-diff)
                                 (* r sin-now sin-diff)
                                 (* r cos-now))
         increase)
      (f (vector-2d-y vector) (-  (+ (* r sin-now cos-diff)
                                     (* r cos-now sin-diff))
                                  (* r sin-now))
         increase))))

(defstruct.ps
    (rotate-system
     (:include ecs-system
               (target-component-types '(point-2d rotate-2d))
               (process (lambda (entity)
                          (with-ecs-components (point-2d rotate-2d) entity
                            (with-slots (speed angle r) rotate-2d
                              (incf-rotate-diff point-2d r angle speed)
                              (let ((model-2d (get-ecs-component 'model-2d entity)))
                                (when model-2d
                                  (with-slots (model center) model-2d
                                    (incf-rotate-diff point-2d (vector-abs center) (+ angle (vector-angle center)) speed
                                                      :increase nil)
                                    (incf model.rotation.z (rotate-2d-speed rotate-2d)))))
                              (incf angle speed))))))))

(defun.ps register-default-systems (scene)
  (register-ecs-system "draw2d"
                       (make-draw-model-system
                        :add-entity-hook (lambda (entity)
                                           (with-ecs-components (model-2d) entity
                                             (scene.add (model-2d-model model-2d))))
                        :delete-entity-hook (lambda (entity)
                                              (with-ecs-components (model-2d) entity
                                                (scene.remove (model-2d-model model-2d))))))
  (register-ecs-system "move2d" (make-move-system))
  (register-ecs-system "rotate2d" (make-rotate-system)))

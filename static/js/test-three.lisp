(in-package :cl-user)
(defpackage caveman-sample.js.test-three
  (:use :cl
        :cl-ppcre
        :parenscript)
  (:shadow :sb-debug
           :var)
  (:import-from :ps-experiment
                :setf-with
                :defun.ps
                :with-use-ps-pack)
  (:import-from :cl-ps-ecs
                :with-ecs-components))
(in-package :caveman-sample.js.test-three)

(defun.ps init-camera (width height)
  (let* ((fov 60)
         (rad-fov (/ (* fov PI) 180))
         (aspect (/ width height))
         (z (abs (* (/ height 2)
                    (/ 1 (tan (/ rad-fov 2))))))
         (camera (new (#j.THREE.PerspectiveCamera# fov aspect
                                                   (/ z 2) (* z 2)))))
    (camera.position.set (/ width 2) (/ height 2) z)
    camera))

(defun.ps make-sample-move-entities ()
  (let ((parent (make-ecs-entity))
        (child (make-ecs-entity)))
    ;; make parent
    (add-ecs-component (make-model-2d :model (make-wired-rect :width 450 :height 300
                                                              :color 0xff00ff)
                                      :depth 1)
                       parent)
    (add-ecs-component (make-point-2d) parent)
    (add-ecs-component (make-speed-2d :x 0.6 :y 0.4) parent)
    (add-ecs-component (make-script-2d :func (lambda (entity)
                                               (with-ecs-components (point-2d) entity
                                                 (when (is-key-down-now :b)
                                                   (setf point-2d.x 0)
                                                   (setf point-2d.y 0)))))
                       parent)
    ;; make child
    (add-ecs-component (make-model-2d :model (make-solid-rect :width 40 :height 30
                                                              :color 0x00ff00)
                                      :depth 1.1)
                       child)
    (add-ecs-component (make-point-2d :center (make-vector-2d :x 20 :y 15)) child) 
    (add-ecs-component (make-speed-2d :x 0.4) child)
    (add-ecs-component (make-rotate-2d :speed (/ PI 120)) child)
    ;; register
    (add-ecs-entity parent)
    (add-ecs-entity child parent)))

(defun.ps make-sample-rotate-entities ()
  (let ((parent (make-ecs-entity))
        (parent-r 50)
        (child (make-ecs-entity))
        (child-r 25)
        (child-dist 120)
        (gchild (make-ecs-entity))
        (gchild-r 15)
        (gchild-dist 50))
    ;; make parent
    (add-ecs-component (make-model-2d :model (make-wired-regular-polygon :r parent-r :n 6 :color 0x00ffff)
                                      :depth 0.5)
                       parent)
    (add-ecs-component (make-point-2d :x 300 :y 200 :center (make-vector-2d :x parent-r :y parent-r)) parent)
    (add-ecs-component (make-rotate-2d :speed (/ PI 120)) parent)
    ;; make child
    (add-ecs-component (make-model-2d :model (make-wired-regular-polygon :r child-r :n 6 :color 0x00ffff)
                                      :depth 0.5)
                       child)
    (add-ecs-component (make-point-2d :x child-dist :center (make-vector-2d :x child-r :y child-r)) child)
    (add-ecs-component (make-rotate-2d :speed (* -1 (/ PI 60))) child)
    (add-ecs-component (make-rotate-2d :speed (/ PI 360) :rot-offset (make-vector-2d :x child-dist)) child)
    ;; make grandchild
    (add-ecs-component (make-model-2d :model (make-wired-regular-polygon :r gchild-r :n 6 :color 0x00ffff)
                                      :depth 0.5)
                       gchild)
    (add-ecs-component (make-point-2d :x gchild-dist :center (make-vector-2d :x gchild-r :y gchild-r)) gchild)
    (add-ecs-component (make-rotate-2d :speed (* -1 (/ PI 300)) :rot-offset (make-vector-2d :x gchild-dist)) gchild)
    ;; register
    (add-ecs-entity parent)
    (add-ecs-entity child parent)
    (add-ecs-entity gchild child)))

(defun.ps make-mouse-pointer ()
  (let ((pointer (make-ecs-entity))
        (r 5))
    (add-ecs-component (make-point-2d :center (make-vector-2d :x r :y r)) pointer)
    (add-ecs-component (make-model-2d :model (make-wired-regular-polygon :n 60 :color 0xff0000
                                                                         :r r)
                                      :depth 1)
                       pointer)
    (add-ecs-component (make-script-2d :func (lambda (entity)
                                               (with-ecs-components (point-2d) entity
                                                 (setf point-2d.x (get-mouse-x))
                                                 (setf point-2d.y (get-mouse-y)))))
                       pointer)
    (add-ecs-entity pointer)))

(defun.ps make-sample-entities ()
  (make-sample-move-entities)
  (make-sample-rotate-entities)
  (make-mouse-pointer))

(defun.ps main ()
  (let* ((scene (new (#j.THREE.Scene#)))
         (width 600)
         (height 400)
         (camera (init-camera width height))
         (renderer (new #j.THREE.WebGLRenderer#)))
    (register-default-systems scene)
    (renderer.set-size width height)
    ((@ ((@ document.query-selector) "#renderer") append-child) renderer.dom-element)
    (let ((light (new (#j.THREE.DirectionalLight# 0xffffff))))
      (light.position.set 0 0.7 0.7)
      (scene.add light))
    (scene.add (make-line :pos-a '(0 0) :pos-b '(600 400) :color 0x00ff00 :z 1))
    (make-sample-entities)
    (refresh-entity-display)
    (labels ((render-loop ()
               (request-animation-frame render-loop)
               (renderer.render scene camera)
               (process-input)
               (ecs-main)))
      (render-loop))))

(defun js-main ()
  (with-use-ps-pack (:caveman-sample.js.2d-geometry
                     :caveman-sample.js.test-ecs-tools
                     :caveman-sample.js.test-ecs-input
                     :caveman-sample.js.test-ecs
                     :this)
    (window.add-event-listener "mousemove" on-mouse-move-event)
    (window.add-event-listener "DOMContentLoaded" main false))) 

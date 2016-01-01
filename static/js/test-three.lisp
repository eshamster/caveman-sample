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
                :with-use-ps-pack))
(in-package :caveman-sample.js.test-three)

(defun.ps rotate-mesh (mesh)
  (return)
  (with-slots ((rot rotation) (pos position)) mesh
    (rot.set 0
             (+ rot.y 0.01)
             (+ rot.z 0.01))
    (if is-keydown
        (pos.set 0 0 0)
        (pos.set (+ pos.x 0.1)
                 (+ pos.y 0.1)
                 0))))

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

(defun.ps make-sample-entities ()
  (let ((parent (make-ecs-entity))
        (child (make-ecs-entity)))
    (add-ecs-component (make-model-2d :model (make-wired-rect :width 450 :height 300
                                                              :color 0xff00ff)
                                      :depth 1)
                       parent)
    (add-ecs-component (make-point-2d) parent)
    (add-ecs-component (make-speed-2d :x 0.6 :y 0.4) parent)

    (add-ecs-component (make-model-2d :model (make-solid-rect :width 40 :height 30
                                                              :color 0x00ff00)
                                      :depth -20)
                       child)
    (add-ecs-component (make-speed-2d :x 0.4) child)
    (add-ecs-component (make-point-2d :x 20 :y 30) child)
    
    (add-ecs-entity parent)
    (add-ecs-entity child parent)))

(defun.ps main ()
  (let* ((scene (new (#j.THREE.Scene#)))
         (width 600)
         (height 400)
         (camera (init-camera width height))
         (renderer (new #j.THREE.WebGLRenderer#)))
    (register-draw-model-system scene)
    (renderer.set-size width height)
    (document.body.append-child renderer.dom-element)
    (let ((light (new (#j.THREE.DirectionalLight# 0xffffff))))
      (light.position.set 0 0.7 0.7)
      (scene.add light))
    (scene.add (make-line :pos-a '(0 0) :pos-b '(600 400) :color 0x00ff00 :z 1))
    (dotimes (i 3)
      (scene.add (make-wired-regular-polygon :r 50 :n 6 :start-angle (* i 30) :color 0x00ffff :z 2)))
    (make-sample-entities)
    (refresh-entity-display)
    (labels ((render-loop ()
               (request-animation-frame render-loop)
               (renderer.render scene camera)
               (ecs-main)))
      (render-loop))))

(defun js-main ()
  (with-use-ps-pack (:caveman-sample.js.2d-geometry
                     :caveman-sample.js.test-ecs-tools
                     :caveman-sample.js.test-ecs
                     :this)
    (defvar is-keydown false)
    (window.add-event-listener "keydown" (lambda (e) (setf is-keydown true)))
    (window.add-event-listener "keyup" (lambda (e) (setf is-keydown false)))
    (window.add-event-listener "DOMContentLoaded" main false))) 

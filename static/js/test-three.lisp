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

(defun.ps main ()
  (let* ((scene (new (#j.THREE.Scene#)))
         (width 600)
         (height 400)
         (camera (init-camera width height))
         (renderer (new #j.THREE.WebGLRenderer#)))
    (renderer.set-size width height)
    (document.body.append-child renderer.dom-element)
    (let ((light (new (#j.THREE.DirectionalLight# 0xffffff))))
      (light.position.set 0 0.7 0.7)
      (scene.add light))
    (scene.add (make-line :pos-a '(0 0) :pos-b '(600 400) :color 0x00ff00 :z 1))
    (dotimes (i 3)
      (scene.add (make-wired-regular-polygon :r 50 :n 6 :start-angle (* i 30) :color 0x00ffff :z 2)))
    (scene.add (make-solid-rect :width 300 :height 200 :z 0 :color 0xaa0000))
    (let* ((rect (make-wired-rect :width 450 :height 300 :color 0xff00ff :z 1))
           (model (make-model-2d :model rect :depth 1))
           (point (make-point-2d))
           (speed (make-speed-2d :x 1 :y 1))
           (entity (make-ecs-entity)))
      (scene.add rect)
      (add-ecs-component model entity)
      (add-ecs-component point entity)
      (add-ecs-component speed entity)
      (add-ecs-entity entity))
    (labels ((render-loop ()
               (request-animation-frame render-loop)
               (renderer.render scene camera)
               (ecs-main)))
      (render-loop))))

(defun js-main ()
  (with-use-ps-pack (:caveman-sample.js.2d-geometry
                     :caveman-sample.js.test-ecs
                     :this)
    (defvar is-keydown false)
    (window.add-event-listener "keydown" (lambda (e) (setf is-keydown true)))
    (window.add-event-listener "keyup" (lambda (e) (setf is-keydown false)))
    (window.add-event-listener "DOMContentLoaded" main false))) 

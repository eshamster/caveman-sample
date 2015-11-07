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
  (with-slots ((rot rotation) (pos position)) mesh
    (rot.set 0
             (+ rot.y 0.01)
             (+ rot.z 0.01))
    (if is-keydown
        (pos.set 0 0 0)
        (pos.set (+ pos.x 0.05)
                 (+ pos.y 0.05)
                 0))))

(defun.ps main ()
  (let* ((scene (new (#j.THREE.Scene#)))
         (width 600)
         (height 400)
         (fov 60)
         (aspect (/ width height))
         (near 1)
         (far 1000)
         (camera (new (#j.THREE.PerspectiveCamera# fov aspect near far)))
         (renderer (new #j.THREE.WebGLRenderer#)))
    (camera.position.set 0 0 50)
    (renderer.set-size width height)
    (document.body.append-child renderer.dom-element)
    (let ((light (new (#j.THREE.DirectionalLight# 0xffffff))))
      (light.position.set 0 0.7 0.7)
      (scene.add light))
    (let* ((geometry (new (#j.THREE.CubeGeometry# 30 30 30)))
           (material (new (#j.THREE.MeshPhongMaterial# (create :color 0xff0000))))
           (mesh (new (#j.THREE.Mesh# geometry material))))
      (scene.add mesh)
      (labels ((render-loop ()
                 (request-animation-frame render-loop)
                 (rotate-mesh mesh)
                 (renderer.render scene camera)))
        (render-loop)))))

(defun js-main ()
  (with-use-ps-pack (this)
    (defvar is-keydown false)
    (window.add-event-listener "keydown" (lambda (e) (setf is-keydown true)))
    (window.add-event-listener "keyup" (lambda (e) (setf is-keydown false)))
    (window.add-event-listener "DOMContentLoaded" main false))) 

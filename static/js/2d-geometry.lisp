(in-package :cl-user)
(defpackage caveman-sample.js.2d-geometry
  (:use :cl
        :cl-ppcre
        :parenscript)
  (:import-from :ps-experiment
                :defmacro.ps
                :defun.ps))
(in-package :caveman-sample.js.2d-geometry)

(defun.ps array-2d-to-vector-3d (src z)
  (new (#j.THREE.Vector3# (aref src 0)
                          (aref src 1)
                          z)))

(defun.ps make-line (&key pos-a pos-b (color 0x000000) (z 0))
  (let* ((geometry (new (#j.THREE.Geometry#)))
         (vertices geometry.vertices)
         (material (new (#j.THREE.LineBasicMaterial# (create :color color)))))
    (vertices.push (array-2d-to-vector-3d pos-a z)
                   (array-2d-to-vector-3d pos-b z))
    (new (#j.THREE.Line# geometry material))))


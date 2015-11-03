(in-package :cl-user)
(defpackage caveman-sample.js.test-three
  (:use :cl
        :cl-ppcre
        :parenscript)
  (:shadow :sb-debug
           :var)
  (:import-from :caveman-sample.js.utils
                :setf-with
                :defun+ps
                :with-import-ps-def))
(in-package :caveman-sample.js.test-three)

(defmacro+ps three (&rest rest)
  `(@ -t-h-r-e-e ,@rest))

(defun+ps main ()
  (let* ((scene (new ((three -scene))))
         (width 600)
         (height 400)
         (fov 60)
         (aspect (/ width height))
         (near 1)
         (far 1000)
         (camera (new ((three -perspective-camera) fov aspect near far)))
         (renderer (new (three -web-g-l-renderer))))
    ((@ camera position set) 0 0 50)
    ((@ renderer set-size) width height)
    ((@ document body append-child) (@ renderer dom-element))
    (let ((light (new ((three -directional-light) 0xffffff))))
      ((@ light position set) 0 0.7 0.7)
      ((@ scene add) light))
    (let* ((geometry (new ((three -cube-geometry) 30 30 30)))
           (material (new ((three -mesh-phong-material) (create :color 0xff0000))))
           (mesh (new ((three -mesh) geometry material))))
      ((@ scene add) mesh))
    (labels ((render-loop ()
               (request-animation-frame render-loop)
               ((@ mesh rotation set)
                0
                (+ (@ mesh rotation y) 0.01)
                (+ (@ mesh rotation z) 0.01))
               ((@ renderer render) scene camera)))
      (render-loop))))

(defun js-main ()
  (with-import-ps-def (main)
    (window.add-event-listener "DOMContentLoaded" main false))) 

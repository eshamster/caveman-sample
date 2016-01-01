(in-package :cl-user)
(defpackage caveman-sample.js.2d-geometry
  (:use :cl
        :cl-ppcre
        :parenscript)
  (:import-from :ps-experiment
                :defmacro.ps+
                :defun.ps
                :enable-ps-experiment-syntax))
(in-package :caveman-sample.js.2d-geometry)

(enable-ps-experiment-syntax)

; Without eval-when, "defun"s are compiled after "defmacro.ps"
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun make-push-vertices (vertices raw-vertex-lst)
    `((@ ,vertices push) ,@(mapcar (lambda (v)
                                     `(new (#j.THREE.Vector3# ,@(append v '(0)))))
                                   raw-vertex-lst)))
  (defun make-push-faces (faces raw-face-lst)
    `((@ ,faces push) ,@ (mapcar (lambda (face)
                                   `(new (#j.THREE.Face3# ,@face)))
                                 raw-face-lst))))

(defun.ps to-rad (degree)
  (/ (* degree pi) 180))

(defmacro.ps+ def-wired-geometry (name args &body body)
  (with-ps-gensyms (geometry vertices material)
    `(defun.ps ,name (&key ,@args color z)
       (let* ((,geometry (new (#j.THREE.Geometry#)))
              (,vertices (@ ,geometry vertices))
              (,material (new (#j.THREE.LineBasicMaterial# (create :color color))))) 
         (macrolet ((push-vertices (&rest rest)
                      (make-push-vertices ',vertices rest)))
           ,@body)
         (new (#j.THREE.Line# ,geometry ,material))))))

(defmacro.ps+ def-solid-geomery (name args &body body)
  (with-ps-gensyms (geometry vertices faces material)
    `(defun.ps ,name (&key ,@args color z)
       (let* ((,geometry (new (#j.THREE.Geometry#)))
              (,vertices (@ ,geometry vertices))
              (,faces (@ ,geometry faces))
              (,material (new (#j.THREE.MeshBasicMaterial# (create :color color)))))
         (macrolet ((push-vertices (&rest rest)
                      (make-push-vertices ',vertices rest))
                    (push-faces (&rest rest)
                      (make-push-faces ',faces rest)))
           ,@body)
         (new (#j.THREE.Mesh# ,geometry ,material))))))

(def-solid-geomery make-solid-rect (width height)
  (push-vertices (0 0) (width 0) (width height) (0 height))
  (push-faces (0 1 2) (2 3 0)))

(def-wired-geometry make-line (pos-a pos-b)
  (push-vertices ((aref pos-a 0) (aref pos-a 1))
                 ((aref pos-b 0) (aref pos-b 1))))

(def-wired-geometry make-wired-rect (width height)
  (push-vertices (0 0) (width 0) (width height) (0 height) (0 0)))

(def-wired-geometry make-wired-regular-polygon (r n start-angle)
  (dotimes (i (1+ n))
    (let ((angle (to-rad (+ (/ (* 360 i) n) start-angle))))
      (push-vertices ((+ r (* r (cos angle)))
                      (+ r (* r (sin angle))))))))

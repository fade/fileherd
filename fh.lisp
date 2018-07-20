;;;; fh.lisp
;;
;;;; Copyright (c) 2018 Brian O'Reilly <fade@deepsky.com>


(in-package #:fh)

(defclass file-store ()
  ((indir :initarg :indir
          :initform nil
          :accessor indir)
   (infiles :initarg :infiles
            :initform nil
            :accessor infiles)
   (outdir :initarg :outdir
           :initform nil
           :accessor outdir)
   (outfiles :initarg :outfiles
             :initform nil
             :accessor outfiles)
   (filehashes :initarg :filehashes
               :initform nil
               :accessor filehashes))
  (:documentation "this object holds all of the pathing information for incoming and file sorted directories."))

(defmethod initialize-instance :after ((fs file-store) &key)
  (format t "~&Setting inbound file paths ...")
  (setf (infiles fs) (uiop:directory-files (indir fs)))
  (format t " [ Done ]")
  (format t "~&Setting long term storage path: ~A ... " (outdir fs))
  (setf (outfiles fs) (uiop:directory-files (outdir fs)))
  (format t "[ Done ]")
  (format t "~&Hashing files in ~A ... " (outdir fs))
  (setf (filehashes fs) (make-hash-table :test 'equal :size (length (outfiles fs))))
  (read-store-state fs)
  (format t "[ Done ]")
  (finish-output))

(defun make-file-store (indir outdir)
  "make an instance of the file-store object."
  (make-instance 'file-store :indir indir :outdir outdir))

(defgeneric read-store-state (store)
  (:documentation "generate the sha1 hashes representing files in the
  file-store's outdir directory and store them with their paths in the
  object's filehashes slot"))

(defmethod read-store-state ((fs file-store))
  (loop for file in (uiop:directory-files (outdir fs))
        for (hash path) = (multiple-value-list (sha1-file file))
        for count from 1
        :do (setf (gethash hash (filehashes fs)) path)
        :finally (format t "~&Processed ~D Hashes. " count)))

(defgeneric clear-store-state (store)
  (:documentation "zero the file hashes stored in the file-store object."))

(defmethod clear-store-state ((fs file-store))
  (clrhash (filehashes fs)))

(defun sha1-file (path)
  (let ((sha1 (ironclad:make-digest 'ironclad:sha1)))
    (with-open-file (stream path :element-type '(unsigned-byte 8))
      (ironclad:update-digest sha1 stream)
      (values (ironclad:byte-array-to-hex-string (ironclad:produce-digest sha1)) path))))

(defun hash-file-list (filelist)
  "given a list of file paths, return a list of lists of hashes and filepaths"
  (mapcar #'(lambda (fpath) (multiple-value-list (sha1-file fpath))) filelist))

;;===============================================================================
;; add incoming files to the storage pool.
;;===============================================================================

(defgeneric merge-file (pathname store)
  (:documentation "Take the pathname, check to see if it exists in the
  file-store, then move it there if it does not."))

(defmethod merge-file (pathname (fs file-store))
  (multiple-value-bind (hash path) (sha1-file pathname)
    (if (gethash hash (filehashes fs))
        (format t "~&File ~A exists in the store. Not merging.~%" path)
        (let ((target (merge-pathnames (file-namestring path) (outdir fs))))
          (format t "~&Moving ~A to ~A ... " path target)
          (rename-file path target)))))

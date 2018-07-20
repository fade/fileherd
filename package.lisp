;;;; package.lisp
;;
;;;; Copyright (c) 2018 Brian O'Reilly <fade@deepsky.com>


(defpackage #:fh
  (:use #:cl)
  (:export
   #:file-store
   #:indir
   #:outdir
   #:filehashes
   #:make-file-store
   #:sha1-file
   #:read-store-state
   #:clear-store-state))

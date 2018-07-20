;;;; fh.asd
;;
;;;; Copyright (c) 2018 Brian O'Reilly <fade@deepsky.com>


(asdf:defsystem #:fh
  :description "Describe fh here"
  :author "Brian O'Reilly <fade@deepsky.com>"
  :license  "LLGPL"
  :version "0.0.1"
  :serial t
  :depends-on (#:ironclad #:uiop)
  :components ((:file "package")
               (:file "fh")))

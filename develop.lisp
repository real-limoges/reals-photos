;;;; develop.lisp --- entry point. Run with:  sbcl --script develop.lisp
;;;;
;;;; Develops every raw the manifest references from ./raw into ./developed,
;;;; with style/base.pp3 and any style/frames/<stem>.pp3 override. Only new or
;;;; stale raws are redeveloped, so re-running is cheap.

(load (merge-pathnames "src/package.lisp" *default-pathname-defaults*))
(load (merge-pathnames "src/generator.lisp" *default-pathname-defaults*))

(reals-photos:develop-all)

;;;; build.lisp --- entry point. Run with:  sbcl --script build.lisp
;;;;
;;;; Loads the generator and builds the site into ./site from ./manifest.lisp.
;;;; It renders any preview images that are not already on disk. Re-running
;;;; after editing manifest.lisp is super cheap

(load (merge-pathnames "src/package.lisp" *default-pathname-defaults*))
(load (merge-pathnames "src/generator.lisp" *default-pathname-defaults*))

(reals-photos:build)

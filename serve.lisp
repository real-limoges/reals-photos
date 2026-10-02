;;;; serve.lisp --- serve ./site locally. Run with:  sbcl --script serve.lisp [port]
;;;;
;;;; A minimal static file server on SBCL's bundled sockets, so serving needs
;;;; nothing beyond the sbcl that already builds the site. GET and HEAD only,
;;;; one request per connection, one connection at a time: plenty for local
;;;; preview, and nothing to configure.

(require :sb-bsd-sockets)

(defpackage #:reals-photos.serve
  (:use #:cl #:sb-bsd-sockets))

(in-package #:reals-photos.serve)

(defparameter *site-dir*
  (merge-pathnames "site/" *default-pathname-defaults*))

(defparameter *port*
  (let ((arg (second sb-ext:*posix-argv*)))
    (if arg (parse-integer arg) 7000)))

(defparameter *content-types*
  '(("html"  . "text/html; charset=utf-8")
    ("css"   . "text/css; charset=utf-8")
    ("js"    . "text/javascript; charset=utf-8")
    ("svg"   . "image/svg+xml")
    ("jpg"   . "image/jpeg")
    ("jpeg"  . "image/jpeg")
    ("png"   . "image/png")
    ("webp"  . "image/webp")
    ("avif"  . "image/avif")
    ("woff2" . "font/woff2")))

(defun content-type (path)
  (or (cdr (assoc (pathname-type path) *content-types* :test #'equalp))
      "application/octet-stream"))

;;; request parsing

(defun url-decode (string)
  "Decode %XX escapes as UTF-8. Leaves + alone; paths don't use it for space."
  (let ((octets (make-array 0 :element-type '(unsigned-byte 8) :adjustable t :fill-pointer 0)))
    (loop with i = 0
          while (< i (length string))
          do (let ((c (char string i)))
               (if (and (char= c #\%) (<= (+ i 3) (length string)))
                   (progn (vector-push-extend (parse-integer string :start (1+ i) :end (+ i 3) :radix 16)
                                              octets)
                          (incf i 3))
                   (progn (loop for b across (sb-ext:string-to-octets (string c) :external-format :utf-8)
                                do (vector-push-extend b octets))
                          (incf i)))))
    (sb-ext:octets-to-string octets :external-format :utf-8)))

(defun split-on (string char)
  (loop for start = 0 then (1+ end)
        for end = (position char string :start start)
        collect (subseq string start end)
        while end))

(defun split-path (target)
  "The decoded, non-empty segments of a request target, query string dropped."
  (let ((path (subseq target 0 (or (position #\? target) (length target)))))
    (remove "" (mapcar #'url-decode (split-on path #\/)) :test #'string=)))


(defun safe-segments-p (segments)
  "Refuse anything that could climb out of the docroot."
  (notany (lambda (s) (or (string= s "..") (string= s ".") (find #\\ s) (find #\Nul s)))
          segments))

;;; resolving a request to a file

(defun segments->pathname (segments)
  "Resolve segments under *site-dir*. A trailing directory maps to index.html."
  (let ((dir (append (pathname-directory *site-dir*) (butlast segments)))
        (leaf (car (last segments))))
    (if (null leaf)
        (make-pathname :directory dir :name "index" :type "html")
        (let ((as-dir (make-pathname :directory (append dir (list leaf)))))
          (if (probe-file (merge-pathnames "index.html" as-dir))
              (merge-pathnames "index.html" as-dir)
              (let ((dot (position #\. leaf :from-end t)))
                (make-pathname :directory dir
                               :name (if dot (subseq leaf 0 dot) leaf)
                               :type (and dot (subseq leaf (1+ dot))))))))))

(defun listing-html ()
  "The site has no index.html, so / lists the top-level pages instead."
  (with-output-to-string (s)
    (format s "<!doctype html><meta charset=\"utf-8\"><title>site</title><ul>~%")
    (dolist (p (directory (merge-pathnames "*.html" *site-dir*)))
      (let ((name (file-namestring p)))
        (format s "<li><a href=\"~a\">~a</a></li>~%" name name)))
    (format s "</ul>~%")))

;;; responses

(defun write-head (stream status reason type length)
  (format stream "HTTP/1.1 ~d ~a~c~cContent-Type: ~a~c~cContent-Length: ~d~c~cConnection: close~c~c~c~c"
          status reason #\Return #\Newline type #\Return #\Newline length
          #\Return #\Newline #\Return #\Newline #\Return #\Newline)
  (force-output stream))

(defun send-octets (stream status reason type octets head-only)
  (write-head stream status reason type (length octets))
  (unless head-only (write-sequence octets stream))
  (force-output stream))

(defun send-text (stream status reason text head-only)
  (send-octets stream status reason "text/plain; charset=utf-8"
               (sb-ext:string-to-octets text :external-format :utf-8) head-only))

(defun read-file-octets (path)
  (with-open-file (in path :element-type '(unsigned-byte 8))
    (let ((octets (make-array (file-length in) :element-type '(unsigned-byte 8))))
      (read-sequence octets in)
      octets)))

(defun respond (stream method target)
  (let ((head-only (string= method "HEAD"))
        (segments (split-path target)))
    (cond ((not (member method '("GET" "HEAD") :test #'string=))
           (send-text stream 405 "Method Not Allowed" "405 method not allowed" nil)
           405)
          ((not (safe-segments-p segments))
           (send-text stream 403 "Forbidden" "403 forbidden" head-only)
           403)
          (t
           (let* ((path (segments->pathname segments))
                  (file (probe-file path)))
             (cond ((and file (pathname-name file))
                    (send-octets stream 200 "OK" (content-type file) (read-file-octets file) head-only)
                    200)
                   ((null segments)
                    (send-octets stream 200 "OK" "text/html; charset=utf-8"
                                 (sb-ext:string-to-octets (listing-html) :external-format :utf-8)
                                 head-only)
                    200)
                   (t
                    (send-text stream 404 "Not Found" "404 not found" head-only)
                    404)))))))

;;; the loop

(defun read-request-line (stream)
  "The request line as (method target), or nil. Headers are read and dropped."
  (let ((line (read-line stream nil)))
    (loop for header = (read-line stream nil)
          while (and header (string/= (string-right-trim '(#\Return) header) "")))
    (when line
      (let ((parts (split-on (string-right-trim '(#\Return) line) #\Space)))
        (when (>= (length parts) 2)
          (list (first parts) (second parts)))))))

(defun handle (socket)
  (let ((stream (socket-make-stream socket :input t :output t
                                           :element-type :default
                                           :external-format :latin-1
                                           :buffering :full)))
    (unwind-protect
         (handler-case
             (let ((request (read-request-line stream)))
               (when request
                 (destructuring-bind (method target) request
                   (format t "~a ~a ~d~%" method target (respond stream method target))
                   (finish-output))))
           (error (e) (format *error-output* "error: ~a~%" e)))
      (ignore-errors (close stream))
      (ignore-errors (socket-close socket)))))

(defun serve ()
  (let ((listener (make-instance 'inet-socket :type :stream :protocol :tcp)))
    (setf (sockopt-reuse-address listener) t)
    (socket-bind listener #(127 0 0 1) *port*)
    (socket-listen listener 16)
    (format t "serving ~a at http://localhost:~d/~%" (namestring *site-dir*) *port*)
    (finish-output)
    (unwind-protect
         (handler-case (loop (handle (socket-accept listener)))
           (sb-sys:interactive-interrupt () (format t "~&stopped~%")))
      (socket-close listener))))

(serve)

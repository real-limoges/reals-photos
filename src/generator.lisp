;;;; generator.lisp --- Gym, Tan, Laundry a static site
;;;; (read the manifest, render previews, emit the site)

(in-package #:reals-photos)

;;; paths

(defparameter *star-dir*
  (merge-pathnames "raw/" *default-pathname-defaults*)
  "Where the selected sources live, split into main/ and antarctica/.")

(defparameter *site-dir*
  (merge-pathnames "site/" *default-pathname-defaults*)
  "Build output. Regenerated; safe to delete.")

(defparameter *manifest*
  (merge-pathnames "manifest.lisp" *default-pathname-defaults*))

(defparameter *widths* '(800 1200 2400)
  "The srcset ladder.")

(defparameter *bleed-widths* '(800 1200 2400 3600)
  "Wider ladder for :bleed rows; they paint at 100vw, so they need more pixels
   to stay sharp on HiDPI screens. Rendered only for bleed stems.")

(defparameter *fonts-dir*
  (merge-pathnames "style/fonts/" *default-pathname-defaults*)
  "Self-hosted woff2 sources, copied into site/fonts/ each build.")

(defparameter *favicon-src*
  (merge-pathnames "style/favicon.svg" *default-pathname-defaults*)
  "The site mark, linked from every page head.")

(defparameter *site-title* "Real's Photographs")

;;; css

(defparameter *css* "
/* Self-hosted, copied into site/fonts/ at build time (see COPY-FONTS). Bricolage Grotesque carries the titles for character; Hanken Grotesk
   reads the body, captions and nav. Latin-subset woff2, ~14-22 KB each. */
@font-face {
  font-family: \"Hanken Grotesk\"; font-style: normal; font-weight: 400;
  font-display: swap; src: url(\"fonts/hanken-grotesk-400.woff2\") format(\"woff2\");
}
@font-face {
  font-family: \"Hanken Grotesk\"; font-style: normal; font-weight: 600;
  font-display: swap; src: url(\"fonts/hanken-grotesk-600.woff2\") format(\"woff2\");
}
@font-face {
  font-family: \"Bricolage Grotesque\"; font-style: normal; font-weight: 600;
  font-display: swap; src: url(\"fonts/bricolage-grotesque-600.woff2\") format(\"woff2\");
}
:root {
  --maxw: 1200px;
  --gap: 20px;
  --bg: #f6f4ef;          /* warm off-white; not pure white so photos sit on paper */
  --fg: #2b2b2b;
  --muted: #8a857c;
  --sans: \"Hanken Grotesk\", system-ui, -apple-system, \"Segoe UI\", Roboto, sans-serif;
  --display: \"Bricolage Grotesque\", \"Hanken Grotesk\", system-ui, sans-serif;
}
* { box-sizing: border-box; }
html, body { margin: 0; }
html { scroll-snap-type: y mandatory; scroll-behavior: smooth; }
@media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } }
body {
  background: var(--bg); color: var(--fg);
  font-family: var(--sans);
  font-size: 17px; line-height: 1.6;
  overflow-x: clip;                 /* contain the 100vw :bleed rows */
  -webkit-font-smoothing: antialiased;
}
header.site {
  max-width: var(--maxw); margin: 0 auto;
  padding: 30px 16px 10px;
  display: flex; gap: 24px; align-items: baseline;
  flex-wrap: wrap;
}
header.site .title { font-family: var(--display); font-weight: 600; font-size: 22px; letter-spacing: 0.01em; }
header.site nav a { color: var(--muted); text-decoration: none; margin-right: 18px; }
header.site nav a.active { color: var(--fg); }
main.stack { max-width: var(--maxw); margin: 0 auto; padding: 16px; }
main.stack > * { margin-bottom: var(--gap); }
figure { margin: 0; }
/* Photo floats within its row: width auto + max-width keeps it filling the
   column when it can, max-height (--imgmax) keeps a tall frame from ever
   exceeding the paper, so nothing is cropped. margin-inline centers it. */
figure img {
  display: block; width: auto; height: auto;
  max-width: 100%; max-height: var(--imgmax, 82dvh);
  margin-inline: auto; background: #eceae4;
}
.row {
  display: grid; gap: var(--gap); align-items: center;
  min-height: 100dvh; align-content: center;   /* the row owns a full screenful */
  --imgmax: 82dvh;                             /* :feature envelope, leaving a paper band */
  scroll-snap-align: center;                   /* a settled snap shows only this row's paper */
  scroll-snap-stop: always;                    /* flings can't skip past a photo; slow scroll stays free */
}
.row.full {                                        /* break past the 1200 text column so the photo scales with the viewport, not a fixed 1200px */
  --imgmax: 74dvh;
  width: min(100vw - 32px, 1800px);
  margin-left: calc((100% - min(100vw - 32px, 1800px)) / 2);
}
.row.pair {                                        /* break wider than the 1200 column so each photo is larger */
  grid-template-columns: 1fr 1fr; --imgmax: 58dvh;
  width: min(100vw - 32px, 1600px);
  margin-left: calc((100% - min(100vw - 32px, 1600px)) / 2);   /* re-center the wider row */
}
.row.feature-left, .row.feature-right {            /* break past the 1200 column, like :pair, so the photo reaches toward the screen edge */
  width: min(100vw - 32px, 2240px);                /* 4fr/1fr split -> photo tops out ~1760px, scaling with the viewport below that */
  margin-left: calc((100% - min(100vw - 32px, 2240px)) / 2);
  column-gap: 40px;                                /* more air between the photo edge and its wall card */
}
.row.feature-left { grid-template-columns: 4fr 1fr; }
.row.feature-right{ grid-template-columns: 1fr 4fr; }
/* Fill the 80% column so the grid split is what the eye sees; the generic
   width:auto rule would leave the fixed-size photo short of the wider column.
   max-height + contain keep a tall frame from overflowing, letterboxed to its
   own side rather than cropped. */
.row.feature-left  figure img,
.row.feature-right figure img {
  width: 100%; max-width: none; height: auto;
  max-height: var(--imgmax); object-fit: contain;
  background: transparent;   /* any contain letterbox is page paper, not the gray load placeholder */
}
.row.feature-left  figure img { object-position: left center; }
.row.feature-right figure img { object-position: right center; }
.row.bleed   {                                     /* the one row meant to fill the frame edge to edge */
  width: 100vw; margin-left: calc(50% - 50vw); --imgmax: none;
  position: relative;                              /* positioning context for the debossed label */
}
.row.bleed figure img { width: 100%; height: 100dvh; max-height: none; object-fit: cover; }
.card-slot { min-height: 1px; display: flex; align-items: center; }   /* breathing room / museum card */
.wall { margin: 0; color: var(--muted); font-size: 14px; line-height: 1.55; letter-spacing: 0.04em; }

/* Bleed label: a wall card pressed into the photo. The soft corner scrim gives
   the text a consistent backdrop over any image; the paired text-shadows (a dark
   edge above, a light edge below, flipped for on-light) fake a letterpress deboss
   so the words read as stamped into the surface rather than laid on top. Corner
   and tone are chosen per image in the manifest, since the quiet area moves. */
.bleed-label {
  position: absolute; z-index: 2; margin: 0; max-width: min(42ch, 64vw);
  padding: clamp(18px, 3vw, 34px) clamp(20px, 3.2vw, 40px);
  font-family: var(--sans); font-size: 14px; line-height: 1.55; letter-spacing: 0.05em;
}
.bleed-label em {
  font-style: normal; font-family: var(--display); font-weight: 600;
  font-size: 20px; letter-spacing: 0.01em; display: block; margin-bottom: 3px;
}
/* corners: which edge to hug, which way the text sets, which way the scrim fades */
.bleed-label.bl { left: 0;  bottom: 0; text-align: left;  }
.bleed-label.br { right: 0; bottom: 0; text-align: right; }
.bleed-label.tl { left: 0;  top: 0;    text-align: left;  }
.bleed-label.tr { right: 0; top: 0;    text-align: right; }
.bleed-label.bl { background: radial-gradient(120% 120% at 0% 100%,   var(--scrim), transparent 68%); }
.bleed-label.br { background: radial-gradient(120% 120% at 100% 100%, var(--scrim), transparent 68%); }
.bleed-label.tl { background: radial-gradient(120% 120% at 0% 0%,     var(--scrim), transparent 68%); }
.bleed-label.tr { background: radial-gradient(120% 120% at 100% 0%,   var(--scrim), transparent 68%); }
.bleed-label.on-dark {
  --scrim: rgba(0,0,0,0.52); color: rgba(255,255,255,0.90);
  text-shadow: 0 1px 1px rgba(0,0,0,0.55), 0 -1px 0 rgba(255,255,255,0.14);
}
.bleed-label.on-light {
  --scrim: rgba(244,239,227,0.60); color: rgba(24,22,18,0.86);
  text-shadow: 0 1px 0 rgba(255,255,255,0.60), 0 -1px 1px rgba(0,0,0,0.30);
}

/* Gallery motion: fade+rise as a work enters, dim as it leaves. Pure CSS
   scroll-driven animation; unsupported browsers and reduced-motion just see
   the images at rest, full opacity. */
@keyframes reveal { from { opacity: 0; transform: translateY(28px); } to { opacity: 1; transform: none; } }
@keyframes settle { from { opacity: 1; } to { opacity: 0.5; } }
@supports (animation-timeline: view()) {
  @media (prefers-reduced-motion: no-preference) {
    figure, .wall { animation: reveal linear both; animation-timeline: view(); animation-range: entry; }
    figure img    { animation: settle linear both; animation-timeline: view(); animation-range: exit; }
  }
}
@media (max-width: 760px) {
  .row.pair, .row.feature-left, .row.feature-right { grid-template-columns: 1fr; }
  .card-slot { display: none; }
}
")

;;; manifest

(defun read-manifest ()
  (with-open-file (in *manifest* :direction :input)
    (read in)))

(defun page-name (page) (second page))          ; (:page :main <row>*)
(defun page-rows (page) (cddr page))

(defun row-stems (row)
  "Stems referenced by ROW"
  (ecase (first row)
    (:full       (list (second row)))
    (:bleed      (list (second row)))
    (:feature    (list (third row)))            ; (:feature :left/:right stem [caption])
    (:pair       (list (second row) (third row)))))

;;; source resolving

(defun source-for (page stem)
  "The original file in raw/<page>/ whose basename is STEM, or NIL."
  (first (directory
          (make-pathname
           :name stem :type :wild
           :directory (append (pathname-directory *star-dir*)
                              (list (string-downcase (symbol-name page))))))))

;;; preview render

(defun preview-path (stem width)
  (merge-pathnames (format nil "img/~a-~d.jpg" stem width) *site-dir*))

(defun render-preview (src stem width)
  "Shell out to sips to make a preview rung. Its lazy and skips work already done."
  (let ((out (preview-path stem width)))
    (ensure-directories-exist out)
    (cond
      ((probe-file out) :cached)
      (t (let ((proc (sb-ext:run-program
                      "sips"
                      (list "-Z" (princ-to-string width)
                            "-s" "format" "jpeg"
                            "-s" "formatOptions" "82"
                            (namestring src)
                            "--out" (namestring out))
                      :search t :output nil :error *error-output*)))
           (if (zerop (sb-ext:process-exit-code proc))
               :rendered
               (progn (format t "  !! sips failed: ~a @ ~d~%" stem width) :failed)))))))

(defun row-widths (row)
  "The srcset rungs to render for ROW: bleed rows get the wider ladder."
  (if (eq (first row) :bleed) *bleed-widths* *widths*))

(defun page-stem-widths (page)
  "Every (stem . widths) pair PAGE asks for"
  (loop for row in (page-rows page)
        for widths = (row-widths row)
        nconc (loop for stem in (row-stems row)
                    collect (cons stem widths))))

(defun ensure-previews (page)
  "Render every rung for every stem on PAGE. Returns (rendered cached missing)."
  (let ((rendered 0) (cached 0) (missing '()))
    (loop for (stem . widths) in (page-stem-widths page)
          for src = (source-for (page-name page) stem)
          if (null src)
            do (pushnew stem missing :test #'string=)
          else
            do (dolist (w widths)
                 (case (render-preview src stem w)
                   (:rendered (incf rendered))
                   (:cached   (incf cached)))))
    (list rendered cached (nreverse missing))))

;;; html

(defun srcset-for (stem widths)
  (format nil "~{~a~^, ~}"
          (mapcar (lambda (w) (format nil "img/~a-~d.jpg ~dw" stem w w)) widths)))

(defun img-html (stem sizes alt &optional (widths *widths*))
  (format nil
          "<img src=\"img/~a-1200.jpg\" srcset=\"~a\" sizes=\"~a\" alt=\"~a\" loading=\"lazy\">"
          stem (srcset-for stem widths) sizes alt))

(defparameter *sizes-full* "(max-width: 1832px) calc(100vw - 32px), 1800px")
(defparameter *sizes-feature*   "(max-width: 760px) 100vw, (max-width: 2272px) calc(80vw - 58px), 1760px")
(defparameter *sizes-pair* "(max-width: 760px) 100vw, (max-width: 1632px) calc(50vw - 26px), 790px")
(defparameter *sizes-bleed* "100vw")

(defun figure-html (stem sizes &optional (widths *widths*))
  (format nil "<figure>~a</figure>" (img-html stem sizes stem widths)))

(defun card-slot-html (caption)
  "The gutter beside a :feature photo. wall text if theres a CAPTION"
  (if caption
      (format nil "<div class=\"card-slot\"><p class=\"wall\">~a</p></div>" caption)
      "<div class=\"card-slot\"></div>"))

(defun placement-class (placement)
  "Corner keyword"
  (ecase (or placement :bottom-left)
    (:bottom-left "bl") (:bottom-right "br")
    (:top-left "tl")    (:top-right "tr")))

(defun bleed-label-html (caption placement tone)
  "The debossed wall label pressed into a :bleed photo (or nothing if no CAPTION)
   TONE is :on-dark (default) or :on-light, picking the scrim and press edges."
  (if caption
      (format nil "<figcaption class=\"bleed-label ~a ~(~a~)\">~a</figcaption>"
              (placement-class placement) (or tone :on-dark) caption)
      ""))

(defun row-html (row)
  (ecase (first row)
    (:full
     (format nil "  <div class=\"row full\">~a</div>"
             (figure-html (second row) *sizes-full*)))
    (:bleed
     ;; (:bleed stem [caption [placement [tone]]])
     (format nil "  <div class=\"row bleed\">~a~a</div>"
             (figure-html (second row) *sizes-bleed* *bleed-widths*)
             (bleed-label-html (third row) (fourth row) (fifth row))))
    (:pair
     (format nil "  <div class=\"row pair\">~a~a</div>"
             (figure-html (second row) *sizes-pair*)
             (figure-html (third row) *sizes-pair*)))
    (:feature
     (let ((side (second row)) (stem (third row)) (caption (fourth row)))
       (ecase side
         ;; photo left, wall text right
         (:left  (format nil "  <div class=\"row feature-left\">~a~a</div>"
                         (figure-html stem *sizes-feature*) (card-slot-html caption)))
         ;; wall text left, photo right
         (:right (format nil "  <div class=\"row feature-right\">~a~a</div>"
                         (card-slot-html caption) (figure-html stem *sizes-feature*))))))))

(defun nav-html (pages current)
  (with-output-to-string (s)
    (write-string "<nav>" s)
    (dolist (page pages)
      (let* ((name (page-name page))
             (label (string-capitalize (symbol-name name)))
             (href (format nil "~(~a~).html" name))
             (active (if (eq name current) " class=\"active\"" "")))
        (format s "<a href=\"~a\"~a>~a</a>" href active label)))
    (write-string "</nav>" s)))

(defun page-html (page pages)
  (let ((name (page-name page)))
    (with-output-to-string (s)
      (format s "<!doctype html>~%<html lang=\"en\">~%<head>~%")
      (format s "<meta charset=\"utf-8\">~%")
      (format s "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">~%")
      (format s "<link rel=\"icon\" type=\"image/svg+xml\" href=\"favicon.svg\">~%")
      (format s "<title>~a &middot; ~a</title>~%"
              (string-capitalize (symbol-name name)) *site-title*)
      (format s "<style>~%~a</style>~%</head>~%<body>~%" *css*)
      (format s "<header class=\"site\"><span class=\"title\">~a</span>~a</header>~%"
              *site-title* (nav-html pages name))
      (format s "<main class=\"stack\">~%")
      (dolist (row (page-rows page))
        (write-string (row-html row) s)
        (terpri s))
      (format s "</main>~%</body>~%</html>~%"))))

;;; build

(defun copy-file (src dst)
  "Byte-for-byte copy SRC to DST, creating DST's directory and overwriting it."
  (ensure-directories-exist dst)
  (with-open-file (in src :element-type '(unsigned-byte 8))
    (with-open-file (out dst :element-type '(unsigned-byte 8)
                             :direction :output :if-exists :supersede
                             :if-does-not-exist :create)
      (let ((buf (make-array 65536 :element-type '(unsigned-byte 8))))
        (loop for n = (read-sequence buf in)
              while (plusp n) do (write-sequence buf out :end n))))))

(defun copy-fonts ()
  "Copy woff2 fonts from *fonts-dir* into site/fonts/. (don't overthink)
   the @font-face urls in *css* are relative to the page"
  (let ((dst-dir (merge-pathnames "fonts/" *site-dir*))
        (copied 0))
    (dolist (src (directory (merge-pathnames "*.woff2" *fonts-dir*)))
      (copy-file src (merge-pathnames (file-namestring src) dst-dir))
      (incf copied))
    copied))

(defun copy-favicon ()
  (copy-file *favicon-src* (merge-pathnames "favicon.svg" *site-dir*)))

(defun write-page (page pages)
  (let ((path (merge-pathnames (format nil "~(~a~).html" (page-name page)) *site-dir*)))
    (ensure-directories-exist path)
    (with-open-file (out path :direction :output :if-exists :supersede
                              :if-does-not-exist :create)
      (write-string (page-html page pages) out))
    path))

(defun build ()
  "Read the manifest, render any missing previews, emit the pages. (Gym, Tan, Laundry)"
  (let* ((site (read-manifest))
         (pages (rest site)))
    (format t "~&Building ~d page(s) from ~a~%" (length pages) (namestring *manifest*))
    (format t "  fonts       ~d woff2 copied to site/fonts/~%" (copy-fonts))
    (copy-favicon)
    (format t "  favicon     site/favicon.svg~%")
    (dolist (page pages)
      (destructuring-bind (rendered cached missing) (ensure-previews page)
        (format t "  ~10a  previews: ~d rendered, ~d cached~@[, MISSING sources: ~{~a~^ ~}~]~%"
                (string-downcase (symbol-name (page-name page)))
                rendered cached missing))
      (let ((path (write-page page pages)))
        (format t "  ~10a  -> ~a (~d rows)~%"
                "" (namestring path) (length (page-rows page)))))
    (format t "Done. Open ~ain a browser.~%"
            (namestring (merge-pathnames "main.html" *site-dir*)))
    (values)))

(defun main ()
  (build))

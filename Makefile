.PHONY: develop build serve clean distclean

# Develop every raw the manifest uses from ./raw into ./developed with
# rawtherapee-cli: style/base.pp3, plus style/frames/<stem>.pp3 where one exists.
# Lazy: only new raws, or ones whose raw or profiles changed, are redeveloped.
develop:
	sbcl --script develop.lisp

# Build the site into ./site from ./manifest.lisp, rendering missing or stale
# previews from ./developed (or straight from ./raw for in-camera HEIF).
build: develop
	sbcl --script build.lisp

# Build, then serve locally so relative paths behave exactly as when deployed.
# serve.lisp is a small static server on SBCL's bundled sockets, site/ as docroot.
serve: build
	sbcl --script serve.lisp 7341

# Drop the generated site (previews included); fully reproducible from a build.
clean:
	rm -rf site

# Also drop the developed full-size JPEGs; the next build redevelops every raw.
distclean: clean
	rm -rf developed

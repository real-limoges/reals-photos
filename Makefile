.PHONY: build serve clean

# Build the site into ./site from ./manifest.lisp (renders missing previews).
build:
	sbcl --script build.lisp

# Build, then serve locally so relative paths behave exactly as when deployed.
# serve.lisp is a small static server on SBCL's bundled sockets, site/ as docroot.
serve: build
	sbcl --script serve.lisp 7000

# Drop the generated site (previews included); fully reproducible from a build.
clean:
	rm -rf site

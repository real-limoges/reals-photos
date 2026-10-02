.PHONY: build serve clean

# Build the site into ./site from ./manifest.lisp (renders missing previews).
build:
	sbcl --script build.lisp

# Build, then serve locally so relative paths behave exactly as when deployed.
# Ruby's stdlib httpd (WEBrick), site/ as docroot. Needs: gem install webrick
serve: build
	ruby -run -e httpd site --port 7000

# Drop the generated site (previews included); fully reproducible from a build.
clean:
	rm -rf site

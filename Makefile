GO := go
NAME := omelette
VERSION := 1.1.1
DIST := $(NAME)-$(VERSION)

all: test build

setup: update_version
	git submodule update --init

update_version:
	@for i in README.md docs/content/_index.md; do\
		sed -e 's!Version-[0-9.]*-yellowgreen!Version-${VERSION}-yellowgreen!g' -e 's!tag/v[0-9.]*!tag/v${VERSION}!g' $$i > a ; mv a $$i; \
	done
	@sed 's/const VERSION = .*/const VERSION = "${VERSION}"/g' cmd/omelette/main.go > a; mv a cmd/omelette/main.go
	@echo "Replace version to \"${VERSION}\""

lib/jacococli.jar:
	sh ./bin/download_dependencies.sh

test: setup lib/jacococli.jar
	$(GO) test -covermode=count -coverprofile=coverage.out $$(go list ./... | grep -v vendor)

# refer from https://pod.hatenablog.com/entry/2017/06/13/150342
define _createDist
	mkdir -p dist/$(1)_$(2)/$(DIST)
	cp -r bin completions README.md LICENSE dist/$(1)_$(2)/$(DIST)
	GOOS=$1 GOARCH=$2 go build -o dist/$(1)_$(2)/$(DIST)/bin/$(NAME)$(3) cmd/$(NAME)/main.go
	tar cfz dist/$(DIST)_$(1)_$(2).tar.gz -C dist/$(1)_$(2) $(DIST)
endef

dist: build
	@$(call _createDist,darwin,amd64,)
	@$(call _createDist,darwin,386,)
	@$(call _createDist,windows,amd64,.exe)
	@$(call _createDist,windows,386,.exe)
	@$(call _createDist,linux,amd64,)
	@$(call _createDist,linux,386,)

build: setup
	$(GO) build -o $(NAME) -v cmd/$(NAME)/main.go

clean:
	$(GO) clean
	rm -f $(NAME) *_coverage.csv *_jacoco.csv *_jacoco.exec

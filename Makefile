.DEFAULT_GOAL := build

PLATFORMS := linux/amd64 darwin/amd64
PREFIX := /usr

temp = $(subst /, ,$@)
os = $(word 1, $(temp))
arch = $(word 2, $(temp))

.PHONY: release $(PLATFORMS)
release: $(PLATFORMS)

$(PLATFORMS):
	GOOS=$(os) GOARCH=$(arch) go build -o 'build/$(os)-$(arch)/jimClient' bin/jimClient/main.go
	GOOS=$(os) GOARCH=$(arch) go build -o 'build/$(os)-$(arch)/jimServer' bin/jimServer/main.go
	cp static/* 'build/$(os)-$(arch)'
	mkdir -p dist
	cd build && tar -zcvf ../dist/jim-$(os)-$(arch).tar.gz $(os)-$(arch)

.PHONY: build
build: build-client build-server
	cp static/* build/local/

.PHONY: build-client
build-client:
	go build -o build/local/jimClient bin/jimClient/main.go

.PHONY: build-server
build-server:
	go build -o build/local/jimServer bin/jimServer/main.go

.PHONY: clean
clean:
	rm -rf build/
	rm -rf dist/

.PHONY: install
install: build
	install -m 0755 build/local/jim $(PREFIX)/bin
	install -m 0755 build/local/jimClient $(PREFIX)/bin
	install -m 0755 build/local/jimServer $(PREFIX)/bin

.PHONY: uninstall
uninstall:
	rm -f $(PREFIX)/bin/jim
	rm -f $(PREFIX)/bin/jimClient
	rm -f $(PREFIX)/bin/jimServer
default: ci

ci: lint cover

ci-full: ci dependencies-analyze openapi-check check-all-modules lint-markdown bench

PATHS := ./... ./examples/petstore/... $\
	./extra/fuegogin/... ./examples/gin-compat/... $\
	./extra/sql/... ./extra/sqlite3/... $\
	./extra/fuegoecho/... ./examples/echo-compat/...
test: 
	go test $(PATHS)

cover:
	go test -coverprofile=coverage.out ${PATHS}
	go tool cover -func=coverage.out

check-all-modules:
	./check-all-modules.sh

cover-web: cover
	go tool cover -html=coverage.out

bench:
	go test -bench ./... -benchmem

build:
	go build -v ./... ./examples/petstore/...

dependencies-analyze:
	which govulncheck || go install golang.org/x/vuln/cmd/govulncheck@latest
	go run golang.org/x/vuln/cmd/govulncheck@latest ./...

fmt:
	which gofumpt || go install mvdan.cc/gofumpt@latest
	gofumpt -l -w -extra .

FIX := "--fix"
GOLANGCI_LINT_VERSION = v2.1.2
lint:
	which golangci-lint || go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)
	golangci-lint run ${FIX} ./...

lint-markdown:
	markdownlint ${FIX} --ignore documentation/node_modules --dot .

# Update golden files
golden-update:
	(cd examples/petstore/lib && go test -update)

# Check OpenAPI spec generated for the Petstore example. Uses https://github.com/daveshanley/vacuum
openapi-check:
	go run github.com/daveshanley/vacuum@latest lint -d examples/petstore/lib/testdata/doc/openapi.json

# Examples
example:
	( cd examples/full-app-gourmet && go run . -debug )

example-watch:
	( cd examples/full-app-gourmet && air -- -debug )

petstore:
	( cd examples/petstore && go run . -debug )

# Documentation website
docs:
	go run golang.org/x/pkgsite/cmd/pkgsite@latest -http localhost:8084

docs-open:
	go run golang.org/x/pkgsite/cmd/pkgsite@latest -http localhost:8084 -open

.PHONY: docs-open docs example-watch example lint lint-markdown fmt ci ci-full
.PHONY: dependencies-analyze build bench cover-web cover test petstore check-all-modules
.PHONY: golden-update openapi-check

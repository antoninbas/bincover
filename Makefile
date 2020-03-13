SHELL           := /bin/bash
ALL_SRC         := $(shell find . -name "*.go" | grep -v -e vendor)
GIT_REMOTE_NAME ?= origin
MASTER_BRANCH   ?= master
ifdef TF_BUILD
	CI := on
endif

.PHONY: deps
deps:
	@GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint@v1.21.0

.PHONY: fmt
fmt:
	@gofmt -e -s -l -w $(ALL_SRC)

.PHONY: lint-go
lint-go:
	@GO111MODULE=on golangci-lint run --timeout=10m --skip-files="test_bin/set_covermode.go"

.PHONY: lint
lint: lint-go 

.PHONY: coverage
coverage:
ifdef CI
	@# Run unit tests with coverage.
	@GO111MODULE=on go test .  -coverpkg=./...  -coverprofile=coverage.out
else
	@GO111MODULE=on go test .
endif

.PHONY: test
test: lint coverage

SHELL := /bin/bash

VERSION := `git describe --always`
GITCOMMIT := `git rev-parse HEAD`
BRANCH := `git rev-parse --abbrev-ref HEAD`
BUILDDATE := `date +%Y-%m-%d`
BUILDUSER := `whoami`

LDFLAGSSTRING :=-X main.Version=$(VERSION)
LDFLAGSSTRING +=-X main.GitCommit=$(GITCOMMIT)
LDFLAGSSTRING +=-X main.Branch=$(BRANCH)
LDFLAGSSTRING +=-X main.BuildDate=$(BUILDDATE)
LDFLAGSSTRING +=-X main.BuildUser=$(BUILDUSER)

LDFLAGS :=-ldflags "$(LDFLAGSSTRING)"

.PHONY: all build

all: build

# Build binary
build:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build $(LDFLAGS) 
docker_build:
	docker build . -t electriccoinco/zcashd-peers
	docker push electriccoinco/zcashd-peers
test:
	go test -v ./...
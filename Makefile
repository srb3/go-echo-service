# Makefile for go-echo-server project

# Variables
BINARY_NAME := go-echo-server
SRC_DIR := .
TARGET_DIR := ./build
GOFILES := $(shell find $(SRC_DIR) -type f -name '*.go')
GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)
DOCKER_IMAGE := $(DOCKER_REPO)/go-echo-server:latest
DOCKER_IMAGE_VERSION := $(DOCKER_REPO)/go-echo-server:$(IMAGE_VERSION)

# Default target
.PHONY: all
all: build

# Install dependencies
.PHONY: deps
deps:
	@echo "Fetching dependencies..."
	go mod tidy

# Build the Go binary
.PHONY: build
build: deps
	@echo "Building the binary..."
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(TARGET_DIR)/$(BINARY_NAME) $(SRC_DIR)

# Run the server
.PHONY: run
run:
	@echo "Running the server..."
	go run $(SRC_DIR)

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	go test -v ./...

# Clean the build directory
.PHONY: clean
clean:
	@echo "Cleaning up..."
	rm -rf $(TARGET_DIR)

# Compile and generate executable for different OS/Architecture
.PHONY: build-cross
build-cross:
	@echo "Cross compiling for different platforms..."
	GOOS=linux GOARCH=amd64 go build -o $(TARGET_DIR)/$(BINARY_NAME)-linux-amd64 $(SRC_DIR)
	GOOS=darwin GOARCH=amd64 go build -o $(TARGET_DIR)/$(BINARY_NAME)-darwin-amd64 $(SRC_DIR)
	GOOS=windows GOARCH=amd64 go build -o $(TARGET_DIR)/$(BINARY_NAME)-windows-amd64.exe $(SRC_DIR)

# Build Docker image
.PHONY: docker-build
docker-build:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE) .
	docker build -t $(DOCKER_IMAGE_VERSION) .

# Push Docker image to repository
.PHONY: docker-push
docker-push:
	@echo "Pushing Docker image..."
	docker push $(DOCKER_IMAGE)
	docker push $(DOCKER_IMAGE_VERSION)

# Help command to display available targets
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all           - Build the project (default)"
	@echo "  deps          - Fetch and tidy dependencies"
	@echo "  build         - Build the Go binary"
	@echo "  run           - Run the Go server"
	@echo "  test          - Run tests"
	@echo "  clean         - Clean the build directory"
	@echo "  build-cross   - Cross compile for multiple platforms"
	@echo "  docker-build  - Build Docker image"
	@echo "  docker-push   - Push Docker image to repository"
	@echo "  help          - Display this help message"

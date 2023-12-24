PROJECT_NAME := Template
EXE_NAME := template

.PHONY: help ## print this
help:
	@echo ""
	@command -v figlet4go &> /dev/null && figlet4go -colors 03A062 -font larry3d -str "$(PROJECT_NAME)" || true
	@echo "$(PROJECT_NAME) Development CLI"
	@echo ""
	@echo "Usage:"
	@echo "  make \033[34m<command>\033[0m"
	@echo ""
	@echo "Commands:"
	@grep '^.PHONY: ' Makefile | sed 's/.PHONY: //' | awk '{split($$0,a," ## "); printf "  \033[34m%0-10s\033[0m %s\n", a[1], a[2]}'
	@echo ""
	@echo "CI flow:"
	@echo "  \033[34mdeps\033[0m -> \033[34mswag\033[0m -> \033[34mlint\033[0m -> \033[34mtest\033[0m -> \033[34mbuild\033[0m"
	@echo ""

.PHONY: doctor ## checks if dev environment is ready
doctor:
	@echo "Doing a quick check..."
	@if ! command -v go &> /dev/null; then \
		echo "`go` is not installed. Please install it first."; \
		exit 1; \
	fi
	@if [[ ! ":$$PATH:" == *":$$HOME/go/bin:"* ]]; then \
		echo "GOPATH/bin is not in PATH. Please add it to your PATH variable."; \
		exit 1; \
	fi
	@if ! command -v cobra-cli &> /dev/null; then \
		echo "Cobra-cli is not installed. Please run 'make deps'."; \
		exit 1; \
	fi
	@if ! command -v swag &> /dev/null; then \
		echo "Swag is not installed. Please run 'make deps'."; \
		exit 1; \
	fi
	@if ! command -v golangci-lint &> /dev/null; then \
		echo "Golangci-lint is not installed. Please run 'make deps'."; \
		exit 1; \
	fi
	@if ! command -v scc &> /dev/null; then \
		echo "Scc is not installed. Please run 'make deps'."; \
		exit 1; \
	fi
	@echo "You're good to go!"

.PHONY: test ## run tests
test:
	@echo "Running tests..."
	@go clean -testcache
	@go test -v -coverprofile=coverage ./...
	@echo "Creating coverage report..."
	@go tool cover -html=coverage -o coverage.html
	@echo "Writing coverage report to coverage.html..."
	@echo "Done."

.PHONY: serve ## run the server
serve: swag .env
	@make swag > /dev/null
	@echo "Starting server..."
	@sed 's/^PROJECT_NAME=.*/PROJECT_NAME=$(PROJECT_NAME)/' .env > .env.tmp
	@mv .env.tmp .env
	@go run . serve

.PHONY: swag ## generate swagger docs
swag:
	@echo "Generating swagger docs..."
	@swag init --parseDependency -g cmd/serve.go

.PHONY: fmt ## format code
fmt:
	@echo "Formatting code..."
	@go fmt ./... > /dev/null
	@echo "Done."
	@echo ""
	@echo "Formatting swagger comments..."
	@swag fmt
	@echo "Done."

.PHONY: lint ## run linters
lint:
	@golangci-lint run

.PHONY: lint-fix ## run linters with --fix
lint-fix:
	@golangci-lint run --fix

.PHONY: build ## build the binary
build:
	@echo "Building binary..."
	@go build -o bin/$(EXE_NAME) .
	@echo "Done."

.PHONY: deps ## install dependencies
deps:
	@echo "Installing dependencies..."
	@go install github.com/spf13/cobra-cli@latest
	@go install github.com/swaggo/swag/cmd/swag@v1.8.12
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@go install github.com/boyter/scc/v3@latest
	@go install github.com/mbndr/figlet4go/cmd/figlet4go@latest
	@echo "Done."

.PHONY: clean ## clears environment
clean:
	@echo "Cleaning..."
	@rm -rf bin coverage*
	@echo "Done."

.PHONY: stat ## repository stats
stat:
	@scc -w

.env:
	@cp .env.default .env

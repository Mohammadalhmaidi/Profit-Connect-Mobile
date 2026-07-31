# Makefile for Profit Connect Mobile
.PHONY: help analyze test format fix clean build-android build-ios build-web ci icons setup

# Variables
FLUTTER := flutter
DART := dart
PUB := flutter pub
ANALYZE := $(FLUTTER) analyze --fatal-infos
TEST := $(FLUTTER) test --coverage
FORMAT := $(DART) format --set-exit-if-changed .

help:
	@echo "Available commands:"
	@echo "  make analyze      - Run static analysis"
	@echo "  make test         - Run tests with coverage"
	@echo "  make format       - Format code"
	@echo "  make fix          - Auto-fix issues"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make build-android - Build Android APK"
	@echo "  make build-ios    - Build iOS"
	@echo "  make build-web    - Build Web"
	@echo "  make icons        - Generate launcher icons"
	@echo "  make setup        - Full project setup"
	@echo "  make ci           - Run full CI pipeline"

analyze:
	$(ANALYZE)

test:
	$(TEST)

format:
	$(FORMAT)

fix:
	$(DART) fix --apply .

clean:
	$(FLUTTER) clean
	$(PUB) get

build-android:
	$(FLUTTER) build apk --release

build-ios:
	$(FLUTTER) build ios --release --no-codesign

build-web:
	$(FLUTTER) build web --release

icons:
	$(FLUTTER) pub run flutter_launcher_icons:main

setup: clean pub get icons analyze
	@echo "Project setup complete!"

pub get:
	$(PUB) get

ci: analyze test format
	@echo "CI checks passed!"
# Makefile for TennisCoach

.DEFAULT_GOAL := help

WORKSPACE := TennisCoach.xcworkspace
APP_SCHEME := TennisCoachApp
DOMAIN_SCHEME := TennisDomain
FEATURE_TEST_SCHEMES := TennisCore AppFeature OnboardingFeature MainFeature RecordFeature SessionSummaryFeature HistoryFeature SettingsFeature TrainingSetupFeature
DERIVED_DATA_PATH ?= /tmp/TennisCoachBuild
SIMULATOR_NAME ?= iPhone 17
XCODEBUILD_FLAGS := -skipMacroValidation -skipPackagePluginValidation

## setup: Configure Team ID and generate the Xcode workspace. Requires TEAM_ID.
.PHONY: setup
setup: require-team-id
	@$(MAKE) signing TEAM_ID=$(TEAM_ID)
	@$(MAKE) generate
	@echo ""
	@echo "Project setup complete. Open $(WORKSPACE) to get started."

## signing: Saves Apple Developer Team ID locally. Requires TEAM_ID.
.PHONY: signing
signing: require-team-id
	@swift Scripts/CodeSigning.swift $(TEAM_ID)

## generate: Generates the Xcode workspace with Tuist.
.PHONY: generate
generate:
	@tuist generate

## build: Builds the app for iOS Simulator.
.PHONY: build
build:
	@xcodebuild build \
		$(XCODEBUILD_FLAGS) \
		-workspace $(WORKSPACE) \
		-scheme $(APP_SCHEME) \
		-destination 'generic/platform=iOS Simulator' \
		-derivedDataPath $(DERIVED_DATA_PATH)

## test: Runs domain and feature unit tests on iOS Simulator.
.PHONY: test
test: test-domain test-features

## test-domain: Runs domain unit tests on iOS Simulator.
.PHONY: test-domain
test-domain:
	@xcodebuild test \
		$(XCODEBUILD_FLAGS) \
		-workspace $(WORKSPACE) \
		-scheme $(DOMAIN_SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR_NAME)' \
		-derivedDataPath $(DERIVED_DATA_PATH)

## test-features: Runs feature unit tests on iOS Simulator.
.PHONY: test-features
test-features:
	@for scheme in $(FEATURE_TEST_SCHEMES); do \
		echo "Testing $$scheme"; \
		xcodebuild test \
			$(XCODEBUILD_FLAGS) \
			-workspace $(WORKSPACE) \
			-scheme $$scheme \
			-destination 'platform=iOS Simulator,name=$(SIMULATOR_NAME)' \
			-derivedDataPath $(DERIVED_DATA_PATH) || exit $$?; \
	done

## clean: Cleans Tuist/Xcode generated files.
.PHONY: clean
clean:
	@tuist clean
	@rm -rf Derived TennisCoach.xcodeproj TennisCoach.xcworkspace

.PHONY: require-team-id
require-team-id:
	@if [ -z "$(TEAM_ID)" ]; then \
		echo "Error: TEAM_ID is not set."; \
		echo "Usage: make setup TEAM_ID=8UV3Y69NB7"; \
		exit 1; \
	fi

## help: Shows this help message.
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@awk '/^## / {line=$$0; sub(/^## /, "", line); split(line, parts, ": "); printf "  %-14s %s\n", parts[1], parts[2]}' $(MAKEFILE_LIST)

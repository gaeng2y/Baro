# Agent Guide

This document is the long-form guide for AI coding agents. The root `AGENTS.md` is the quick entry point; `CLAUDE.md` is a symlink to it so Claude reads the same instructions.

## Operating Rules

- Check `git status --short` before editing.
- Preserve unrelated user changes, including untracked files.
- Use `rg` or `rg --files` first for search.
- Use `apply_patch` for manual file edits.
- Keep changes scoped to the user request.
- Do not commit unless the user asks for commits.
- If the user asks for multiple commits, stage only the files belonging to each requested logical unit.

## Repository Context

TennisCoach is a Tuist-based iOS app:

- iOS 17+
- Swift 6
- SwiftUI
- Clean Architecture style modules
- TCA-ready `State` / `Action` / `Reducer` feature shape
- On-device camera, pose estimation, rule-based coaching, and audio feedback pipeline

Primary source references:

- `README.md` for setup and module overview.
- `PRD.md` for product requirements and phased roadmap.
- `Project.swift` for target definitions.
- `Makefile` for local build/test commands.

## Commands

- Generate workspace: `make generate`
- Configure signing and generate workspace: `make setup TEAM_ID=<TEAM_ID>`
- Build app for simulator: `make build`
- Run domain tests: `make test`
- Clean generated project files: `make clean`

When using XcodeBuildMCP, inspect session defaults before build or run calls. If defaults are missing, use the workspace `TennisCoach.xcworkspace`, scheme `TennisCoachApp`, and an available iOS simulator.

## Files Agents Must Not Treat As Source

Do not edit or commit generated artifacts unless the user explicitly asks:

- `TennisCoach.xcworkspace`
- `TennisCoach.xcodeproj`
- `Derived/`

Local signing data must stay local:

- `Tuist/Local/TeamID.txt`

## Preferred Workflow

1. Read the relevant module and nearby patterns.
2. Make the smallest coherent patch.
3. Run the narrowest meaningful verification.
4. Report what changed, what was verified, and any blocker.

Use this verification rule:

- Domain-only changes: run `make test`.
- Feature/UI/Core/project changes: run `make build` when feasible.
- Project manifest or target membership changes: run `make generate` before Xcode-based verification.

## Documentation Updates

Agents should update docs when they change behavior that future work depends on:

- Module boundaries or dependencies: update [Architecture](architecture.md).
- SwiftUI patterns, design system primitives, or navigation shape: update [SwiftUI Guide](swiftui.md).
- Camera, Vision, pose features, model inputs, model outputs, or inference flow: update [Core ML and On-Device ML](coreml.md).
- New recurring engineering process: update this guide.


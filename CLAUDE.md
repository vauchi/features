# CLAUDE.md - Feature Specifications

> **Inherits**: See [CLAUDE.md](../CLAUDE.md) for project-wide rules.
> **Reference**: [TDD Rules](../_docs/2026-01-22-TDD_RULES.md)

Top-level Gherkin `.feature` files defining expected behavior across all platforms.
These are the source of truth for TDD - shared by Rust, iOS, Android, and desktop.

## Purpose

- Define expected behavior in human-readable scenarios
- Every test (in any crate/platform) should trace back to a scenario here
- Drive implementation through TDD (Red-Green-Refactor)
- Platform-agnostic: specs apply to all clients

## Editing Rules

- Use standard Gherkin syntax: `Feature`, `Scenario`, `Given/When/Then`
- Keep scenarios focused and atomic
- Use `Background` for shared setup
- Tag scenarios: `@wip`, `@security`, `@slow` as appropriate
- `future/` contains planned but not-yet-implemented features
- `ideas/` contains ideas for new features. Not to be implemented. Should be ignored when implementing.

## Adding New Features

1. Write `.feature` file first (Red)
2. Implement tests that parse/reference scenarios
3. Implement code to pass tests (Green)
4. Refactor

## File Naming

- Use snake_case: `contact_exchange.feature`
- One feature per file
- Group related scenarios within a feature

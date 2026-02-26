<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# CLAUDE.md - Feature Specifications

> **Inherits**: See [CLAUDE.md](https://gitlab.com/vauchi/vauchi/-/blob/main/CLAUDE.md) for project-wide rules.
> **Reference**: [TDD Rules](https://docs.vauchi.app/developers/tdd-rules/)

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
- Tag scenarios with domain tags (`@security`, `@slow`) as appropriate

## Lifecycle Tags (MANDATORY)

Every `Scenario` and `Scenario Outline` must have exactly one lifecycle tag:

| Tag | Meaning | When to use |
|-----|---------|-------------|
| `@implemented` | Has passing tests | Scenario verified by test suite |
| `@planned` | Specced, not yet implemented | Default for new scenarios |
| `@wip` | Actively being implemented | During a feature branch |

- New scenarios default to `@planned`
- When tests are written and passing, change to `@implemented`
- `@wip` is temporary — must resolve to `@implemented` or `@planned` before merge
- Lifecycle tags go on the same line as domain tags: `@security @implemented`

## Adding New Features

1. Write `.feature` file first (Red)
2. Implement tests that parse/reference scenarios
3. Implement code to pass tests (Green)
4. Refactor

## File Naming

- Use snake_case: `contact_exchange.feature`
- One feature per file
- Group related scenarios within a feature

## Git Workflow

This repo (`vauchi/features`) follows the standard Vauchi branch strategy.

### Branch Types

| Type | Use Case | Example |
|------|----------|---------|
| `feature/` | New feature specs | `feature/remote-content-updates` |
| `bugfix/` | Fix spec errors | `bugfix/exchange-scenario-typo` |
| `refactor/` | Reorganize specs | `refactor/split-large-feature` |

### Cross-Repo Changes

Feature specs typically accompany implementation in other repos. Use the **same branch name**:

```bash
# Feature spec + implementation + planning
git -C features checkout -b feature/remote-content-updates
git -C core checkout -b feature/remote-content-updates
git -C docs checkout -b feature/remote-content-updates
```

### Linking MRs

In the MR description, link to related MRs:

```markdown
## Related MRs

- vauchi/docs!15 - Planning documents
- vauchi/core!78 - Implementation
```

Format: `{group}/{project}!{mr_number}`

<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# CLAUDE.md - Feature Specifications

> **Inherits**: See [CLAUDE.md](https://gitlab.com/vauchi/vauchi/-/blob/main/CLAUDE.md) for project-wide rules.

Gherkin `.feature` files defining expected behavior across all platforms. Source of truth for TDD.

## Rules

- Standard Gherkin syntax. One feature per file, `snake_case.feature`.
- **Lifecycle tags** (MANDATORY on every Scenario): `@implemented`, `@planned`, `@wip`
- `@wip` must resolve before merge. New scenarios default to `@planned`.
- Domain tags alongside lifecycle: `@security @implemented`
- Draft scenarios live in problem records (`_private/docs/problems/`) until promoted here.

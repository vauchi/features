<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# Feature Scenarios

> **Mirror:** This repo is a read-only mirror of
> [gitlab.com/vauchi/features](https://gitlab.com/vauchi/features).
> Please open issues and merge requests there.

[![Pipeline](https://img.shields.io/endpoint?url=https://vauchi.gitlab.io/features/badges/pipeline.json&label=pipeline)](https://gitlab.com/vauchi/features/-/pipelines)
[![REUSE](https://api.reuse.software/badge/gitlab.com/vauchi/features)](https://api.reuse.software/info/gitlab.com/vauchi/features)

Gherkin scenarios defining Vauchi behavior.
Each scenario should have corresponding tests.

## Lifecycle Tags

Every scenario is tagged with its implementation status:

- `@implemented` — has passing tests in the test suite
- `@planned` — specced but not yet implemented
- `@wip` — actively being implemented (temporary, feature branches only)

Use `grep -c '@implemented' *.feature` to get live implementation counts.
Ideas and brainstorming live in `_private/features/ideas/` (not in this repo).

## Status

Scenario counts and implementation status are live data — count them,
don't read them here (this README once carried a 2026-02 snapshot that
drifted 40% off):

```bash
grep -rc "Scenario:" features/*.feature   # scenarios per file
just grep "@implemented" features                # implemented tally
```

## Priority Definitions

- **P0 (Core)**: Required for MVP. Must work before any release.
- **P1 (Security)**: Security-critical features. Required for public launch.
- **P2 (Infrastructure)**: Relay, federation, labels. Enhances reliability.
- **P3 (Post-launch)**: Advanced privacy features. Opt-in, can ship later.

## Running Scenario Tests

```bash
# Run all tests (includes scenario coverage)
cargo test

# Run tests for specific feature area
cargo test identity
cargo test exchange
cargo test sync
```

## Adding New Scenarios

1. Write scenario in appropriate `.feature` file
2. Write failing test referencing the scenario
3. Implement minimal code to pass
4. Refactor while green

See [TDD Rules](https://docs.vauchi.app/developers/tdd-rules/) for methodology.

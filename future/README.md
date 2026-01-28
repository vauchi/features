<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# Future Features (P2/P3)

This directory previously contained feature specifications for planned but not-yet-implemented functionality. These have been migrated to problem records following the Problem to Solution Flow.

## Migrated Features

| Feature | Problem Record | Priority |
|---------|---------------|----------|
| Contact Recovery | _(listed but no spec existed)_ | P2 |
| Duress Password | `docs/planning/problems/2026-01-26-duress-password/` | P3 |
| Hidden Contacts | `docs/planning/problems/2026-01-26-hidden-contacts/` | P3 |
| Tor Mode | `docs/planning/problems/2026-01-26-tor-mode/` | P3 |

Gherkin `.feature` files will be written as part of the implementation planning phase for each problem, per the Problem to Solution Flow.

## Implementation Notes

When implementing these features:

1. Follow the Problem to Solution Flow (`docs/2026-01-23-problem-to-solution-flow.md`)
2. Start from the problem record in `docs/planning/problems/`
3. Write Gherkin features during the planning phase
4. Follow TDD: Write failing tests first
5. Consider security implications carefully (see `docs/THREAT_ANALYSIS.md`)

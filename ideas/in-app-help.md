<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# In-App Help System

## Requirements
- Privacy-respecting (no analytics on help usage unless opted-in)
- Works offline (help content bundled, not fetched)
- Non-intrusive but discoverable

## Proposed Components

### 1. Contextual Hints
- First-time tooltips on key UI elements
- Dismissable, don't repeat once dismissed
- Stored locally: "seen hints" list

### 2. Help Overlay (?)
- Floating ? button in corner (or in settings)
- Opens overlay explaining current screen
- Written in plain language, no jargon

### 3. FAQ Section (Settings > Help)
- Common questions with expandable answers
- "What happens if I lose my phone?"
- "Can someone track me through vauchi?"
- "How do I remove a contact?"
- "What data is stored where?"

### 4. Onboarding Replay
- Settings option: "Show onboarding again"
- For users who skipped or forgot

### 5. Privacy Explainer
- Dedicated section explaining E2E encryption
- Visual diagram: your phone ↔ contact's phone (no middle)
- "We can't see your data because we never have it"

## Content Principles
- Assume zero technical knowledge
- Lead with "what this means for you" not "how it works"
- Every help item should reinforce trust

## Open Questions
- In-app chat support? (Conflicts with privacy stance)
- Community forum link? (Requires account, friction)
- Email support? (Simple, but slow)

# UI redesign brief (approved by product owner)

Restyle Foqos iOS SwiftUI to match this HTML proof-of-concept. Do **not** change blocking/NFC/Screen Time logic—visual/UI layer only.

## Reference files (read these first)
- `design-ref/index.html` — interactive PoC (colors, type, layout, three screens)
- `design-ref/shot-home.png` — Focus / home
- `design-ref/shot-locked.png` — active session (green)
- `design-ref/shot-mode.png` — mode / profile edit

## Design tokens
- Cream `#F7F0DC`, forest green `#16280D`
- UI / captions: Suisse BP (bundle Regular+Bold from `design-ref/SuisseBPIntl-*.woff2` if feasible; else SF Pro with similar tracking). Uppercase small labels with wide letter-spacing.
- Display titles: high-contrast **serif**, sentence case (not all-caps). PoC uses Instrument Serif; on iOS use a system serif (e.g. `.serif` design) or embed a free serif if already in project—do not invent a commercial font license.
- No card/box chrome: hairline dividers, open lists, generous type.
- Home / Mode: cream background, forest text.
- Active session: **inverted** — forest background, cream text.
- Primary actions: text CTA with top hairline rule + arrow, not filled pill buttons (unless accessibility needs a min hit target—keep visual minimal).

## Screens to restyle (priority)
1. Home / Focus — profile list + lock CTA (see HomeDashboard*, HomeProfilesList*, Welcome, HomeHeader*)
2. Active session — green theme (HomeActiveSessionView*)
3. Profile / mode edit — blocked apps list, unlock settings (profile edit views)

## Constraints
- Follow `AGENTS.md` (2-space indent, naming).
- Prefer existing view structure; restyle with colors, fonts, spacing, remove Material/card clutter.
- If a color asset catalog exists, add cream/forest tokens and use them.
- After edits, summarize files changed and how to preview (Xcode). Cannot run iOS Simulator on this Linux box—code changes only.

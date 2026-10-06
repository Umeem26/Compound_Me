# Documentation

The specification documents were written in **Indonesian** (the product's first language) as the brief for a phase-by-phase rebuild. Code, commit messages and the repository README are in English.

| Folder | Document | What it covers |
|---|---|---|
| [`product/`](product/) | [01 PRD](product/01-PRD.md) | Problem, persona, the build/reduce habit idea, features F-01…F-25, user stories and acceptance criteria, success metrics |
| [`design/`](design/) | [02 Design system](design/02-design-system.md) | Color tokens with computed contrast, typography, spacing, components, motion, the "no AI slop" checklist |
| | [03 UX flows and screens](design/03-ux-flows-and-screens.md) | Information architecture, routes, flows, every screen S-00…S-43 |
| | [04 Brand assets](design/04-brand-assets.md) | Logo mark, icon and splash configuration |
| | [`mockups/`](design/mockups/) | Visual references |
| [`engineering/`](engineering/) | [05 Architecture and data](engineering/05-architecture-and-data.md) | Layers, Drift schema, streak and compound-interest rules, l10n, tooling |
| | [07 Phase 6 audit](engineering/07-audit-fase-6.md) | Audit findings with their status (design rules, accessibility, performance, release, 16 KB) |
| [`process/`](process/) | [06 Execution plan](process/06-execution-plan.md) | The seven phases with the prompts given to Claude Code, definition of done, decision log, manual QA list |
| | [Release notes 2.0.0](process/release-notes-v2.0.0.md) | Text of the 2.0.0 release |
| | [`phase-screens/`](process/phase-screens/) | Screenshots taken during each phase |

Also: [`screenshots/`](screenshots/) (the images used in the README), [`media/`](media/) (two short screen recordings) and the QA tooling in [`tool/qa/`](../tool/qa/README.md).

Where code and these documents disagree, the documents are the intended behavior; the decision log in the execution plan records every deliberate deviation.

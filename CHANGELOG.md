# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed
- The Flutter project moved to the repository root; documentation sorted into `docs/product`, `design`, `engineering` and `process`.
- CI also runs on pushes to `main`, checks formatting and builds a debug APK.

### Added
- MIT license, issue and pull request templates, Dependabot configuration, README screenshots and a social preview image.

## [2.0.0] - 2026-10-01

A full rebuild of the v1 prototype (still available under the `v1-legacy` tag). v1 data is not migrated, and v2 is signed with a new key, so v1 has to be uninstalled first.

### Added
- Wallets and categories; balances are computed from transactions.
- Fast expense and income logging with an amount keypad and undo; history by month with search and filters.
- Habits to build and to reduce, with schedules, one-tap check-in, counts for reduce habits and a streak with a grace day ("never miss twice"). Reduce check-ins create the matching expense.
- Compound Insights: share of spending from reduce habits, yearly projection per habit, consistency and trend for build habits, category donut, and a savings simulator with compound interest.
- Indonesian and English, light and dark themes, hide-balance option, delete-all-data.
- Accessibility: 48 dp touch targets, labels on every action, amounts spelled out for screen readers, layouts checked at 130 % text size.
- Audit tests for design rules, accessibility and error states; performance and release QA scripts.

### Changed
- Android release builds are signed with a dedicated upload key and pass the 16 KB page size checks.

## [1.0.0] - v1 prototype

First prototype (tag `v1-legacy`): basic transactions and habits, signed with the debug key. Superseded by 2.0.0.

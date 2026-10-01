# CompoundMe 2.0.0

A full rebuild of the v1 prototype: a personal finance and habit tracker that shows what your small habits really cost. Everything stays on your phone.

## Install

- Android 8.0 or newer. Download `CompoundMe-2.0.0.apk` on the phone and open it (Android may ask you to allow installs from your browser or file manager).
- **Uninstall the old version first.** Version 2 is signed with a new key and the data of version 1 is not migrated, so Android will not update over it.
- SHA-256: `f2e9a11a55521b8c7c2a45a4321b54621d519b0491b4ea69283d7fa370cb2910`

## What is in it

- Wallets, categories and fast expense logging with undo; history by month, search and filters.
- Habits to **build** and to **reduce**. A reduce habit has a price: every check-in becomes an expense in the wallet and category you chose.
- A streak that forgives one missed day ("never miss twice").
- **Compound Insights:** how much of the month goes to habits you want to cut, the yearly cost of each, a category donut, and a simulator that shows what cutting a habit would save over 1, 3 and 5 years (a simulation, not financial advice).
- Indonesian and English, light and dark, hide-balance option, delete-all-data. No account, no analytics, works offline.

## Checked

`flutter analyze` with 0 issues and 350+ tests, including an audit of every screen in both languages at 130 % text size. The release build was smoke-tested on an Android 15 emulator and passes the 16 KB page size checks.

## Known limits

No export or backup yet; no reminders, budgets, goals or transfers (planned for 2.1). Not yet checked on real devices (TalkBack, haptics, scrolling feel on hardware).

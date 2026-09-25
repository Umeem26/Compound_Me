# CompoundMe v2.0 — Paket Spesifikasi

Paket ini adalah acuan rebuild total CompoundMe v2.0, dari icon sampai end-to-end flow.

| # | Dokumen | Isi | Untuk siapa |
|---|---|---|---|
| 01 | [PRD](01-PRD.md) | Masalah, persona, konsep Bangun/Kurangi, fitur F-01…F-25 dengan prioritas, user stories & acceptance criteria, metrik, risiko | Semua |
| 02 | [Design System](02-design-system.md) | Referensi (DANA, GoPay, Copilot Money, Streaks), token warna (tanpa gradasi, kontras sudah dihitung), tipografi Plus Jakarta Sans, jarak, komponen, motion, copywriting, larangan "AI slop" | Desain & implementasi UI |
| 03 | [UX Flows & Layar](03-ux-flows-and-screens.md) | Arsitektur informasi, rute, 4 flow utama, spesifikasi S-00…S-43 dengan wireframe dan state | Implementasi layar |
| 04 | [Brand Assets](04-brand-assets.md) | Kenapa icon/splash v1 rusak, logo mark baru, daftar aset, konfigurasi `flutter_launcher_icons` & `flutter_native_splash` | Fase 0 |
| 05 | [Arsitektur & Data](05-architecture-and-data.md) | Keputusan teknis, struktur folder, skema Drift, rumus streak & compound, l10n, tooling | Claude Code |
| 06 | [Rencana Eksekusi](06-execution-plan.md) | 7 fase, prompt siap tempel untuk Claude Code, definition of done, checklist tes manual | Kamu (Umem) |

File pendukung di root paket:
- `CLAUDE.md` → taruh di root repo, dibaca otomatis oleh Claude Code.
- `assets/brand/` → icon, adaptive layers, splash, notifikasi, `preview_sheet.png`.
- `tool/generate_brand_assets.py` → generator aset (bisa dijalankan ulang).

Mockup visual: canvas **"CompoundMe v2 — UI Mockup"** di Claude Design (8 artboard: Onboarding, Beranda terang & gelap, Tambah transaksi, Kebiasaan, Wawasan, Simulator, Fondasi visual). Mockup adalah referensi rasa tampilan; kalau ada perbedaan angka/ukuran, **dokumen 02 dan 03 yang menang**. Ekspor artboard sebagai PNG ke `docs/v2/mockups/` supaya Claude Code bisa melihatnya.

Urutan membaca untuk memulai: **06 §0 (persiapan)** → 01 → 02 → 03, lalu jalankan prompt Fase 0.

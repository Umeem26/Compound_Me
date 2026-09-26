# CLAUDE.md — CompoundMe

Panduan untuk Claude Code saat bekerja di repo ini. Baca ini dulu setiap sesi.

## Konteks
- CompoundMe: app Flutter pencatat keuangan + kebiasaan. Ide inti: kebiasaan kecil yang berulang ("Kurangi" = punya biaya, "Bangun" = ingin diperbanyak) dan dampaknya ke uang ("Compound Insights").
- Sedang dalam **rebuild v2.0**. Spesifikasi lengkap ada di `docs/v2/`:
  - `01-PRD.md` — fitur (F-xx) & acceptance criteria
  - `02-design-system.md` — token, tipografi, komponen, larangan "AI slop"
  - `03-ux-flows-and-screens.md` — layar (S-xx) & flow
  - `04-brand-assets.md` — icon & splash
  - `05-architecture-and-data.md` — arsitektur, skema, aturan domain
  - `06-execution-plan.md` — fase & definition of done
- Kalau kode dan dokumen bertentangan, **dokumen yang benar**. Kalau dokumen tidak jelas atau salah, tanya dulu, jangan menebak.

## Perintah (jalankan dari folder `compound_me/`)
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
flutter run            # emulator: Pixel 9, API 35
```

## Aturan wajib
1. **Design system**: warna, ukuran teks, jarak, radius, durasi hanya dari `lib/core/design/`. Tidak ada `Color(0x...)`, `Colors.*`, `fontSize:` atau `EdgeInsets` dengan angka lepas di luar folder itu.
2. **Tanpa gradasi, tanpa emoji, tanpa data dummy, tanpa tombol yang tidak berfungsi, tanpa teks "segera hadir"** di UI rilis.
3. **Semua string UI lewat l10n** (`context.l10n`), selalu isi `app_id.arb` dan `app_en.arb` bersamaan.
4. **Widget tidak menyentuh database.** Presentation → repository/domain. Operasi multi-tabel selalu di dalam `db.transaction`.
5. **Uang = `int` Rupiah.** Format hanya lewat `formatRupiah`. Saldo dihitung dari transaksi, tidak disimpan.
6. **Setiap layar punya empty, loading (skeleton > 300 ms), dan error state.**
7. **Aksesibilitas**: target sentuh ≥ 48 dp, `Semantics` untuk tombol ikon, layout aman di `textScaler` 1.3.
8. Package Android `com.umem.compound_me` harus sama di `namespace`, `applicationId`, baris `package` di `MainActivity.kt`, dan proguard keep rule.
9. Jangan commit `compound_me/.metadata` kecuali memang upgrade Flutter.
10. Komentar kode dalam bahasa Inggris, singkat, menjelaskan "kenapa". Tidak ada komentar seperti "PERBAIKAN DISINI" atau "AJAIB".

## Alur kerja git
- Satu fase = satu branch `v2/phase-N-<nama>` dari `main`.
- Conventional Commits, sertakan ID fitur bila relevan: `feat(F-04): amount keypad`.
- Sebelum PR: `flutter analyze` harus **0 issue**, `flutter test` hijau, app dijalankan di emulator, screenshot layar baru disimpan di `docs/v2/screens/` **di root repo** (bukan `compound_me/docs/`).
- Buat PR ke `main` tapi **jangan merge**. Pemilik repo yang merge setelah review.
- Di akhir tugas, tulis ringkasan: apa yang dikerjakan, keputusan yang diambil sendiri, dan apa yang belum diuji.

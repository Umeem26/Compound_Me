# CompoundMe v2.0 — Arsitektur, Data & Aturan Teknis

| | |
|---|---|
| Status | Draft 1 |
| Pembaca utama | Claude Code (eksekutor) dan Umem (reviewer) |
| Dokumen terkait | `01-PRD.md`, `06-execution-plan.md`, `CLAUDE.md` di root repo |

---

## 1. Keputusan besar

| Keputusan | Pilihan | Alasan |
|---|---|---|
| Strategi rebuild | Tulis ulang `lib/` dari nol di branch `v2/*`. Kode v1 disimpan lewat tag git `v1-legacy`, bukan folder arsip. | Kode v1 punya pola yang bertentangan dengan design system baru (gradasi, ukuran lepas, controller langsung ke DB). Memperbaikinya satu per satu lebih mahal daripada menulis ulang. |
| Database | **Drift (SQLite)**, skema baru v1 untuk "generasi 2" (mulai database bersih). | Belum ada pengguna publik. Migrasi data v1 tidak sepadan. Nama file DB baru: `compoundme.db`. |
| State management | **Riverpod 3** dengan code generation (`@riverpod`). | Riverpod 3 menyatukan `Ref` (tidak ada lagi `XxxRef`), menyatukan Notifier, dan menambah `ref.mounted`. v1 memakai API 2.x yang sudah usang. |
| Navigasi | **go_router** dengan `StatefulShellRoute.indexedStack` untuk bottom nav. | Sudah jadi dependency di v1 tapi tidak dipakai. Mendukung deep link dan menjaga state tiap tab. |
| Lokalisasi | **gen-l10n** (`flutter_localizations` + `intl`), ARB `id` dan `en`. | Cara resmi Flutter, type-safe. |
| Preferensi | `shared_preferences` (tema, bahasa, onboarding selesai, sembunyikan saldo, dompet/kategori terakhir). | Data kecil key-value, tidak perlu masuk SQLite. |
| Ikon | Phosphor dibundel sebagai font + `AppIcons`. | Satu set ikon konsisten (design system §6). `phosphor_flutter` tidak bisa dikompilasi di Flutter 3.43+ (keputusan Fase 0). |
| SQLite native | Lewat `drift`/`sqlite3` (build hooks). | `sqlite3_flutter_libs` sudah EOL dan tidak dipakai (keputusan Fase 0). |
| Grafik | `fl_chart`. | Sudah dipakai di v1, cukup untuk donut & bar. |
| ID data | **UUID string** (`uuid` v4) untuk semua tabel. | Menyiapkan cloud sync P2 tanpa konflik ID auto-increment. |
| Uang | **`int` Rupiah** (tanpa desimal). | Rupiah tidak memakai sen di praktik sehari-hari. Integer menghindari seluruh kelas bug floating point. |
| Saldo | **Dihitung**, tidak disimpan. `saldo = saldo_awal + Σ pemasukan − Σ pengeluaran (± transfer)`. | Menghapus bug v1 di mana saldo tersimpan bisa berbeda dengan riwayat transaksi. |
| Hapus | Soft delete (`deletedAt`) untuk transaksi, lalu dibersihkan permanen setelah 30 hari. Dompet/kategori/kebiasaan: arsip (`archivedAt`). | Mendukung undo dan menyiapkan sync (tombstone). |

## 2. Struktur folder

```
lib/
├── main.dart                     # bootstrap + preserve splash
├── app.dart                      # MaterialApp.router, theme, locale
├── bootstrap/app_bootstrap.dart  # buka DB, baca prefs, muat locale data
├── core/
│   ├── design/                   # tokens.dart, typography.dart, theme.dart, components/
│   ├── l10n/                     # app_id.arb, app_en.arb (output gen-l10n)
│   ├── database/                 # app_database.dart, tables/, daos/, seed.dart
│   ├── preferences/              # app_preferences.dart (+ provider)
│   ├── router/                   # app_router.dart, routes.dart
│   └── utils/                    # money.dart, dates.dart, result.dart, id.dart
└── features/
    ├── onboarding/               # presentation/, application/
    ├── home/
    ├── transactions/             # data/, domain/, presentation/
    ├── wallets/
    ├── categories/
    ├── habits/                   # domain/streak_calculator.dart, domain/schedule.dart
    ├── insights/                 # domain/insights_calculator.dart, domain/compound_projection.dart
    └── settings/
test/                             # cermin struktur lib/
integration_test/                 # 2–3 flow utama (P1 di fase polish)
```

Aturan lapisan:
- `presentation` (widget + controller Riverpod) → hanya memanggil `domain`/repository, **tidak pernah** menyentuh `AppDatabase` langsung.
- `domain` berisi entity dan kalkulator **murni Dart** (tanpa Flutter, tanpa Drift), supaya bisa dites cepat.
- `data` berisi repository + DAO Drift. Semua operasi multi-tabel ada di sini, dibungkus `db.transaction`.

## 3. Skema database (Drift)

Semua tabel punya `id TEXT PK (uuid)`, `createdAt`, `updatedAt` (DateTime, UTC). Foreign key **aktif**: `PRAGMA foreign_keys = ON` di `beforeOpen`.

### `wallets`
| Kolom | Tipe | Catatan |
|---|---|---|
| name | TEXT(1–30) | |
| type | TEXT enum | `cash` · `bank` · `ewallet` · `other` |
| iconKey | TEXT | dari daftar ikon kurasi |
| colorKey | TEXT | salah satu 8 preset |
| initialBalance | INTEGER ≥ 0 | Rupiah |
| sortOrder | INTEGER | |
| archivedAt | DateTime? | |

### `categories`
| Kolom | Tipe | Catatan |
|---|---|---|
| kind | TEXT enum | `expense` · `income` |
| nameKey | TEXT? | kunci l10n untuk kategori default (mis. `catFood`) |
| customName | TEXT? | untuk kategori buatan pengguna. Tepat satu dari `nameKey`/`customName` terisi (CHECK constraint) |
| iconKey, colorKey | TEXT | |
| sortOrder | INTEGER | |
| archivedAt | DateTime? | |

### `transactions`
| Kolom | Tipe | Catatan |
|---|---|---|
| kind | TEXT enum | `expense` · `income` (· `transfer` di v2.1) |
| amount | INTEGER > 0 | selalu positif, arah ditentukan `kind` |
| walletId | TEXT FK → wallets | `ON DELETE RESTRICT` |
| categoryId | TEXT FK → categories | `ON DELETE RESTRICT` |
| note | TEXT? (≤ 120) | |
| occurredAt | DateTime | waktu transaksi (lokal dikonversi ke UTC) |
| habitLogId | TEXT? FK → habit_logs | `ON DELETE SET NULL` |
| deletedAt | DateTime? | soft delete |

Index: `(occurredAt)`, `(walletId, occurredAt)`, `(categoryId, occurredAt)`, `(habitLogId)`.

### `habits`
| Kolom | Tipe | Catatan |
|---|---|---|
| name | TEXT(1–40) | |
| kind | TEXT enum | `build` · `reduce` |
| iconKey, colorKey | TEXT | |
| scheduleType | TEXT enum | `daily` · `weekdays` · `timesPerWeek` |
| scheduleDays | INTEGER | bitmask Senin=1 … Minggu=64 (untuk `weekdays`) |
| timesPerWeek | INTEGER? | 1–7 |
| costPerOccurrence | INTEGER? | wajib > 0 jika `reduce` |
| walletId | TEXT? FK | wajib jika `reduce` |
| categoryId | TEXT? FK | wajib jika `reduce` (kategori `expense`) |
| weeklyLimit | INTEGER? | opsional, untuk `reduce` |
| sortOrder | INTEGER | |
| archivedAt | DateTime? | |

### `habit_logs`
| Kolom | Tipe | Catatan |
|---|---|---|
| habitId | TEXT FK → habits | `ON DELETE CASCADE` (hapus permanen hanya untuk habit tanpa log, lihat PRD) |
| date | TEXT `YYYY-MM-DD` | **tanggal lokal**, bukan timestamp. UNIQUE `(habitId, date)` |
| count | INTEGER ≥ 1 | jumlah kejadian hari itu (build selalu 1) |

**Relasi check-in ↔ transaksi:** untuk kebiasaan `reduce`, setiap kejadian = satu baris `transactions` dengan `habitLogId` yang sama. Menaikkan `count` = tambah transaksi. Menurunkan = soft delete transaksi terbaru dari log itu. `count` 0 = hapus log. Semuanya dalam satu `db.transaction`.

### Query saldo (contoh)
```sql
SELECT w.id,
       w.initial_balance
       + COALESCE(SUM(CASE WHEN t.kind = 'income'  THEN t.amount
                           WHEN t.kind = 'expense' THEN -t.amount END), 0) AS balance
FROM wallets w
LEFT JOIN transactions t ON t.wallet_id = w.id AND t.deleted_at IS NULL
WHERE w.archived_at IS NULL
GROUP BY w.id;
```
Dipakai lewat `watch()` Drift supaya UI reaktif otomatis, tidak perlu `invalidate` manual seperti v1.

### Seed
Kategori default (lihat `03-ux-flows-and-screens.md` S-42) dimasukkan di `MigrationStrategy.onCreate`. Dompet dan kebiasaan **tidak** di-seed. Keduanya dibuat di onboarding.

## 4. Aturan domain

### 4.1 Uang
- `Money` = extension/typedef di atas `int`. Format lewat satu fungsi: `formatRupiah(int value, {bool signed = false, bool compact = false})`.
  - `formatRupiah(22000)` → `Rp 22.000`; `signed` → `−Rp 22.000` / `+Rp 22.000`; `compact` (grafik) → `22 rb` (id) / `22K` (en).
- Parsing input hanya dari `AmountKeypad` (digit), tanpa parsing string berformat.

### 4.2 Jadwal kebiasaan
- `isScheduledOn(habit, date)`: `daily` = selalu; `weekdays` = bit hari itu aktif; `timesPerWeek` = setiap hari "boleh", target dihitung per minggu (Senin–Minggu).

### 4.3 Streak dengan "jangan bolong dua kali"
Untuk `daily`/`weekdays` (satuan hari):
1. Mulai dari **kemarin** (hari ini belum dianggap gagal). Kalau hari ini sudah check-in, hitung juga hari ini.
2. Telusuri mundur hanya hari yang terjadwal.
3. Hari check-in → `streak += 1`, reset penghitung "terlewat berturut".
4. Hari terlewat → kalau ini terlewat pertama (berturut), tandai **hari longgar** dan lanjut (tidak menambah streak). Kalau terlewat kedua berturut → berhenti.
5. `bestStreak` = maksimum dari seluruh riwayat dengan aturan yang sama.

Untuk `timesPerWeek` (satuan minggu): minggu "berhasil" kalau jumlah check-in ≥ target. Minggu berjalan tidak dihitung gagal. Aturan longgar yang sama berlaku per minggu. Streak ditampilkan sebagai "N minggu".

Untuk `reduce`: streak hanya ada kalau `weeklyLimit` diisi. Minggu berhasil = jumlah kejadian ≤ batas.

**Konsistensi 30 hari:** `hari terjadwal yang di-check-in / hari terjadwal` dalam 30 hari terakhir (hari ini dihitung hanya jika sudah check-in). Untuk `timesPerWeek`: `Σ min(check-in minggu, target) / Σ target` dalam 4 minggu terakhir yang lengkap + minggu berjalan secara proporsional.

Semua ini diimplementasikan di `habits/domain/streak_calculator.dart` sebagai fungsi murni yang menerima `List<HabitLog>`, `Habit`, `DateTime today`, dan **wajib** punya unit test untuk: tanpa log, streak berjalan, satu hari longgar, dua hari terlewat, hari tidak terjadwal di tengah, pergantian bulan/tahun, dan `timesPerWeek`.

### 4.4 Compound Insights
Semua di `insights/domain/`, murni Dart:

- **Porsi kebiasaan reduce** = Σ amount transaksi dengan `habitLogId` dari habit `reduce` pada periode ÷ Σ semua pengeluaran periode.
- **Frekuensi rata-rata per minggu** = Σ count 28 hari terakhir ÷ 4.
- **Proyeksi tahunan** = frekuensi/minggu × 52 × biaya per kejadian.
- **Simulasi hemat** = proyeksi tahunan × persen pengurangan.
- **Proyeksi compounding** (setoran bulanan tetap `P` = hemat tahunan ÷ 12, bunga tahunan `r`, `n` tahun, bunga majemuk bulanan):
  - `r = 0` → `FV = P × 12n`
  - `r > 0` → `FV = P × ((1 + r/12)^(12n) − 1) / (r/12)`
  - Tampilkan untuk n = 1, 3, 5. Bulatkan ke ribuan terdekat. Selalu dengan disclaimer.
- **Tren kebiasaan build** = konsistensi bulan ini − konsistensi bulan lalu (poin persen).

Unit test wajib: periode tanpa data, pembagian dengan nol, r = 0, contoh angka yang diverifikasi manual (mis. P = 100.000, r = 5%, n = 1 → ≈ 1.227.886).

## 5. Lokalisasi

- `l10n.yaml`: `arb-dir: lib/core/l10n`, `template-arb-file: app_id.arb`, `output-localization-file: app_localizations.dart`, `nullable-getter: false`.
- `pubspec.yaml`: `flutter: generate: true`.
- Semua string UI lewat `context.l10n.xxx` (extension). **Tidak ada string literal di widget**, kecuali `Rp` dan simbol angka.
- Nama kategori default memakai `nameKey` → dipetakan ke getter l10n.
- Bahasa: disimpan di preferensi, diterapkan ke `MaterialApp.locale`. `initializeDateFormatting()` untuk `id` dan `en` di bootstrap (pelajaran dari crash `LocaleDataException` v1).
- Plural pakai ICU di ARB (`{count, plural, =1{1 kali} other{{count} kali}}`).

## 6. Kualitas & tooling

| Hal | Aturan |
|---|---|
| Lint | `very_good_analysis` (atau `flutter_lints` + aturan strict di `analysis_options.yaml`). Target: **0 issue**, bukan hanya 0 error. |
| Format | `dart format` sebelum commit. |
| Test | Unit test untuk semua `domain/` dan repository (DB in-memory: `NativeDatabase.memory()`). Widget test untuk komponen kunci (AmountKeypad, HabitChip, BalanceHeader). Minimal 1 widget test per layar utama yang memastikan empty state tampil. |
| CI | GitHub Actions: `flutter pub get` → `dart run build_runner build` → `flutter analyze` → `flutter test`, jalan di setiap PR. |
| Commit | Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`), sebutkan ID fitur bila relevan: `feat(F-04): amount keypad`. |
| Branch | Satu branch per fase: `v2/phase-0-foundation`, `v2/phase-1-data`, dst. PR ke `main`, **merge setelah direview Umem**. |

## 7. Pelajaran v1 yang wajib dipertahankan

- Package Android `com.umem.compound_me`: `namespace`, `applicationId`, **baris `package` di `MainActivity.kt`**, dan proguard keep rule harus sama. (Crash `ClassNotFoundException` v1 berasal dari sini.)
- `initializeDateFormatting` sebelum dipakai (crash `LocaleDataException` v1).
- Check-in harus aman dari tap ganda (guard in-flight) dan atomik.
- Jangan commit `compound_me/.metadata` hasil tooling kecuali memang upgrade Flutter.
- Uji di emulator setelah perubahan native (ikon, splash, manifest), bukan hanya `flutter test`.

## 8. Persiapan sync (P2), dikerjakan sekarang agar murah nanti

- UUID untuk semua ID, `updatedAt` di semua tabel, soft delete/arsip alih-alih hapus keras.
- Repository punya interface (abstract class) sehingga implementasi remote bisa ditambah.
- Tidak ada logika bisnis di widget.

## Sumber

- Riverpod 3.0 — What's new: https://riverpod.dev/docs/whats_new
- Flutter internationalization (gen-l10n): https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization

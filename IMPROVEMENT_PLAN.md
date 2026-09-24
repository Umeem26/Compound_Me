# CompoundMe — Improvement Plan (Fase 1: Bug Fix)

Konteks: audit kode 25 Sept 2026. Stack: Flutter + Riverpod 2 (riverpod_generator) + Drift/SQLite.
Semua path di bawah relatif ke folder `compound_me/`.

## Aturan kerja
- Kerjakan di branch baru `improve/phase-1` dari `main`. JANGAN push ke remote.
- Satu commit per item, format commit mengikuti repo ini (`fix: ...`, `feat: ...`, `test: ...`).
- Jangan ubah styling/tema UI di luar yang disebut di sini.
- Pertahankan line ending file yang sudah ada.
- Setelah semua item: `flutter analyze` (tidak boleh ada error baru) dan `flutter test` (harus hijau).
- Akhiri dengan ringkasan singkat per item: apa yang diubah dan kenapa.

## 1. Splash screen loop
`lib/src/features/dashboard/presentation/screens/splash_screen.dart` — `_navigateToHome()` melakukan
`pushReplacement` ke `MyApp()`, padahal `MyApp.home` = `SplashScreen` → splash berulang terus, `MainScreen` tidak pernah tercapai.
Fix: navigasi ke `const MainScreen()`, hapus import `package:compound_me/main.dart` yang jadi tidak terpakai.

## 2. Habit bisa dicentang berkali-kali + tidak bisa di-uncheck
`lib/src/features/habits/presentation/controllers/habit_controller.dart` → `TodayHabitLogs.checkHabit`
tidak mengecek log hari ini, jadi setiap tap membuat log baru DAN transaksi otomatis baru (saldo terpotong berulang).
Fix yang diinginkan (toggle):
- Kalau habit BELUM dicentang hari ini → buat log; kalau `costPerUnit > 0`, buat transaksi otomatis seperti sekarang.
- Kalau SUDAH dicentang hari ini → hapus log hari ini untuk habit itu dan hapus transaksi otomatis yang terkait
  (saldo dompet dikembalikan).
- Untuk menautkan transaksi ke log secara andal (jangan cocokkan lewat teks note), tambahkan kolom nullable
  `habitLogId` (references HabitLogs.id) di tabel `Transactions` (`lib/src/core/database/tables.dart`).
- Naikkan `schemaVersion` ke 2 di `app_database.dart` dan tambahkan `MigrationStrategy`:
  `onCreate: m.createAll()` + seed kategori default (pindahkan seeder dari `CategoryList.build()` ke sini),
  `onUpgrade: from < 2 → m.addColumn(transactions, transactions.habitLogId)`.
  Nama file DB `compound_me_v3.sqlite` JANGAN diganti lagi (itu cara lama "reset" yang menghapus data user).
- Tambahkan method repository yang dibutuhkan (hapus log, cari/hapus transaksi berdasarkan habitLogId).
- Jangan aktifkan `PRAGMA foreign_keys` di fase ini (akan membuat delete habit gagal kalau masih ada log) — itu Fase 4.
- Jalankan `dart run build_runner build --delete-conflicting-outputs` setelah ubah tabel/provider.

## 3. Update saldo tidak atomik
`lib/src/features/finance/presentation/controllers/transaction_controller.dart` — add/edit/delete transaksi dan
update saldo dompet berjalan sebagai langkah terpisah, dan `_updateWalletBalance` memakai pola read-modify-write.
Fix:
- Bungkus setiap operasi (insert/update/delete transaksi + koreksi saldo) di dalam `db.transaction(() async { ... })`.
- Update saldo dengan ekspresi SQL relatif (`balance = balance + diff`), bukan baca-lalu-tulis. Contoh Drift:
  `(db.update(db.wallets)..where((w) => w.id.equals(id))).write(WalletsCompanion.custom(balance: db.wallets.balance + Variable(diff)))`.
- Alur transaksi otomatis dari habit (item 2) juga harus lewat jalur atomik yang sama.

## 4. Saldo di Home basi
Setelah hapus transaksi (swipe di Home) atau centang habit berbiaya, `walletListProvider` tidak di-invalidate,
jadi kartu "Total Aset Bersih" dan daftar dompet tidak berubah sampai ada refresh lain.
Fix: di `TransactionList` (add/edit/delete) panggil `ref.invalidate(walletListProvider)` setelah operasi sukses.
Invalidate manual di `add_transaction_screen.dart` jadi redundant — boleh dihapus.

## 5. Tambah habit dengan nama kosong → crash
`lib/src/features/habits/presentation/screens/habits_screen.dart` → `_showAddHabitDialog`: tidak ada validasi, sementara
kolom `name` punya `withLength(min: 1, max: 50)` sehingga insert melempar exception.
Fix: `trim()` nama, tolak jika kosong atau > 50 karakter dengan pesan error di field (jangan tutup dialog).
Sekalian dispose `TextEditingController` di form screen yang StatefulWidget (`add_transaction_screen.dart`, `add_wallet_screen.dart`).

## 6. Test yang benar-benar menguji logika
`test/widget_test.dart` masih template counter bawaan Flutter (pasti gagal). Ganti dengan unit test logika:
- Ubah konstruktor jadi `AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());`
  supaya test bisa pakai `NativeDatabase.memory()`.
- Test minimal: tambah pengeluaran mengurangi saldo; tambah pemasukan menambah saldo; edit transaksi pindah dompet
  mengoreksi kedua dompet; hapus transaksi mengembalikan saldo; centang habit berbiaya 2x di hari yang sama = toggle
  (saldo kembali ke awal, tidak terpotong dua kali).
- Pakai `ProviderContainer` dengan override `appDatabaseProvider` ke DB in-memory.

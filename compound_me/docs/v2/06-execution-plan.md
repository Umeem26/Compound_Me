# CompoundMe v2.0 — Rencana Eksekusi & Prompt Claude Code

| | |
|---|---|
| Status | Siap dipakai |
| Cara pakai | Kerjakan fase berurutan. Satu fase = satu branch = satu PR. Merge hanya setelah kamu review dan tes manual. |

---

## 0. Persiapan (sekali saja)

1. Ekstrak paket dokumen ke **root repo** `Compound_Me/`, sehingga strukturnya:
   ```
   Compound_Me/
   ├── CLAUDE.md                 ← dibaca otomatis oleh Claude Code
   ├── docs/v2/                  ← 01-PRD.md … 06-execution-plan.md, README.md
   ├── assets/brand/             ← icon & splash baru
   ├── tool/generate_brand_assets.py
   └── compound_me/              ← proyek Flutter (lib/, android/, ...)
   ```
   > `assets/brand/` dan `tool/` nanti dipindah ke dalam `compound_me/` oleh Claude Code di Fase 0, karena `pubspec.yaml` ada di sana.
2. Dari canvas Claude Design "CompoundMe v2 — UI Mockup", ekspor tiap artboard sebagai PNG ke `docs/v2/mockups/` (nama file = ID layar, mis. `S-10-beranda.png`). Claude Code tidak bisa membuka link canvas, jadi gambar ini yang jadi referensi visualnya.
3. Commit dokumen dulu langsung di `main`: `docs: add CompoundMe v2 product & design specs`.
4. Di VS Code, buka panel Claude Code. **Gunakan plan mode** (Shift+Tab sampai mode "plan") di awal setiap fase supaya Claude Code menyusun rencana dulu, lalu kamu setujui.

## 1. Pola kerja per fase

```
Prompt fase (plan mode) → review rencana → setujui
→ Claude Code eksekusi di branch v2/phase-N-...
→ flutter analyze (0 issue) + flutter test (hijau) + jalan di emulator
→ Claude Code ambil screenshot layar baru (adb) dan buat PR (JANGAN merge)
→ Kamu: tes manual pakai checklist fase → kirim catatan ke Cowork untuk review
→ Revisi kalau perlu → merge
```

Perintah screenshot yang bisa dipakai Claude Code:
```
adb exec-out screencap -p > docs/v2/screens/phase-N-<nama-layar>.png
```

## 2. Fase-fase

### Fase 0 — Fondasi & identitas
**Branch:** `v2/phase-0-foundation` · **Fitur:** F-01, F-11 (kerangka), S-00

**Hasil akhir:** app terbuka dengan **satu** splash baru → shell kosong dengan bottom nav 5 slot dan design system aktif. Icon baru terpasang dan tidak terpotong.

**Prompt:**
```
Baca CLAUDE.md, lalu docs/v2/01-PRD.md, 02-design-system.md, 04-brand-assets.md, dan 05-architecture-and-data.md. Lihat juga gambar di docs/v2/mockups/ sebagai referensi rasa tampilan (angka pasti tetap dari dokumen). Kita mulai rebuild CompoundMe v2 Fase 0 (lihat docs/v2/06-execution-plan.md bagian Fase 0).

Buat rencana dulu, jangan eksekusi sebelum saya setujui.

Lingkup Fase 0:
1. Buat tag git v1-legacy di commit main saat ini, lalu branch v2/phase-0-foundation.
2. Pindahkan assets/brand/ dan tool/ ke dalam compound_me/. Hapus seluruh isi lib/ dan test/ lama (riwayat tetap ada di tag v1-legacy). Hapus dependency yang tidak dipakai lagi (local_auth, font_awesome_flutter, dll.) dan aset lama assets/icon/.
3. Update dependency ke versi stabil terbaru: flutter_riverpod + riverpod_annotation + riverpod_generator (v3), go_router, drift + drift_dev + sqlite3_flutter_libs, shared_preferences, intl, flutter_localizations, phosphor_flutter, fl_chart, uuid, flutter_native_splash, flutter_launcher_icons, very_good_analysis (atau lint strict setara). Pastikan build tetap jalan dan kompatibel dengan page size 16 KB Android.
4. Pasang icon & splash baru persis sesuai 04-brand-assets.md §4 dan §5 (adaptive_icon_foreground_inset: 0, hanya satu splash native dengan preserve/remove, tanpa SplashScreen widget, tanpa delay buatan).
5. Bangun design system sesuai 02-design-system.md: lib/core/design/tokens.dart, typography.dart (Plus Jakarta Sans dibundel sebagai aset font, angka tabular untuk nominal), theme.dart (M3 + ThemeExtension, terang & gelap), dan komponen dasar: AppBottomNav, AppLargeTitle, PrimaryButton, SecondaryButton, GhostButton, AppCard, EmptyState, UndoSnackbar, SegmentedToggle.
6. Setup gen-l10n (id sebagai template, en) sesuai 05-architecture-and-data.md §5, dengan string untuk shell dan empty state tiap tab.
7. go_router dengan StatefulShellRoute: tab Beranda, Kebiasaan, Wawasan, Profil + tombol Tambah di tengah (untuk sekarang membuka bottom sheet placeholder bertuliskan judul saja). Setiap tab menampilkan EmptyState yang benar, bukan layar kosong.
8. Bootstrap (05 §2): buka database kosong (skema belum perlu lengkap), baca preferensi, initializeDateFormatting id & en, lalu remove splash setelah frame pertama.
9. Pastikan MainActivity.kt tetap package com.umem.compound_me dan proguard keep rule sesuai.
10. GitHub Actions: analyze + test di setiap PR.
11. Tambah widget test: bottom nav berpindah tab, EmptyState tampil di tiap tab, tema gelap tidak crash.

Definition of done: flutter analyze 0 issue, flutter test hijau, app jalan di emulator Pixel 9 terang dan gelap, screenshot icon di launcher + splash + 4 tab disimpan di docs/v2/screens/, lalu push dan buat PR ke main tanpa merge. Tulis ringkasan dan keputusan yang kamu ambil sendiri.
```

**Checklist tes manual kamu:**
- [ ] Icon di launcher utuh (tidak ter-zoom) di home screen dan di app drawer. Coba juga themed icon (tahan home screen → Wallpaper & style → Themed icons).
- [ ] Hanya ada satu splash, tidak ada ikon dompet Material.
- [ ] Pindah-pindah tab lancar, teks tidak kebesaran.
- [ ] Ganti mode gelap di HP → app ikut.

### Fase 1 — Lapisan data & logika domain
**Branch:** `v2/phase-1-data` · **Fitur:** fondasi F-03 s.d. F-09

**Hasil akhir:** skema database lengkap, repository, dan semua kalkulator domain (uang, jadwal, streak, insights) dengan unit test. Belum ada UI baru.

**Prompt:**
```
Lanjut Fase 1 sesuai docs/v2/06-execution-plan.md. Baca ulang docs/v2/05-architecture-and-data.md §3 dan §4. Buat rencana dulu.

Lingkup:
1. Skema Drift lengkap (wallets, categories, transactions, habits, habit_logs) persis sesuai §3: UUID, createdAt/updatedAt, soft delete/arsip, CHECK constraint, index, PRAGMA foreign_keys = ON di beforeOpen, seed kategori default di onCreate (nameKey + ARB id/en).
2. Repository (interface + implementasi Drift) per fitur: WalletRepository (termasuk stream saldo dihitung dengan query §3), CategoryRepository, TransactionRepository (tambah, edit, soft delete, restore/undo, purge > 30 hari, filter bulan/kategori/dompet/teks), HabitRepository (CRUD, arsip, check-in toggle, set count untuk reduce. Semua operasi log + transaksi atomik dalam satu db.transaction dan aman dari pemanggilan ganda).
3. Domain murni Dart: formatRupiah (§4.1), isScheduledOn (§4.2), StreakCalculator (§4.3), InsightsCalculator + CompoundProjection (§4.4).
4. Unit test lengkap untuk semua poin di §4 (termasuk kasus yang disebut wajib), plus test repository dengan NativeDatabase.memory(): saldo terhitung benar setelah tambah/edit/hapus/undo, check-in reduce 2x lalu kurangi 1, arsip dompet yang punya transaksi, hapus kategori yang dipakai ditolak.
5. Target coverage domain/ ≥ 80% (laporkan angkanya).

DoD: analyze 0 issue, test hijau, laporkan coverage. Push dan buat PR tanpa merge.
```

**Checklist kamu:** baca ringkasan test, pastikan kasus streak "satu hari longgar" dan "dua hari terlewat" ada dan lulus.

### Fase 2 — Onboarding, Dompet, Kategori, Profil & Pengaturan
**Branch:** `v2/phase-2-onboarding-setup` · **Fitur:** F-02, F-06, F-07, F-10, F-11 · **Layar:** S-01, S-40, S-41, S-42, S-43

**Prompt:**
```
Lanjut Fase 2. Baca docs/v2/03-ux-flows-and-screens.md bagian S-01, S-40, S-41, S-42, S-43 dan Flow A, serta PRD F-02, F-06, F-07, F-10, F-11 beserta acceptance criteria-nya. Buat rencana dulu.

Implementasikan layar-layar itu persis mengikuti design system (hanya token dan komponen dari lib/core/design, tanpa angka lepas, tanpa gradasi, tanpa emoji). Termasuk:
- Onboarding lengkap dengan penyimpanan progres per langkah dan redirect router.
- 8 template kebiasaan (id/en) di langkah terakhir onboarding (tersimpan sebagai habit sungguhan lewat HabitRepository).
- Komponen baru yang dibutuhkan: AppTextField, RowPicker, AmountKeypad + AmountDisplay (dipakai di saldo awal dompet), pemilih ikon & warna preset.
- Ganti bahasa & tema langsung berlaku tanpa restart dan tersimpan.
- Hapus semua data dengan konfirmasi 2 langkah.
Widget test: onboarding sampai selesai, validasi nama kosong, dompet dengan transaksi hanya bisa diarsipkan.

DoD seperti biasa + screenshot semua layar baru (terang & gelap, bahasa id & en untuk onboarding). PR tanpa merge.
```

**Checklist kamu:**
- [ ] Onboarding selesai ≤ 60 detik tanpa bingung.
- [ ] Tutup app di tengah onboarding → buka lagi, lanjut dari langkah terakhir.
- [ ] Ganti ke English → semua teks berganti, tanggal berbahasa Inggris, uang tetap `Rp 25.000`.
- [ ] Tidak ada teks yang kepotong dengan ukuran font HP diperbesar.

### Fase 3 — Transaksi & Beranda
**Branch:** `v2/phase-3-transactions` · **Fitur:** F-03 (tanpa strip kebiasaan & kartu insight), F-04, F-05 · **Layar:** S-10, S-11, S-12, S-13

**Prompt:**
```
Lanjut Fase 3. Baca 03-ux-flows-and-screens.md S-10, S-11, S-12, S-13, Flow B, dan PRD F-03/F-04/F-05. Buat rencana dulu.

Implementasikan:
- Tombol Tambah di tengah bottom nav membuka sheet S-11 (keypad khusus, default pintar: tipe pengeluaran, kategori & dompet terakhir dipakai, tanggal sekarang), mode tambah dan edit.
- Beranda S-10: sapaan dengan nama + waktu, BalanceHeader (sembunyikan saldo tersimpan), ringkasan bulan, transaksi terbaru per hari, empty state. Slot strip kebiasaan dan kartu insight dibiarkan tersembunyi dulu (diisi Fase 4 & 5).
- Riwayat S-13 dengan filter bulan/kategori/dompet, pencarian, swipe hapus + undo. Detail S-12.
- Semua reaktif lewat stream Drift (tidak ada invalidate manual untuk saldo).
- Haptic sesuai design system §8.
Widget test: simpan pengeluaran mengubah saldo di Beranda, undo hapus mengembalikan transaksi, tombol Simpan nonaktif saat nominal 0.
Ukur dan laporkan: berapa tap dari tombol Tambah sampai tersimpan untuk pengeluaran dengan kategori terakhir.

DoD + screenshot. PR tanpa merge.
```

**Checklist kamu:**
- [ ] Catat "kopi Rp 22.000" ≤ 5 detik (pakai stopwatch HP).
- [ ] Hapus transaksi → Urungkan → kembali utuh, saldo benar.
- [ ] Edit transaksi pindah dompet → saldo kedua dompet benar.

### Fase 4 — Kebiasaan
**Branch:** `v2/phase-4-habits` · **Fitur:** F-08 + strip kebiasaan di Beranda · **Layar:** S-20, S-21, S-22

**Prompt:**
```
Lanjut Fase 4. Baca 03-ux-flows-and-screens.md S-20, S-21, S-22, Flow C, PRD F-08, dan 05-architecture-and-data.md §4.3. Buat rencana dulu.

Implementasikan tab Kebiasaan, form buat/edit (build & reduce, jadwal, biaya + dompet + kategori untuk reduce, batas mingguan), detail dengan HabitCalendar + streak + konsistensi 30 hari, dan HabitChip strip di Beranda. Check-in 1 tap (toggle) dengan undo snackbar dan haptic, long-press untuk stepper jumlah pada reduce. Transaksi dari kebiasaan berlabel "Dari kebiasaan" di list dan detail, dan menghapusnya membatalkan check-in terkait setelah konfirmasi.
Widget test: tap cepat 5x tetap konsisten, check-in reduce mengurangi saldo dan uncheck mengembalikan, hari longgar tampil di kalender.

DoD + screenshot. PR tanpa merge.
```

**Checklist kamu:**
- [ ] Buat "Kopi Rp 25.000, pakai GoPay, kategori Makanan" → check-in → transaksi masuk ke GoPay, bukan dompet pertama.
- [ ] Long-press → set 2 kopi → 2 transaksi. Turunkan ke 1 → tinggal 1.
- [ ] Bolong satu hari (ubah tanggal HP atau pakai data uji) → streak tidak putus, ditandai hari longgar.

### Fase 5 — Compound Insights
**Branch:** `v2/phase-5-insights` · **Fitur:** F-09 + kartu insight Beranda · **Layar:** S-30, S-31

**Prompt:**
```
Lanjut Fase 5. Baca 03-ux-flows-and-screens.md S-30, S-31, Flow D, bagian kartu insight di S-10, PRD F-09, dan 05 §4.4. Buat rencana dulu.

Implementasikan tab Wawasan (kartu porsi kebiasaan reduce, daftar reduce dengan proyeksi, daftar build dengan konsistensi & tren, donut kategori yang bisa di-tap ke riwayat terfilter), simulator S-31 (slider 0–100%, toggle tabung & kembangkan dengan bunga 0/3/5% atau input, proyeksi 1/3/5 tahun, disclaimer permanen, tombol atur batas mingguan), empty state data < 7 hari dengan progres, dan kartu insight di Beranda sesuai aturan prioritas.
Tambah alat bantu debug (hanya di build debug): tombol di Pengaturan untuk mengisi data contoh 60 hari agar layar Wawasan bisa diuji. Tidak boleh ada di build release.
Test: InsightsCalculator dengan data contoh, widget test empty state.

DoD + screenshot (dengan data contoh). PR tanpa merge.
```

**Checklist kamu:**
- [ ] Angka di Wawasan cocok dengan hitungan manual kamu untuk satu kebiasaan.
- [ ] Simulator: 50% dari kopi 3x/minggu × Rp 25.000 ≈ Rp 1,95 jt/tahun.
- [ ] Disclaimer selalu terlihat.

### Fase 6 — Polish, aksesibilitas, rilis
**Branch:** `v2/phase-6-polish` · **Fitur:** F-12 + non-fungsional PRD §8

**Prompt:**
```
Fase 6 (polish). Lakukan audit terhadap docs/v2/02-design-system.md §10 (daftar larangan AI slop) dan 03-ux-flows-and-screens.md §4–§5 di SEMUA layar, lalu perbaiki temuannya. Buat rencana dulu berisi daftar temuan.

Termasuk:
- Grep angka lepas (Color(0x, Colors., fontSize:, EdgeInsets dengan angka) di luar lib/core/design → harus 0.
- Semantics label di semua tombol ikon (id & en), nominal dibaca lengkap.
- Uji textScaler 1.3 di semua layar, perbaiki overflow.
- Loading skeleton hanya jika > 300 ms, error state dengan Coba lagi di semua layar yang membaca data.
- Performa: 1.000 transaksi uji → scroll riwayat mulus, cold start diukur di mode profile.
- Build release (R8) dan jalankan di emulator; pastikan tidak ada crash (keep rule, drift, sqlite3).
- Cek kompatibilitas page size 16 KB (emulator image 16 KB).
- README baru (bahasa Inggris): deskripsi jujur, fitur, screenshot, arsitektur, cara build. Hapus klaim Web.
- Bump versi ke 2.0.0+1.

DoD + laporan audit sebelum/sesudah. PR tanpa merge.
```

**Checklist kamu (uji pengguna kecil):**
- [ ] Minta 3–5 teman (persona target) mencoba tanpa penjelasan: onboarding, catat kopi, cari kebiasaan termahal. Catat di mana mereka ragu.
- [ ] Isi skor SUS (10 pertanyaan standar) dari mereka. Target ≥ 75.

## 3. Setelah v2.0

1. Update dokumen `compoundme-audit.md` di project Cowork dengan status akhir.
2. Lanjut ke konten LinkedIn: teks "product ad" + media Canva memakai screenshot v2.0 (lihat to-do LinkedIn).
3. Backlog v2.1: pengingat (F-20), anggaran (F-21), goals (F-22), transfer (F-23), ekspor (F-24).

## 4. Kalau hasil Claude Code tidak sesuai

Pakai prompt koreksi yang spesifik, jangan "perbaiki UI-nya":
```
Layar <S-xx> belum sesuai docs/v2/02-design-system.md: <sebutkan: ukuran judul terlalu besar / ada gradasi di X / jarak antar kartu tidak 16>. Perbaiki hanya itu, jangan ubah layar lain, lalu kirim screenshot sebelum/sesudah.
```

## 5. Log keputusan eksekusi

| Fase | Keputusan | Alasan | Status |
|---|---|---|---|
| 0 | Ikon Phosphor dibundel sebagai font + `AppIcons`, bukan paket `phosphor_flutter` | Paket (rilis Mei 2024) gagal dikompilasi di Flutter 3.43+ | Disetujui |
| 0 | `sqlite3_flutter_libs` dihapus | Sudah EOL, SQLite ikut lewat drift/sqlite3 | Disetujui |
| 0 | Plus Jakarta Sans lewat `fonts:` pubspec | Offline, tanpa kedipan font | Disetujui |
| 0 | Splash terang tetap teal | Titik putih logo hilang di latar terang (03 S-00 diperbarui) | Disetujui |
| 0 | 3 lint very_good_analysis dimatikan (doc comment API publik + 2 lint sintaks konstruktor Dart 3.13) | Alasan tercatat di `analysis_options.yaml` | Disetujui |
| 0 | Durasi pressed 120 ms (`motionFast`) | Konsisten dengan token yang ada (02 §7.2 diperbarui) | Disetujui |
| 0 | Nilai pressed/tint tema gelap dihitung sendiri | Spesifikasi hanya memberi nilai terang | Disetujui, dicatat ke 02 §11 di Fase 1 |
| 0 | Lisensi font OFL & Phosphor MIT ikut dibundel | Kewajiban lisensi | Perlu didaftarkan ke `LicenseRegistry` (Fase 1) |

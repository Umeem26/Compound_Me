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
Prompt fase (plan mode, atau rencana ditulis di deskripsi PR) → setujui
→ Claude Code eksekusi di branch v2/phase-N-...
→ flutter analyze (0 issue) + flutter test (hijau) + jalan di emulator
→ Checklist fase dijalankan OTOMATIS di emulator sebelum PR:
    integration test  compound_me/integration_test/phaseN_checklist_test.dart
    skrip adb         compound_me/tool/qa/qa_phaseN.py (force stop, font 1,3, mode gelap, intent)
  hasilnya ditulis sebagai tabel lulus/gagal di PR (cara pakai: compound_me/tool/qa/README.md)
→ Claude Code ambil screenshot layar baru (adb) dan buat PR (JANGAN merge)
→ Kamu: review PR + tabel QA → kirim catatan ke Cowork untuk review
→ Revisi kalau perlu → merge
```

Checklist tiap fase di §2 adalah daftar yang dijalankan otomatis itu. Yang hanya bisa dinilai manusia (waktu, rasa, TalkBack, HP sungguhan) dikumpulkan di Fase 6, "QA manual sebelum rilis", dan setiap fase menambahkan itemnya ke sana.

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

**Checklist fase (otomatis, §1):**
- [ ] Onboarding selesai: jumlah tap dan layar dilaporkan (waktu ≤ 60 detik tanpa bingung dinilai di QA manual Fase 6).
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

**Checklist fase (otomatis, §1):**
- [ ] Catat "kopi Rp 22.000": jumlah tap dari tombol Tambah sampai tersimpan dilaporkan (≤ 5 detik dinilai di QA manual Fase 6).
- [ ] Hapus transaksi → Urungkan → kembali utuh, saldo benar.
- [ ] Edit transaksi pindah dompet → saldo kedua dompet benar.
- [ ] Toggle "Sembunyikan saldo" di Pengaturan: saat app dibuka, saldo di BalanceHeader tertutup; ikon mata membukanya. Matikan toggle → saldo terlihat saat app dibuka.

### Fase 4 — Kebiasaan
**Branch:** `v2/phase-4-habits` · **Fitur:** F-08 + strip kebiasaan di Beranda · **Layar:** S-20, S-21, S-22

**Prompt:**
```
Lanjut Fase 4. Baca 03-ux-flows-and-screens.md S-20, S-21, S-22, Flow C, PRD F-08, dan 05-architecture-and-data.md §4.3. Buat rencana dulu.

Implementasikan tab Kebiasaan, form buat/edit (build & reduce, jadwal, biaya + dompet + kategori untuk reduce, batas mingguan), detail dengan HabitCalendar + streak + konsistensi 30 hari, dan HabitChip strip di Beranda. Check-in 1 tap (toggle) dengan undo snackbar dan haptic, long-press untuk stepper jumlah pada reduce. Transaksi dari kebiasaan berlabel "Dari kebiasaan" di list dan detail, dan menghapusnya membatalkan check-in terkait setelah konfirmasi.
Widget test: tap cepat 5x tetap konsisten, check-in reduce mengurangi saldo dan uncheck mengembalikan, hari longgar tampil di kalender.

DoD + screenshot. PR tanpa merge.
```

**Checklist fase (otomatis, §1):**
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

**Checklist fase (otomatis, §1):**
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
- Naikkan `version` di pubspec dari 1.0.0+1 ke 2.0.0+2. Build number harus lebih besar dari APK v1, yang selalu 1.0.0+1 (commit ca79cb0 sampai tag v1-legacy), supaya v2 bisa dipasang menimpa v1.

DoD + laporan audit sebelum/sesudah. PR tanpa merge.
```

### QA manual sebelum rilis
Hal yang hanya bisa dinilai manusia di HP sungguhan. Semua checklist fase lain sudah dijalankan otomatis (§1); fase berikutnya menambahkan itemnya di sini.
- [ ] Onboarding selesai ≤ 60 detik tanpa bingung (Fase 2, Flow A).
- [ ] Catat transaksi ≤ 5 detik dengan stopwatch, misalnya "kopi Rp 22.000" (Fase 3, Flow B).
- [ ] Rasa tampilan mode gelap di semua layar: kontras, tidak ada yang terlalu terang atau hilang.
- [ ] TalkBack langsung, minimal S-10, S-11, S-20 (03 §5): urutan fokus, label tombol ikon, nominal dibaca lengkap, "Saldo disembunyikan".
- [ ] App dimatikan di tengah proses (tepat setelah "Mulai" di onboarding, dan saat "Hapus semua data") di HP sungguhan → dibuka lagi tanpa data dobel atau Beranda kosong.
- [ ] Link "Kode sumber di GitHub" membuka halaman repo yang benar di browser HP sungguhan.
- [ ] Haptic terasa pas (keypad, check-in, hapus) di HP sungguhan, karena emulator tidak bergetar.

**Checklist kamu (uji pengguna kecil):**
- [ ] Minta 3–5 teman (persona target) mencoba tanpa penjelasan: onboarding, catat kopi, cari kebiasaan termahal. Catat di mana mereka ragu.
- [ ] Isi skor SUS (10 pertanyaan standar) dari mereka. Target ≥ 75.
- [ ] `version` di pubspec = 2.0.0+2 (build number > 1 milik APK v1). APK v2 terpasang menimpa APK v1 tanpa uninstall.

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
| 0 | Nilai pressed/tint tema gelap dihitung sendiri | Spesifikasi hanya memberi nilai terang | Disetujui, tercatat di 02 §11.1 (Fase 1) |
| 0 | Lisensi font OFL & Phosphor MIT ikut dibundel | Kewajiban lisensi | Selesai: didaftarkan ke `LicenseRegistry` di bootstrap (Fase 1) |
| 1 | schemaVersion 2: upgrade dari v1 = `createAll` + seed | Fase 0 terpasang dengan skema v1 kosong; tanpa ini perangkat dev crash "no such table". Instal baru tetap sama | Disetujui |
| 1 | Tanggal disimpan sebagai teks ISO-8601 UTC berpresisi milidetik (`build.yaml`, `toStoredUtc`) | Drift membandingkan tanggal sebagai teks; semua nilai harus berformat sama agar urutan dan filter bulan benar | Disetujui |
| 1 | Tanpa folder DAO; `HabitLedger` satu-satunya penulis `habit_logs` + transaksi check-in | Satu jalur untuk konsistensi log ↔ transaksi, dipakai HabitRepository dan TransactionRepository | Disetujui |
| 1 | Konsistensi 30 hari hanya untuk kebiasaan build | Untuk reduce, check-in berarti melakukan kebiasaan yang ingin dikurangi; ukurannya batas mingguan | Disetujui |
| 1 | Minggu berjalan dan minggu pembuatan tidak pernah dihitung gagal; minggu reduce baru dinilai setelah selesai | Sesuai prinsip "ramah saat gagal" (§4.3) | Disetujui |
| 1 | `formatRupiah` diberi parameter `localeCode`; tanda minus `−` (U+2212) | Mode compact berbeda antara id (rb/jt/M) dan en (K/M/B) | Disetujui |
| 1 | Toggle reduce: 0 → 1, ≥ 1 → 0; check-in tanggal lampau dicatat pukul 12.00 lokal | Flow C "tap lagi = batal"; jam 12 mencegah tanggal bergeser saat dikonversi ke UTC | Disetujui |
| 1 | Hapus transaksi dari kebiasaan menurunkan count log; `restore` menaikkannya kembali | Review PR #5: dulu log di-hapus saat count jadi 0 sehingga restore kehilangan check-in dan tautannya. Sekarang `habit_logs` punya `deletedAt` (skema v3), count 0 = soft delete, restore = log aktif lagi dengan count + 1 | Diperbaiki |
| 1 | Pencarian nama kategori default lewat `extraCategoryIds` dari UI | Nama terjemahan tidak disimpan di DB | Disetujui |
| 1 | Ganti jenis kebiasaan (build ↔ reduce) ditolak kalau sudah ada check-in; nama kategori kustom maks. 30 karakter | Menjaga riwayat dan transaksi; 05 §3 tidak menyebut batas nama kategori | Disetujui |
| 1 | Ikon & warna kategori default dipilih sendiri (mis. Makanan = forkKnife/coral) | S-42 hanya menyebut nama | Disetujui |
| 1 | Lint `recursive_getters` diabaikan per file tabel Drift | DSL CHECK Drift merujuk kolom di getter-nya sendiri; bukan rekursi runtime | Disetujui |
| 1 | schemaVersion 3: `addColumn` `habit_logs.deletedAt`; upgrade dari v1 tetap `createAll` (langsung skema terbaru). Snapshot skema di `drift_schemas/`, diuji dengan `SchemaVerifier` | Migrasi diuji terhadap skema v3 yang dibuat dari nol, termasuk index unik; siap dipakai migrasi fase berikutnya | Disetujui |
| 1 | Ganti jenis kebiasaan setelah check-in dibatalkan: log terhapusnya dibuang permanen | Transaksi reduce lama tidak boleh menaikkan count kebiasaan build saat di-restore; transaksinya kembali sebagai pengeluaran biasa | Disetujui |
| 1 | Jatah hari longgar dihitung dari hari longgar terakhir yang diberikan, termasuk dari streak sebelumnya; hanya periode yang sudah dinilai yang dihitung | Batas "1 per 7 periode terjadwal" berlaku sebagai jendela bergeser; hari tidak terjadwal, hari ini yang terbuka, dan minggu berjalan tidak menghabiskan jatah | Disetujui |
| 1 | Batas 10 check-in per hari hanya untuk input (stepper/setCount). Restore pengeluaran boleh membuat count > 10 agar count selalu sama dengan jumlah pengeluaran aktif. Stepper di Fase 4 menampilkan count sebenarnya dan menonaktifkan tombol + saat count ≥ 10. | Review Fase 1; dijaga test repository (restore saat count 10 → count 11, pengeluaran aktif 11, `setCount(11)` tetap ditolak) | Disetujui |
| 2 | Warna ikon preset dibuat per tema: gold, coral, green diganti di tema terang; teal, slate di tema gelap (tabel 02 §3.5). Key yang tersimpan tetap | Audit B: 5 preset di bawah 3:1 terhadap tint-nya (WCAG 1.4.11); dijaga `preset_colors_test.dart` | Disetujui |
| 2 | Token baru `dangerTint`, `dangerTintPressed`, `onDangerTint` untuk `DestructiveButton` (02 §11.1) | Teks `danger` di atas tint-nya sendiri hanya 4,33–4,46, di bawah 4,5 | Disetujui |
| 2 | Editor dompet dan kategori tampil layar penuh di root navigator (tanpa bottom nav); tombol Simpan di akhir body | Form layar penuh seperti S-21; di `bottomNavigationBar` tombol tertutup keyboard | Disetujui |
| 2 | Hapus dompet/kategori kosong memakai snackbar undo 4 detik, bukan dialog; undo memasukkan kembali baris yang sama (`undoDelete`) | Pola global 03 §4: dialog hanya untuk yang tidak bisa dibatalkan | Disetujui |
| 2 | Draft onboarding disimpan di preferensi (JSON) per perubahan; dompet dan kebiasaan dibuat sekaligus di akhir dalam satu `db.transaction` | Lanjut dari langkah terakhir tanpa data setengah jadi di DB | Disetujui |
| 2 | Template: 4 Bangun + 4 Kurangi; Kurangi memakai kategori default (Makanan & minuman, Transportasi, Belanja), tanpa `weeklyLimit`; ikon & warna dipilih sendiri; nama disimpan dalam bahasa saat onboarding | S-01 hanya menyebut nama dan biaya | Disetujui |
| 2 | Hapus semua data: sheet 2 langkah (bukan dialog), kata `HAPUS`/`DELETE` dicocokkan tanpa peduli huruf besar-kecil; ikut mereset bahasa, tema, dan nama lalu kembali ke onboarding | Hasilnya sama dengan instal baru | Disetujui |
| 2 | Bahasa di Pengaturan dua opsi "Indonesia / English"; default awal tetap mengikuti perangkat sampai dipilih | S-43; label pendek supaya tidak terpotong di ukuran teks 1,3 | Disetujui |
| 2 | Satu set baris Tentang (versi, pembuat, kode sumber, lisensi) dipakai di layar Tentang (dari S-40) dan grup Tentang di S-43 | S-40 dan S-43 sama-sama menyebut isi Tentang | Diubah (review PR #6): Tentang hanya di S-40 |
| 2 | Toggle "Sembunyikan saldo saat membuka app" sudah disimpan, efeknya baru terlihat di `BalanceHeader` Fase 3 | S-43 masuk Fase 2, Beranda Fase 3 | Disetujui |
| 2 | Dependensi baru `package_info_plus` (versi app) dan `url_launcher` (+ query `https` di AndroidManifest) | Versi dan link repo di Tentang | Disetujui |
| 2 | Label `SegmentedToggle` boleh dua baris | Di ukuran teks 1,3 "Ikuti sistem" terpotong | Disetujui |
| 2 | Widget test yang memompa seluruh app memakai `testApp` (melepas app agar timer Drift selesai) dan membaca DB dengan query biasa, bukan `watch().first` | Timer stream Drift tidak berjalan di waktu palsu test | Disetujui |
| 2 | Status onboarding bersumber dari database: saat bootstrap (splash masih ditahan) `onboardingDone` = ada minimal satu dompet (aktif/arsip); draft yang tersisa dihapus; tanpa dompet padahal preferensi "selesai" = hapus semua data yang terputus, jadi preferensi dibersihkan. Nama disimpan sebelum transaksi DB. Preferensi tetap cache untuk redirect router | App yang mati di antara tulis DB dan tulis preferensi tidak boleh membuat dompet/kebiasaan dobel atau masuk Beranda tanpa dompet | Disetujui (review PR #6) |
| 2 | Konfirmasi "Buang perubahan?" (Buang / Lanjut edit) untuk sheet dan layar editor dengan input belum disimpan: `UnsavedChangesGuard` + `confirmDiscardChanges` di `lib/core/design`, dipakai editor dompet/kategori dan nanti S-11 dan S-21. Simpan/arsip/hapus keluar tanpa konfirmasi. Sheet ber-input memakai `showAppSheet(enableDrag: false)` | Tarik-tutup sheet di Flutter 3.47 memanggil `Navigator.pop` langsung dan melewati `PopScope` | Disetujui (review PR #6) |
| 3 | Saldo tersembunyi = state sesi (`BalanceHidden`, dibaca sekali dari pengaturan saat app dibuka). Ikon mata tidak mengubah pengaturan; mengubah toggle di S-43 berlaku mulai app dibuka berikutnya. Total & saldo per dompet di S-41 ikut; nominal transaksi dan pill ringkasan bulan tidak disembunyikan | Permintaan Fase 3 (A); ringkasan bulan adalah jumlah transaksi yang tetap terlihat di list | Disetujui |
| 3 | Pill ringkasan Beranda memakai nominal penuh (`Masuk Rp 3.500.000`), bukan `Rp 3,5 jt` seperti sketsa/mockup; pill membungkus ke baris berikut bila perlu. Ditambah pill ketiga "Selisih" | 02 §9 membatasi singkatan untuk grafik; PRD US-03.1 meminta total masuk, keluar, dan selisih | Diubah (review PR #7): kartu 3 kolom `PeriodSummaryCard` di S-10 dan S-13, pemilih bulan = chip di header kartu |
| 3 | Beranda: baris tanggal ("Jumat, 25 September") di atas sapaan seperti mockup; avatar membuka tab Profil; tanpa nama sapaan menjadi "Selamat pagi" saja | Mockup S-10; permintaan Fase 3 (C) | Disetujui |
| 3 | S-11: default dimuat sebelum sheet terbuka dengan query biasa (`recentCategoryIds`, `lastUsedWalletId`, `listActive`). Transaksi pertama tanpa kategori terpilih; chip = 6 kategori terakhir dipakai, ditambah urutan tampilan bila kurang; kategori dari "Semua ›" mengambil chip pertama | Kategori terakhir hanya ada kalau pernah dipakai; menebak kategori bisa salah catat | Disetujui |
| 3 | S-11: sheet tanpa handle dengan header judul + X (`SheetHeader`); picker opsi/tanggal tetap bisa ditarik. Gagal simpan tampil sebagai teks error di atas tombol Simpan | Permintaan Fase 3 (B); snackbar akan tertutup sheet | Disetujui |
| 3 | S-11 edit transaksi dari kebiasaan: tipe dan tanggal terkunci, catatan boleh diubah | Tipe dan tanggal terikat ke log check-in hari itu (03 S-11 diperbarui) | Disetujui |
| 3 | S-11 tanggal: kalender dalam sheet sampai hari ini (tanpa tanggal masa depan), jam dipertahankan; tidak ada pemilih jam | 03 S-11 hanya menyebut tanggal | Disetujui |
| 3 | "Urungkan" setelah simpan: transaksi baru di-soft-delete (terhapus permanen setelah 30 hari), hasil edit dikembalikan ke nilai sebelumnya | Satu jalur undo yang sama dengan hapus | Disetujui |
| 3 | S-12 label "Dari kebiasaan: Kopi" belum bisa di-tap; tautan ke S-22 dipasang di Fase 4 saat layarnya ada | Tanpa tombol yang tidak berfungsi | Disetujui |
| 3 | S-13 di rute `/transactions` dalam cabang Beranda (bottom nav tetap tampil), query `month`, `category`, `wallet`. Infinite scroll per bulan mulai dari bulan terpilih; ringkasan = bulan terpilih dengan filter aktif; filter kategori/dompet ikut menampilkan yang diarsipkan | Transaksi lama bisa memakai kategori/dompet arsip | Diubah (review PR #7): bulan = filter tegas + tombol "Lihat <bulan sebelumnya>"; pencarian meliputi semua bulan, dimuat per 50 |
| 3 | Filter kategori S-13 memuat kedua jenis; nama yang dipakai keduanya diberi jenisnya: "Lainnya (Pengeluaran)" / "Lainnya (Pemasukan)" | Ditemukan saat QA screenshot: dua "Lainnya" tidak bisa dibedakan | Disetujui |
| 3 | Haptic: `selectionClick` di chip, keypad, segmented; `mediumImpact` saat hapus transaksi; tidak ada haptic saat simpan | 02 §8 | Disetujui |
| 3 | Jam layar lewat `clockProvider` (bisa diganti di test); repository tetap memakai `Clock` sendiri | Sapaan dan label "Hari ini" harus deterministik di test | Disetujui |
| 3 | Satu sumber "sekarang/hari ini" (`nowProvider`): diperbarui saat app kembali ke depan (`AppLifecycleListener`) dan lewat `Timer` ke batas berikutnya (tengah malam lokal, juga jam sapaan 04/10/15/18). Dipakai sapaan, label Hari ini/Kemarin, bulan default Beranda & S-13 (selama belum dipilih manual), dan tanggal default S-11 (S-11 membaca jam segar lewat `refresh()`) | App yang terbuka melewati tengah malam atau lama di latar belakang tidak boleh menampilkan "Hari ini" untuk kemarin (review PR #7) | Disetujui (review PR #7) |
| 3 | Kartu ringkasan S-13 dihitung di database (`watchTotals(filter)`) supaya pencarian lintas bulan yang dimuat bertahap tetap menjumlah semua hasil | Ringkasan tidak boleh bergantung pada halaman yang sudah dimuat | Perlu review |
| 3 | Nominal di `TransactionTile` maks. setengah lebar layar dan mengecil (`FittedBox`); mode catatan S-11 menampilkan nominal kecil di bawah judul sheet dan menyembunyikan tipe + nominal besar | Ditemukan saat test 360 dp/1,3: nominal sangat besar membuat baris overflow; review PR #7 poin 4 | Perlu review |

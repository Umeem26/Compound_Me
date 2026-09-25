# CompoundMe v2.0 — Product Requirements Document (PRD)

| | |
|---|---|
| Pemilik produk | Hisyam Khaeru Umam (Umem) |
| Status | Draft 1 — siap dieksekusi bertahap |
| Tanggal | 25 September 2026 |
| Versi app target | 2.0.0 (rebuild total dari fondasi v1) |
| Dokumen terkait | `02-design-system.md`, `03-ux-flows-and-screens.md`, `04-brand-assets.md`, `05-architecture-and-data.md`, `06-execution-plan.md` |

> Cara membaca: setiap fitur punya ID (`F-xx`) dan setiap user story punya kriteria penerimaan (acceptance criteria/AC). ID ini dipakai di rencana eksekusi dan di commit message supaya jejaknya bisa ditelusuri.

---

## 1. Ringkasan

CompoundMe adalah aplikasi pencatat keuangan dan kebiasaan yang **menghubungkan kebiasaan kecil sehari-hari dengan dampaknya ke uang**. Kopi Rp 25.000 sehari terasa kecil, tapi setahun jadi Rp 9,1 juta. Olahraga 3x seminggu terasa berat, tapi setelah beberapa minggu jadi otomatis. CompoundMe membuat efek "menggulung" (compounding) dari kebiasaan terlihat nyata, lalu membantu pengguna mengarahkannya.

v1 membuktikan ide intinya menarik (habit berbiaya otomatis tercatat sebagai pengeluaran), tapi eksekusinya belum layak pakai. Hasil uji manual 25 Sept 2026:

- Icon dan logo terpotong (foreground adaptive icon tanpa safe zone), dan ada dua splash screen berturut-turut (splash native, lalu splash Flutter dengan icon Material bawaan).
- Tata letak berantakan, ukuran komponen dan teks tidak konsisten dan terlalu besar.
- UX membingungkan untuk pengguna baru: tidak ada onboarding, tidak ada tombol tambah transaksi, istilah tidak jelas.
- Kesan "AI slop": emoji di teks, gradasi di mana-mana, notifikasi dummy, klaim fitur yang belum ada.

**Keputusan:** v2.0 adalah rebuild menyeluruh, dari icon sampai end-to-end flow. Palet warna teal + emas dipertahankan (sudah disukai) tapi dipakai tanpa gradasi. Kode v1 boleh dibuang. Yang dipertahankan hanya ide, nama, dan pelajaran teknis (lihat `05-architecture-and-data.md`).

## 2. Masalah

1. **Pengeluaran kecil yang berulang tidak terasa.** Orang mencatat pengeluaran besar, tapi bocornya justru di pengeluaran kecil yang sering (kopi, jajan, ongkir, ojol). Tanpa angka yang terkumpul, tidak ada dorongan untuk berubah.
2. **Aplikasi keuangan dan aplikasi kebiasaan terpisah.** Pengguna harus mencatat dua kali, dan hubungan "kebiasaan → uang" tidak pernah terlihat.
3. **Mencatat terasa merepotkan.** Kalau input transaksi lebih dari beberapa detik, pengguna berhenti mencatat dalam hitungan minggu.
4. **Aplikasi habit menghukum saat gagal.** Streak yang langsung reset ke 0 karena satu hari bolong bikin orang menyerah (lihat §9).

Konteks pasar (fakta): menurut Survei Nasional Literasi dan Inklusi Keuangan (SNLIK) 2025 dari OJK dan BPS, indeks literasi keuangan nasional 66,46% sementara inklusi 80,51% (metode keberlanjutan). Artinya akses ke produk keuangan sudah jauh lebih luas daripada pemahaman cara mengelolanya. Untuk usia 18–25, literasinya 73,22% dan inklusinya 89,96%.

## 3. Visi & positioning

**Visi:** "Kebiasaan kecil, dampak besar." / *"Small habits, compounding results."*

**Positioning (opini produk, bukan fakta pasar):** e-wallet (GoPay, DANA) unggul di transaksi, dan habit tracker (Streaks, Habitify) unggul di kebiasaan. CompoundMe tidak bersaing di keduanya. Ia mengisi celah di tengah: **alat refleksi pribadi** yang memperlihatkan harga sebenarnya dari rutinitas, dengan input secepat e-wallet dan rasa tenang seperti app iOS yang rapi.

**Prinsip produk:**
1. **Cepat dulu, lengkap kemudian.** Tambah transaksi ≤ 5 detik, check-in habit 1 tap.
2. **Tunjukkan, jangan menggurui.** Angka dan proyeksi jujur, tanpa ceramah atau emoji.
3. **Ramah saat gagal.** Satu hari bolong itu wajar, pola bolong itu yang perlu diperhatikan.
4. **Privat secara default.** Data tersimpan di perangkat. Tidak ada akun wajib di v2.0.
5. **Jujur.** Tidak ada data dummy, tidak ada tombol mati, tidak ada klaim fitur yang belum ada.

## 4. Target pengguna

**Utama:** mahasiswa dan first-jobber usia 18–27 di Indonesia. Memegang uang saku atau gaji pertama, pengeluaran kecil tapi sering, memakai e-wallet sehari-hari, akrab dengan UI GoPay/DANA/Instagram.

### Persona 1 — Raka, mahasiswa semester 5 (20 th)
- Uang saku Rp 2,5 juta/bulan dari orang tua, plus freelance desain kecil-kecilan.
- Beli kopi susu 4–5x seminggu, sering GoFood tengah malam.
- Selalu "kok tiba-tiba habis" di minggu ke-3.
- **Kebutuhan:** tahu ke mana uangnya pergi tanpa ribet, dan punya alasan konkret untuk mengurangi jajan.

### Persona 2 — Nadia, first-jobber (24 th)
- Gaji Rp 6 juta, kos, mulai ingin menabung dana darurat.
- Punya target kebiasaan: olahraga 3x seminggu, bawa bekal.
- Pernah pakai 2 app habit, berhenti karena streak putus.
- **Kebutuhan:** melihat bahwa kebiasaan baiknya berdampak ke tabungan, dan app yang tidak bikin merasa bersalah.

### Jobs-to-be-done
- *Saat* saya baru bayar sesuatu, *saya ingin* mencatatnya dalam hitungan detik, *supaya* catatan saya tetap lengkap tanpa jadi beban.
- *Saat* saya merasa boros, *saya ingin* melihat kebiasaan mana yang paling mahal, *supaya* tahu harus mulai dari mana.
- *Saat* saya mau mengurangi kebiasaan, *saya ingin* melihat berapa yang bisa saya hemat dalam setahun, *supaya* punya motivasi nyata.
- *Saat* saya bolong sehari, *saya ingin* app tetap menghargai progres saya, *supaya* saya tidak menyerah.

## 5. Konsep inti: dua jenis kebiasaan

| Jenis | Label ID / EN | Contoh | Perilaku |
|---|---|---|---|
| **Bangun** | Bangun / *Build* | Olahraga, baca 10 halaman, bawa bekal, nabung harian | Target frekuensi (harian / hari tertentu / X kali per minggu). Sukses = check-in. Opsional: nilai tabungan per check-in (P1, dengan Goals). |
| **Kurangi** | Kurangi / *Reduce* | Kopi kekinian, jajan malam, rokok, ojol jarak dekat | Punya biaya per kejadian. Setiap check-in otomatis tercatat sebagai pengeluaran (dompet dan kategori dipilih pengguna, bukan hardcode). Sukses = di bawah batas mingguan. |

"Compound Insights" menghubungkan keduanya: berapa porsi pengeluaran dari kebiasaan *Kurangi*, proyeksi tahunannya, simulasi "kalau dikurangi X%", dan konsistensi kebiasaan *Bangun*.

## 6. Ruang lingkup v2.0

Prioritas: **P0** = wajib ada di rilis 2.0. **P1** = target 2.1. **P2** = backlog.

### P0 — Rilis 2.0

| ID | Fitur | Ringkasan |
|---|---|---|
| F-01 | Identitas visual baru | Icon app baru (adaptive + monochrome), satu splash native, design system baru. Lihat `04-brand-assets.md`. |
| F-02 | Onboarding | Pilih bahasa → 3 layar nilai produk (bisa di-skip) → nama panggilan → dompet pertama → pilih 1–3 kebiasaan dari template. Maksimal ±60 detik. |
| F-03 | Beranda (Home) | Sapaan dengan nama pengguna, total saldo (bisa disembunyikan), ringkasan bulan ini (masuk/keluar), strip check-in kebiasaan hari ini, 1 kartu insight, transaksi terbaru. |
| F-04 | Tambah transaksi cepat | Tombol tambah di tengah navigasi. Keypad angka khusus, kategori terakhir dipakai muncul duluan, dompet default = terakhir dipakai, tanggal default = hari ini. Pengeluaran / pemasukan. |
| F-05 | Riwayat transaksi | Dikelompokkan per hari, filter bulan/kategori/dompet, pencarian catatan, edit, hapus dengan **undo**. |
| F-06 | Dompet | Tambah/edit/arsipkan dompet (tunai, bank, e-wallet), saldo awal, urutan. Saldo = saldo awal + transaksi (dihitung, bukan disimpan). |
| F-07 | Kategori | Set default dwibahasa + kategori kustom (ikon & warna dari set terbatas). Arsipkan, bukan hapus, kalau sudah dipakai. |
| F-08 | Kebiasaan | Buat/edit/arsipkan kebiasaan *Bangun* dan *Kurangi*. Jadwal, biaya + dompet + kategori (khusus *Kurangi*), check-in 1 tap dengan undo, riwayat kalender, streak dengan aturan "jangan bolong dua kali". |
| F-09 | Compound Insights | Tab Wawasan: porsi biaya kebiasaan dari total pengeluaran, rincian per kebiasaan, proyeksi tahunan, simulasi pengurangan, proyeksi compounding (opsional bunga), konsistensi kebiasaan *Bangun*, breakdown kategori. |
| F-10 | Pengaturan | Bahasa (ID/EN), tema (sistem/terang/gelap, tersimpan), nama, sembunyikan saldo default, tentang app, reset data (dengan konfirmasi berlapis). |
| F-11 | Dwibahasa | Semua teks UI lewat `gen-l10n` (ARB `id` dan `en`). Tidak ada string hardcoded di widget. Default mengikuti bahasa perangkat, bisa diganti di onboarding dan Pengaturan. |
| F-12 | State lengkap | Setiap layar punya empty, loading, dan error state yang dirancang, bukan layar kosong atau teks "Error". |

### P1 — Rilis 2.1

| ID | Fitur | Ringkasan |
|---|---|---|
| F-20 | Pengingat | Notifikasi lokal per kebiasaan (jam pilihan) dan pengingat harian "sudah catat hari ini?" (opsional). |
| F-21 | Anggaran | Batas bulanan per kategori, progress bar, peringatan lembut di 80% dan 100%. |
| F-22 | Goals / kantong tabungan | Target tabungan. Kebiasaan *Bangun* "nabung harian" bisa otomatis menambah progres goal. |
| F-23 | Transfer antar dompet | Pindah saldo tanpa tercatat sebagai pengeluaran/pemasukan. |
| F-24 | Ekspor & backup | Ekspor CSV transaksi, backup/restore file JSON lokal. |
| F-25 | Transaksi berulang | Kos, langganan, dll. |

### P2 — Backlog

Cloud sync + akun (Supabase, arsitektur sudah disiapkan di v2.0), widget layar utama, kunci biometrik, foto struk, rekap mingguan, berbagi kartu insight.

### Bukan tujuan (non-goals)

- Integrasi rekening bank atau e-wallet (butuh izin regulasi, di luar kapasitas proyek).
- Rekomendasi investasi. Proyeksi compounding hanyalah simulasi matematis dengan disclaimer, **bukan saran keuangan**.
- Multi-mata uang. v2.0 hanya IDR.
- Versi web. Klaim "Web" di README v1 dihapus.

## 7. User stories & acceptance criteria (P0)

### F-02 Onboarding
- **US-02.1** Sebagai pengguna baru, saya bisa mulai memakai app dalam kurang dari satu menit.
  - AC: Alur = Bahasa → Nilai produk (3 halaman, tombol "Lewati") → Nama → Dompet pertama (nama + saldo awal, boleh 0) → Pilih 0–3 template kebiasaan → Beranda.
  - AC: Setiap langkah bisa kembali tanpa kehilangan input.
  - AC: Onboarding hanya muncul sekali. Status disimpan, dan app yang ditutup di tengah onboarding melanjutkan dari langkah terakhir.
- **US-02.2** Template kebiasaan sudah terisi masuk akal.
  - AC: Minimal 8 template (4 Bangun, 4 Kurangi). Template Kurangi punya biaya contoh yang bisa diedit sebelum disimpan.

### F-03 Beranda
- **US-03.1** Saya langsung melihat kondisi keuangan saya.
  - AC: Total saldo semua dompet aktif tampil dengan format `Rp 1.250.000`. Ikon mata menyembunyikan angka menjadi `Rp ••••••`, dan pilihan ini tersimpan.
  - AC: Ringkasan bulan berjalan: total masuk, total keluar, selisih.
- **US-03.2** Saya bisa check-in kebiasaan hari ini dari Beranda.
  - AC: Strip horizontal berisi kebiasaan yang terjadwal hari ini. Tap = check-in, haptic ringan, dan snackbar "Dicatat · Urungkan" selama 4 detik.
  - AC: Check-in kebiasaan *Kurangi* langsung menambah transaksi dan memperbarui saldo di layar yang sama tanpa refresh manual.
- **US-03.3** Beranda tidak pernah kosong tanpa arah.
  - AC: Tanpa transaksi → empty state dengan satu CTA "Catat transaksi pertama".

### F-04 Tambah transaksi cepat
- **US-04.1** Saya bisa mencatat pengeluaran dalam ≤ 5 detik.
  - AC: Dari tombol tambah → sheet muncul dengan fokus di nominal (keypad khusus, bukan keyboard sistem) → pilih kategori (6 kategori terakhir dipakai tampil sebagai chip) → Simpan. Minimal 3 tap setelah angka diketik.
  - AC: Default: tipe Pengeluaran, dompet terakhir dipakai, tanggal hari ini.
  - AC: Nominal 0 atau kosong tidak bisa disimpan (tombol nonaktif, tanpa dialog error).
  - AC: Keypad punya tombol `000` dan hapus. Nominal diformat ribuan secara live.
- **US-04.2** Saya bisa mencatat pemasukan.
  - AC: Toggle segmented Pengeluaran | Pemasukan di atas nominal. Kategori menyesuaikan tipe.
- **US-04.3** Saya bisa menambahkan detail kalau mau.
  - AC: Baris opsional: Dompet, Tanggal, Catatan. Semuanya punya nilai default dan tidak wajib.

### F-05 Riwayat transaksi
- **US-05.1** Saya bisa menemukan transaksi lama.
  - AC: List dikelompokkan per hari dengan header tanggal ("Hari ini", "Kemarin", "Senin, 21 Sep") dan subtotal hari itu.
  - AC: Filter: bulan (pemilih bulan), kategori, dompet. Pencarian teks di catatan dan nama kategori.
- **US-05.2** Saya bisa memperbaiki kesalahan tanpa takut.
  - AC: Tap transaksi → sheet detail → Edit / Hapus. Hapus menampilkan snackbar "Transaksi dihapus · Urungkan" (soft delete, dibersihkan permanen setelah 30 hari atau saat app dibuka ulang).
  - AC: Transaksi hasil check-in kebiasaan diberi label "Dari kebiasaan: Kopi". Menghapusnya juga membatalkan check-in terkait (dengan konfirmasi).

### F-06 Dompet
- **US-06.1** Saya bisa mengelola dompet.
  - AC: Tipe: Tunai, Bank, E-wallet, Lainnya. Nama, ikon, warna dari set terbatas, saldo awal.
  - AC: Dompet yang sudah punya transaksi tidak bisa dihapus, hanya diarsipkan (disembunyikan dari pilihan, tetap ada di riwayat). Dompet kosong boleh dihapus.
  - AC: Minimal 1 dompet aktif harus selalu ada.

### F-08 Kebiasaan
- **US-08.1** Saya bisa membuat kebiasaan *Bangun* atau *Kurangi*.
  - AC: Form: jenis, nama (1–40 karakter), ikon, warna, jadwal (setiap hari / hari tertentu / N kali per minggu).
  - AC: Khusus *Kurangi*: biaya per kejadian (wajib > 0), dompet sumber, kategori pengeluaran, batas maksimal per minggu (opsional, untuk menilai "berhasil").
- **US-08.2** Check-in bersifat toggle dan aman.
  - AC: Satu tap = check-in untuk hari ini, tap lagi = batal. Operasi atomik (log + transaksi + saldo), aman dari tap ganda.
  - AC: *Kurangi* boleh lebih dari 1 kejadian per hari (mis. 2 kopi): long-press → stepper jumlah. Setiap kejadian = 1 transaksi.
- **US-08.3** Streak tidak menghukum.
  - AC: Aturan "jangan bolong dua kali": satu hari terjadwal yang terlewat tidak memutus streak (ditandai sebagai *hari longgar*). Dua hari terjadwal berturut-turut terlewat baru mereset streak.
  - AC: Tampilkan juga "konsistensi 30 hari" (%) yang tidak pernah reset, sebagai metrik utama selain streak.
- **US-08.4** Saya bisa melihat riwayat kebiasaan.
  - AC: Detail kebiasaan menampilkan kalender bulan (hari check-in, hari longgar, hari terlewat), streak saat ini, streak terbaik, konsistensi 30 hari, dan total biaya (untuk *Kurangi*).

### F-09 Compound Insights
- **US-09.1** Saya tahu seberapa besar kebiasaan menggerogoti uang saya.
  - AC: Kartu utama: "Kebiasaan *Kurangi* = X% dari pengeluaranmu bulan ini (Rp Y)". Periode mengikuti pemilih bulan.
- **US-09.2** Saya bisa melihat dampak setahun dan mensimulasikan perubahan.
  - AC: Per kebiasaan *Kurangi*: frekuensi rata-rata/minggu (dari 4 minggu terakhir), biaya bulan ini, proyeksi 12 bulan dengan laju saat ini.
  - AC: Simulator: slider pengurangan 0–100% (langkah 10%) → hemat per tahun. Toggle "tabung & kembangkan" menampilkan proyeksi 1/3/5 tahun dengan bunga majemuk bulanan pada suku bunga yang bisa diatur (default 0%, contoh 5%/th), disertai disclaimer "Simulasi, bukan saran keuangan".
- **US-09.3** Saya melihat progres kebiasaan baik.
  - AC: Per kebiasaan *Bangun*: konsistensi bulan ini, streak, dan tren vs bulan lalu (naik/turun, dalam poin persen).
- **US-09.4** Saya melihat pengeluaran per kategori.
  - AC: Donut chart per kategori + list dengan nominal dan persentase. Tap segmen/list → filter riwayat transaksi.
- AC umum: data < 7 hari → tampilkan empty state edukatif ("Insight muncul setelah seminggu mencatat"), bukan grafik kosong.

### F-10 & F-11 Pengaturan dan dwibahasa
- AC: Mengganti bahasa langsung mengubah seluruh UI tanpa restart. Format tanggal mengikuti bahasa (`Jumat, 25 September` / `Friday, 25 September`). Format uang selalu `Rp 25.000` (IDR).
- AC: Tema tersimpan dan diterapkan sebelum frame pertama (tidak ada kedipan tema).
- AC: "Hapus semua data" butuh dua langkah konfirmasi dan mengetik kata `HAPUS` / `DELETE`.

## 8. Kebutuhan non-fungsional

| Area | Target |
|---|---|
| Performa | Cold start ke Beranda ≤ 2 detik di emulator Pixel 9 (debug profile diukur di mode profile/release). Scroll 60 fps pada 1.000 transaksi. |
| Offline | 100% fitur P0 berjalan tanpa internet. |
| Integritas data | Uang disimpan sebagai integer Rupiah. Saldo dihitung dari transaksi. Semua operasi multi-tabel di dalam transaksi database. Foreign key aktif. |
| Aksesibilitas | Kontras teks minimal 4,5:1 (WCAG 2.2 AA), target sentuh ≥ 48×48 dp, mendukung text scaling sampai 130% tanpa layout rusak, semua ikon aksi punya label semantik. |
| Privasi | Tidak ada analytics pihak ketiga di v2.0. Data tidak keluar dari perangkat. |
| Kualitas kode | `flutter analyze` 0 warning (bukan cuma 0 error), coverage unit test untuk logika domain ≥ 80%, CI GitHub Actions menjalankan analyze + test. |
| Platform | Android 8.0+ (minSdk 26) utama, iOS berjalan (belum dipublikasikan). Mendukung page size 16 KB Android. |

## 9. Dasar riset untuk keputusan desain

- **Streak ramah:** studi Lally dkk. (2010, *European Journal of Social Psychology*) menemukan median 66 hari (rentang 18–254) untuk kebiasaan menjadi otomatis, dan satu kesempatan yang terlewat tidak berdampak berarti pada pembentukan kebiasaan. Ini dasar aturan "jangan bolong dua kali" dan metrik konsistensi yang tidak reset.
- **Batasi pilihan di awal:** Streaks (pemenang Apple Design Award) awalnya membatasi hanya 6 kebiasaan agar tetap fokus. Onboarding CompoundMe membatasi 1–3 kebiasaan awal.
- **Input cepat:** praktik umum app pencatat pengeluaran: tombol tambah dalam jangkauan jempol, default pintar (dompet terakhir, hari ini, kategori terbaru), dan undo alih-alih dialog konfirmasi.
- **Pola e-wallet lokal:** redesign DANA v2.0 berfokus mengurangi kepadatan beranda dan memperjelas ikon lewat uji pengguna. Studi kasus GoPay menyoroti font tidak konsisten, penempatan tombol, dan kebutuhan ringkasan transaksi bulanan di beranda. Detail di `02-design-system.md §2`.

## 10. Metrik keberhasilan

Karena tidak ada analytics, metrik diukur lewat uji pengguna kecil (5 orang dari persona target) dan instrumentasi lokal opsional di mode debug.

| Metrik | Target |
|---|---|
| Waktu onboarding sampai Beranda | ≤ 60 detik (median) |
| Waktu catat pengeluaran | ≤ 5 detik (median, dari tap tombol tambah) |
| Tugas "catat kopi Rp 22.000 pakai GoPay" tanpa bantuan | 5/5 berhasil |
| Tugas "cari kebiasaan termahal bulan ini" tanpa bantuan | ≥ 4/5 berhasil |
| Skor SUS (System Usability Scale) | ≥ 75 |
| Retensi pribadi (Umem sebagai pengguna harian) | Mencatat ≥ 25 dari 30 hari |

## 11. Risiko & mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Scope terlalu besar untuk dikerjakan sendiri | Tinggi | Eksekusi per fase (lihat `06-execution-plan.md`). Setiap fase bisa dirilis dan diuji sendiri. |
| Proyeksi compounding disalahartikan sebagai saran investasi | Sedang | Default bunga 0%, label "Simulasi", disclaimer tetap terlihat, tanpa nama produk investasi. |
| Rebuild data merusak data lama | Rendah (belum ada pengguna publik) | v2.0 memakai skema baru dan memulai database bersih. Diputuskan sadar karena app belum dirilis. |
| Terjemahan EN terasa kaku | Rendah | Kedua bahasa ditulis dengan panduan suara yang sama (`02-design-system.md §9`) dan direview manual. |

## 12. Pertanyaan terbuka

1. Apakah kebiasaan *Bangun* "nabung harian" langsung terhubung ke Goals (P1), atau cukup sebagai check-in biasa di 2.0? *(Usulan: check-in biasa dulu.)*
2. Batas jumlah kebiasaan aktif: tanpa batas, atau batas lunak 10 dengan saran fokus? *(Usulan: batas lunak.)*
3. Nama tab "Wawasan" vs "Insight" untuk versi Indonesia. *(Usulan: "Wawasan", lebih natural.)*

## 13. Glosarium

- **Kebiasaan Bangun (Build):** kebiasaan yang ingin diperbanyak.
- **Kebiasaan Kurangi (Reduce):** kebiasaan yang ingin dikurangi dan punya biaya.
- **Check-in:** menandai kebiasaan dilakukan pada suatu hari.
- **Hari longgar:** satu hari terjadwal yang terlewat tapi tidak memutus streak.
- **Konsistensi 30 hari:** persentase hari terjadwal yang di-check-in dalam 30 hari terakhir.

## Sumber

- OJK & BPS, Siaran Pers SNLIK 2025: https://ojk.go.id/id/berita-dan-kegiatan/siaran-pers/Pages/OJK-dan-BPS-Umumkan-Hasil-Survei-Nasional-Literasi-Dan-Inklusi-Keuangan-SNLIK-Tahun-2025.aspx
- Lally dkk. (2010), *How are habits formed*: https://onlinelibrary.wiley.com/doi/abs/10.1002/ejsp.674 dan ringkasan: https://www.thebehavioralscientist.com/articles/how-long-to-form-a-habit
- Tentang reset streak dan aturan dua hari: https://tracebyme.com/blog/habit-tracker-streak-anxiety-two-day-rule/
- Streaks 3 review (MacStories): https://www.macstories.net/reviews/streaks-3-review/
- Praktik input cepat expense tracker: https://koder.ai/blog/build-mobile-app-personal-finance-expense-tracking
- DANA v2.0 (DANA Product & Tech): https://medium.com/dana-engineering/small-steps-big-impact-journey-to-dana-v2-0-e2ec0a63838f
- Studi kasus GoPay: https://medium.com/@katherinenatalia2/ui-ux-case-study-gopay-app-5cb7c1c001f8

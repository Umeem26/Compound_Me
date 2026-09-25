# CompoundMe v2.0 — UX Flows & Spesifikasi Layar

| | |
|---|---|
| Status | Draft 1 |
| Dokumen terkait | `01-PRD.md` (fitur & AC), `02-design-system.md` (token & komponen) |

> Wireframe di bawah adalah **struktur**, bukan tampilan akhir. Ukuran, warna, dan tipografi mengikuti `02-design-system.md`. Setiap layar punya ID (`S-xx`) yang dipakai di rencana eksekusi.

---

## 1. Arsitektur informasi

```
App
├── Onboarding (sekali)                         S-01
└── Shell dengan bottom nav
    ├── Beranda                                  S-10
    │   ├── Riwayat transaksi                    S-13
    │   └── Detail transaksi (sheet)             S-12
    ├── Kebiasaan                                S-20
    │   ├── Detail kebiasaan                     S-22
    │   └── Buat / edit kebiasaan                S-21
    ├── [ + ] Tambah transaksi (sheet)           S-11
    ├── Wawasan                                  S-30
    │   └── Simulator kebiasaan (sheet)          S-31
    └── Profil                                   S-40
        ├── Dompet  → Edit dompet                S-41
        ├── Kategori → Edit kategori             S-42
        └── Pengaturan                           S-43
```

### Rute (go_router)

| Rute | Layar | Catatan |
|---|---|---|
| `/onboarding` | S-01 | Redirect otomatis kalau onboarding belum selesai |
| `/home` | S-10 | Tab 1 (StatefulShellRoute, state tiap tab dipertahankan) |
| `/habits` | S-20 | Tab 2 |
| `/insights` | S-30 | Tab 4 |
| `/me` | S-40 | Tab 5 |
| `/transactions` | S-13 | Query: `?month=2026-09&category=..&wallet=..` |
| `/habits/new`, `/habits/:id`, `/habits/:id/edit` | S-21, S-22 | |
| `/me/wallets`, `/me/wallets/new`, `/me/wallets/:id` | S-41 | |
| `/me/categories`, `/me/categories/:id` | S-42 | |
| `/me/settings` | S-43 | |

Sheet (S-11, S-12, S-31) dibuka dengan `showModalBottomSheet` dari mana pun, bukan rute penuh.

## 2. Flow utama

### Flow A — Pengguna baru (target ≤ 60 detik)
```
Splash native (logo, tanpa animasi)
  → Pilih bahasa (ID / EN)
  → Nilai produk 1/3 → 2/3 → 3/3   [Lewati] tersedia di semua halaman
  → "Panggil kamu siapa?" (nama, wajib, 1–24 karakter)
  → Dompet pertama (nama default "Tunai", saldo awal boleh 0)
  → Pilih kebiasaan (0–3 dari template, bisa ubah biaya)
  → Beranda, dengan coach mark satu kali di tombol [+]
```

### Flow B — Catat pengeluaran (target ≤ 5 detik)
```
Tap [+]  → Sheet S-11 terbuka, keypad aktif
Ketik 22000 → Tap chip "Makanan" → Tap [Simpan]
→ Sheet tertutup, saldo & list Beranda ter-update, snackbar "Tersimpan · Urungkan"
```

### Flow C — Check-in kebiasaan
```
Beranda: tap HabitChip "Kopi" → ring terisi, haptic, saldo berkurang Rp 25.000
Tap lagi (atau "Urungkan" di snackbar) → batal, saldo kembali
Long-press (khusus Kurangi) → stepper jumlah hari ini (0–10)
```

### Flow D — Refleksi
```
Tab Wawasan → Kartu utama "Kebiasaan Kurangi = 18% pengeluaran bulan ini"
→ Tap kebiasaan "Kopi" → Sheet S-31: proyeksi setahun, slider kurangi 50%
→ "Hemat ±Rp 2,0 jt per tahun" → toggle "Tabung & kembangkan" → proyeksi 1/3/5 tahun
```

## 3. Spesifikasi layar

### S-00 Splash
- **Hanya splash native** (Android 12+ SplashScreen API lewat `flutter_native_splash`, dan LaunchScreen di iOS). Latar `bg` (terang/gelap), logo mark di tengah sesuai ukuran di `04-brand-assets.md`.
- **Tidak ada `SplashScreen` widget di Flutter** dan tidak ada delay buatan. Splash native ditahan (`FlutterNativeSplash.preserve`) hanya selama inisialisasi (buka database, muat preferensi, muat locale), lalu `remove()`.
- Ini memperbaiki masalah v1: dua splash berturut-turut dan logo terpotong.

### S-01 Onboarding

```
┌──────────────────────────────┐   ┌──────────────────────────────┐
│                         Lewati│   │ ←                            │
│                              │   │                              │
│      [ ilustrasi garis ]     │   │  Panggil kamu siapa?         │
│                              │   │  Dipakai untuk sapaan saja.  │
│  Kebiasaan kecil,            │   │                              │
│  dampak besar                │   │  ┌────────────────────────┐  │
│  Lihat berapa sebenarnya     │   │  │ Raka                   │  │
│  harga rutinitasmu.          │   │  └────────────────────────┘  │
│                              │   │                              │
│          ● ○ ○               │   │                              │
│  [        Lanjut           ] │   │  [        Lanjut           ] │
└──────────────────────────────┘   └──────────────────────────────┘
```

- **Bahasa:** dua kartu besar "Bahasa Indonesia" / "English", default mengikuti perangkat.
- **Nilai produk (3 halaman):** (1) *Kebiasaan kecil, dampak besar* — lihat harga rutinitas; (2) *Catat dalam hitungan detik* — keypad cepat, check-in 1 tap; (3) *Privat di perangkatmu* — tanpa akun, data tidak keluar dari HP. Ilustrasi garis sederhana 1 warna (`teal700` + aksen `gold500`), tanpa karakter kartun.
- **Dompet pertama:** field nama (default "Tunai"/"Cash"), tipe (segmented: Tunai/Bank/E-wallet), saldo awal (keypad). Teks bantu: "Bisa ditambah atau diubah nanti."
- **Pilih kebiasaan:** dua grup "Ingin dibangun" dan "Ingin dikurangi". Kartu template bisa dipilih (maks 3), template Kurangi menampilkan biaya yang bisa di-tap untuk diubah. Tombol utama: "Mulai" (aktif walau 0 dipilih, teks jadi "Lewati dulu").
- **Template awal (ID/EN):**
  - Bangun: Olahraga (3x/minggu) / Exercise · Baca 10 halaman (harian) / Read 10 pages · Bawa bekal (hari kerja) / Pack lunch · Minum air 8 gelas (harian) / Drink 8 glasses of water.
  - Kurangi: Kopi kekinian Rp 25.000 / Café coffee · Jajan malam Rp 20.000 / Late-night snacks · Ojol jarak dekat Rp 15.000 / Short ride-hailing trips · Belanja impulsif Rp 50.000 / Impulse buys.
- **State:** progres disimpan per langkah. Back fisik = langkah sebelumnya.

### S-10 Beranda

```
┌──────────────────────────────┐
│ Selamat pagi, Raka     (◎)   │  ← avatar inisial → Profil
│                              │
│ TOTAL SALDO                  │
│ Rp 1.250.000        (mata)   │  ← ikon Eye Phosphor
│ ( ↙ Masuk Rp 2,5 jt ) ( ↗ Keluar Rp 1,25 jt )   September ▾ │
│                              │
│ Kebiasaan hari ini     Semua │
│  (○)   (●)   (○)   (○)       │  ← HabitChip, scroll horizontal
│ Kopi  Olahraga Baca  Bekal   │
│                              │
│ ┌──────────────────────────┐ │
│ │ Kopi sudah Rp 310.000    │ │  ← 1 kartu insight kontekstual
│ │ bulan ini. Lihat dampak ›│ │
│ └──────────────────────────┘ │
│                              │
│ Transaksi terbaru  Lihat semua│
│ Hari ini            −47.000  │
│ (ic) Makanan  GoPay  −22.000 │
│ (ic) Transport Tunai −25.000 │
│ Kemarin             +500.000 │
│ ...                          │
├──────────────────────────────┤
│ Beranda Kebiasaan (+) Wawasan Profil │
└──────────────────────────────┘
```

- **Sapaan** berdasarkan jam: pagi (04–10), siang (10–15), sore (15–18), malam (18–04), dengan nama dari onboarding.
- **Periode** ringkasan masuk/keluar mengikuti pemilih bulan kecil di kanan pill (default bulan ini). Total saldo selalu saldo saat ini (tidak terpengaruh bulan).
- **Strip kebiasaan:** hanya kebiasaan yang terjadwal hari ini, urutan: belum selesai dulu. Tap "Semua" → tab Kebiasaan. Kalau tidak ada kebiasaan: kartu kecil "Tambah kebiasaan pertamamu" → S-21.
- **Kartu insight:** satu saja, dipilih dari aturan sederhana (prioritas): (1) kebiasaan Kurangi dengan biaya bulan ini terbesar, (2) streak kebiasaan Bangun tertinggi ≥ 7, (3) pengeluaran naik > 20% vs periode yang sama bulan lalu. Tidak muncul kalau data < 7 hari.
- **Transaksi terbaru:** maksimal 10, dikelompokkan per hari. Tap → S-12.
- **Pull to refresh:** tidak perlu (data lokal reaktif). Semua bagian reaktif lewat stream Drift.
- **Empty:** belum ada transaksi → EmptyState "Belum ada transaksi" + tombol "Catat transaksi pertama" (buka S-11).

### S-11 Tambah / edit transaksi (bottom sheet, tinggi ±90%)

```
┌──────────────────────────────┐
│            ──                │
│ [ Pengeluaran | Pemasukan ]  │
│                              │
│         Rp 22.000            │  ← AmountDisplay
│                              │
│ (Makanan)(Transport)(Belanja)│  ← CategoryChips: 6 terakhir + "Semua ›"
│ (Hiburan)(Tagihan)(Semua ›)  │
│ Dompet         GoPay       › │  ← RowPicker
│ Tanggal        Hari ini    › │
│ Catatan        Tambah catatan│
│ ┌────┬────┬────┐             │
│ │ 1  │ 2  │ 3  │             │
│ │ 4  │ 5  │ 6  │             │  ← AmountKeypad
│ │ 7  │ 8  │ 9  │             │
│ │000 │ 0  │ ⌫  │             │
│ └────┴────┴────┘             │
│ [          Simpan          ] │
└──────────────────────────────┘
```

- Default: Pengeluaran, kategori = terakhir dipakai untuk tipe itu (terpilih), dompet = terakhir dipakai, tanggal = sekarang.
- Tap "Catatan" → field teks muncul, keypad angka disembunyikan sementara (keyboard sistem).
- Nominal maksimal 12 digit. Tombol Simpan nonaktif kalau nominal 0 atau kategori belum ada.
- **Mode edit** (dari S-12): judul "Edit transaksi", data terisi, tombol "Simpan perubahan". Transaksi dari kebiasaan: kategori/dompet/nominal bisa diedit, tanpa memutus tautan ke log.
- Setelah simpan: sheet tertutup, snackbar "Tersimpan · Urungkan".
- Tombol kembali/drag down dengan input terisi → konfirmasi ringan "Buang perubahan?".

### S-12 Detail transaksi (sheet kecil)
- Ikon kategori besar, nominal `titleLarge`, kategori, dompet, tanggal lengkap, catatan, label "Dari kebiasaan: Kopi" (tap → S-22).
- Aksi: "Edit" (Secondary) dan "Hapus" (ikon, danger). Hapus → tutup sheet + snackbar undo. Kalau dari kebiasaan: sheet konfirmasi "Ini juga membatalkan check-in Kopi hari itu."

### S-13 Riwayat transaksi
- Large title "Transaksi". Di bawahnya search bar + baris filter chip: Bulan (September 2026 ▾), Kategori ▾, Dompet ▾.
- Ringkasan kecil periode: Masuk · Keluar · Selisih.
- List per hari (DayHeader + TransactionTile), infinite scroll per bulan.
- Swipe kiri pada tile = hapus (dengan undo). Tap = S-12.
- Empty (setelah filter): "Tidak ada transaksi yang cocok" + "Hapus filter".

### S-20 Kebiasaan

```
┌──────────────────────────────┐
│ Kebiasaan               (+)  │
│ [ Hari ini | Semua ]         │
│                              │
│ BANGUN                       │
│ ┌──────────────────────────┐ │
│ │(ic) Olahraga         (✓) │ │  ← HabitTile, tombol check kanan
│ │     3x/minggu · (api) 12 hari│  ← ikon Flame Phosphor
│ └──────────────────────────┘ │
│ KURANGI                      │
│ ┌──────────────────────────┐ │
│ │(ic) Kopi             (2) │ │  ← jumlah kejadian hari ini
│ │     Rp 25.000 · minggu ini 3/4 │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

- Segmented: **Hari ini** (hanya yang terjadwal hari ini) / **Semua** (termasuk yang tidak terjadwal, plus bagian "Diarsipkan" terlipat di bawah).
- Kebiasaan Kurangi menampilkan "minggu ini 3/4" kalau ada batas mingguan (warna `warning` saat mencapai batas, `danger` saat lewat).
- Tap tile = S-22. Tap tombol check = check-in (toggle). Long-press tombol check pada Kurangi = stepper.
- Reorder dengan drag handle (mode "Atur urutan" dari menu ⋯).
- Empty: "Mulai dari satu kebiasaan" + tombol "Buat kebiasaan" + link "Pilih dari template".

### S-21 Buat / edit kebiasaan (layar penuh)
- Langkah dalam satu layar scroll (bukan wizard): Jenis (kartu Bangun / Kurangi) → Nama → Ikon & warna (grid preset) → Jadwal (Setiap hari / Hari tertentu [chip S S R K J S M] / N kali per minggu [stepper 1–7]) → khusus Kurangi: Biaya per kejadian (AmountDisplay kecil + keypad di sheet), Dompet, Kategori, Batas per minggu (opsional) → Pengingat (P1, sembunyikan di 2.0).
- Validasi inline. Tombol "Simpan" menempel di bawah.
- Edit: tambah aksi "Arsipkan" di bawah (bukan hapus, supaya riwayat & transaksi tetap utuh). Hapus permanen hanya kalau kebiasaan belum punya log.

### S-22 Detail kebiasaan
- Header: ikon besar, nama, jenis + jadwal.
- 3 statistik dalam satu baris: **Streak** (dengan ikon api), **Terbaik**, **Konsistensi 30 hari** (%).
- `HabitCalendar` bulan ini (geser untuk bulan lain) dengan legenda: selesai, hari longgar, terlewat.
- Khusus Kurangi: kartu "Biaya bulan ini Rp 310.000 · proyeksi setahun ±Rp 4,0 jt" + tombol "Simulasikan" → S-31.
- Daftar check-in terakhir (tanggal, jumlah, transaksi terkait).
- Menu ⋯: Edit, Arsipkan.

### S-30 Wawasan

```
┌──────────────────────────────┐
│ Wawasan          September ▾ │
│                              │
│ ┌──────────────────────────┐ │
│ │ 18%                      │ │  ← angka besar, gold800/gold300
│ │ pengeluaranmu bulan ini  │ │
│ │ dari kebiasaan yang ingin│ │
│ │ kamu kurangi · Rp 540.000│ │
│ │ ▓▓▓▓░░░░░░░░░░░░░░░░░░░ │ │  ← bar proporsi, bukan gradasi
│ └──────────────────────────┘ │
│                              │
│ Kebiasaan yang dikurangi     │
│ (ic) Kopi     Rp 310.000   › │
│      ±3,1x/minggu · Rp 4,0 jt/th │
│ (ic) Jajan malam Rp 230.000 ›│
│                              │
│ Kebiasaan yang dibangun      │
│ (ic) Olahraga   83%  ▲ 12 poin│
│ (ic) Baca       61%  ▼ 5 poin │
│                              │
│ Pengeluaran per kategori     │
│      [ donut chart ]         │
│ (●) Makanan  Rp 820.000  41% │
│ ...                          │
└──────────────────────────────┘
```

- Periode mengikuti pemilih bulan di kanan atas.
- Semua angka bisa di-tap: kebiasaan → S-31 (Kurangi) atau S-22 (Bangun), kategori → S-13 dengan filter.
- **Empty (data < 7 hari):** EmptyState "Wawasan muncul setelah seminggu mencatat" + progres "3 dari 7 hari" (ring kecil). Jangan tampilkan grafik kosong.

### S-31 Simulator kebiasaan (sheet)
- Judul: "Kalau Kopi dikurangi…"
- Baris info: rata-rata ±3,1 kali/minggu (4 minggu terakhir) × Rp 25.000.
- Slider "Kurangi" 0–100% (langkah 10%), label nilai di atasnya.
- Hasil utama: "Hemat ±Rp 2,0 jt per tahun" (`amountHero` kecil, `gold800`/`gold300`).
- Toggle "Tabung & kembangkan": field suku bunga per tahun (default 0%, chip cepat 0% · 3% · 5%), hasil 1/3/5 tahun dalam 3 kolom. Rumus: setoran bulanan tetap dengan bunga majemuk bulanan (lihat `05-architecture-and-data.md §6`).
- Disclaimer permanen di bawah: "Simulasi, bukan saran keuangan."
- Tombol "Atur batas mingguan" → mengisi batas per minggu di kebiasaan sesuai hasil slider (opsional).

### S-40 Profil
- Header: avatar inisial (lingkaran `teal50`, huruf `teal700`), nama (tap untuk ubah).
- Grup list: **Keuangan**: Dompet (jumlah aktif), Kategori. **Aplikasi**: Pengaturan. **Tentang**: Tentang CompoundMe (versi, lisensi open source, link GitHub).
- Tidak ada item yang belum berfungsi.

### S-41 Dompet
- List dompet aktif: ikon, nama, tipe, saldo saat ini. Total di atas. Drag untuk urutkan.
- Tap → edit (nama, tipe, ikon, warna, saldo awal). Saldo awal mengubah saldo saat ini sesuai selisih.
- Aksi: Arsipkan (kalau ada transaksi) / Hapus (kalau kosong). Minimal 1 dompet aktif (aksi nonaktif dengan penjelasan).
- Bagian "Diarsipkan" terlipat.

### S-42 Kategori
- Segmented Pengeluaran | Pemasukan. List kategori dengan ikon & warna. Tombol tambah.
- Default punya `nameKey` (diterjemahkan), kategori kustom punya nama bebas.
- Kategori yang sudah dipakai: Arsipkan. Kosong: Hapus.
- **Default pengeluaran:** Makanan & minuman, Transportasi, Belanja, Tagihan, Hiburan, Kesehatan, Pendidikan, Lainnya. **Default pemasukan:** Uang saku / gaji, Freelance, Hadiah, Lainnya.

### S-43 Pengaturan
- **Tampilan:** Bahasa (Indonesia / English), Tema (Ikuti sistem / Terang / Gelap), Sembunyikan saldo saat membuka app (toggle).
- **Data:** Hapus semua data (danger, konfirmasi 2 langkah + ketik `HAPUS`/`DELETE`). Ekspor & backup muncul di 2.1.
- **Tentang:** versi app, "Dibuat oleh Hisyam Khaeru Umam", link repo.

## 4. Pola interaksi global

| Pola | Aturan |
|---|---|
| Hapus | Tidak pernah pakai dialog "Yakin?" untuk hal yang bisa di-undo. Pakai snackbar undo 4 detik. Dialog hanya untuk yang tidak bisa dibatalkan (hapus semua data). |
| Simpan | Optimistic: UI langsung berubah, error ditampilkan lewat snackbar + rollback. |
| Navigasi kembali | Tombol back sistem selalu bekerja. Sheet dengan input kotor minta konfirmasi. |
| Keyboard | Field teks tidak pernah tertutup keyboard (`resizeToAvoidBottomInset` + scroll). |
| Angka | Selalu tabular, selalu `Rp` di depan kecuali di grafik. |
| Waktu | "Hari ini", "Kemarin", lalu nama hari untuk 7 hari terakhir, lalu tanggal lengkap. |
| Loading | Skeleton hanya jika > 300 ms. Data lokal biasanya instan, jadi jangan tampilkan spinner yang berkedip. |

## 5. Aksesibilitas per layar (checklist)

- [ ] Semua tombol ikon punya `Semantics(label:)` / `tooltip` di kedua bahasa.
- [ ] Nominal dibacakan lengkap ("dua puluh dua ribu rupiah") lewat `semanticsLabel` pada teks nominal.
- [ ] HabitChip membacakan status ("Kopi, sudah check-in 2 kali hari ini, tombol").
- [ ] Urutan fokus logis (atas → bawah, kiri → kanan).
- [ ] Uji dengan TalkBack minimal di S-10, S-11, S-20.
- [ ] Uji `textScaler` 1,3 di semua layar.

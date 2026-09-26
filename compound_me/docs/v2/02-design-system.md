# CompoundMe v2.0 — Design System & Panduan UI

| | |
|---|---|
| Status | Draft 1 |
| Arah visual | iOS-clean di atas Material 3: satu desain untuk Android & iOS |
| Dokumen terkait | `01-PRD.md`, `03-ux-flows-and-screens.md`, `04-brand-assets.md` |

> Dokumen ini adalah **sumber kebenaran** untuk semua keputusan visual. Kalau ada layar yang butuh nilai di luar token di sini, tambahkan tokennya dulu di dokumen ini (dan di `lib/core/design/`), jangan pakai angka lepas di widget.

---

## 1. Prinsip desain

1. **Tenang dan lega.** Banyak ruang kosong, satu fokus utama per layar. Terinspirasi dari rasa rapi app iOS, bukan super-app yang padat.
2. **Angka adalah pahlawan.** Nominal uang dan progres kebiasaan adalah elemen paling menonjol, sisanya mundur.
3. **Datar, bukan mengilap.** Tanpa gradasi, tanpa glassmorphism, tanpa bayangan tebal. Kedalaman dibuat lewat warna permukaan (tonal) dan garis tipis.
4. **Konsisten di atas kreatif.** Satu skala tipografi, satu set ikon, satu grid jarak. Kreativitas masuk lewat konten dan micro-interaction, bukan variasi ukuran.
5. **Ramah dan jujur.** Bahasa manusia tanpa emoji, tanpa hiperbola, tanpa data palsu.

## 2. Referensi & apa yang diambil

Yang diambil adalah **pola**, bukan tampilan. Jangan meniru logo, ilustrasi, warna merek, atau layout pixel-per-pixel dari app mana pun.

| Referensi | Pola yang diambil | Yang dihindari |
|---|---|---|
| **DANA v2.0** | Beranda dirapikan dari kepadatan v1. Aksi inti sedikit dan jelas. Ikon diuji ke pengguna. Ringkasan pengeluaran per kategori + ringkasan bulanan. | Banner promo, "What's New" feed, kepadatan layanan. |
| **GoPay** (studi kasus) | Aksi utama (bayar) diletakkan paling mudah dijangkau. Ringkasan transaksi bulanan di beranda. Font dan penempatan tombol harus konsisten. | Grid layanan super-app, warna aksen berlebihan. |
| **E-wallet lokal umum** | Tombol mata untuk menyembunyikan saldo. Keypad angka khusus saat input nominal. Format `Rp 25.000`. | Pop-up promo, badge merah di mana-mana. |
| **Copilot Money** (iOS) | Ringkasan dulu, detail belakangan (progressive disclosure). Warna data semantik yang konsisten (masuk/keluar). Grafik sebagai antarmuka yang bisa di-tap, bukan hiasan. Teks gelap tidak 100% putih. | Estetika "deep space" yang terlalu gelap untuk default, headline raksasa. |
| **Streaks** (Apple Design Award) | Kebiasaan tampil sebagai lingkaran/ikon yang cepat dikenali. Batasi jumlah kebiasaan di awal. Dukung kebiasaan negatif (yang ingin dikurangi). | Tap-and-hold sebagai satu-satunya cara check-in (kurang discoverable). |
| **App pencatat keuangan (praktik umum)** | Tombol tambah dalam jangkauan jempol. Default pintar. Undo alih-alih dialog konfirmasi. | Formulir panjang dengan banyak field wajib. |

## 3. Warna

Palet teal + emas dari v1 dipertahankan, tapi dirapikan: emas `#FFD700` yang terlalu neon diganti emas yang lebih matang, dan ditambah skala netral bernuansa teal supaya permukaan tidak terasa abu-abu mati.

**Aturan utama: tidak ada gradasi.** Untuk efek "lembut", pakai **tint** (warna yang sama dengan opacity 8–16%) atau warna skala 50/100. Ini yang dimaksud "di-fade-kan saja".

### 3.1 Skala brand

| Token | Hex | Pakai untuk |
|---|---|---|
| `teal50` | `#E6F2F0` | Latar chip terpilih, latar kartu insight (terang) |
| `teal100` | `#CCE5E1` | Border fokus lembut, track progress |
| `teal200` | `#99CBC3` | Ilustrasi garis, disabled pada latar teal |
| `teal400` | `#4DB6AC` | **Primary di tema gelap**, data "masuk" di tema gelap |
| `teal700` | `#00695C` | **Primary di tema terang**: tombol utama, tab aktif, data "masuk" |
| `teal800` | `#004D40` | Pressed state tombol primary |
| `teal900` | `#00332E` | Teks di atas emas, judul ilustrasi |
| `gold50` | `#FDF6E3` | Latar highlight "hemat / pencapaian" (terang) |
| `gold100` | `#FAEBC2` | Badge streak (terang) |
| `gold300` | `#F2CF6B` | **Aksen di tema gelap**, ikon streak di tema gelap |
| `gold500` | `#E0A91B` | **Aksen utama**: badge streak, lingkaran check-in selesai, highlight angka hemat. Selalu dengan teks `teal900` di atasnya |
| `gold800` | `#8A6400` | Teks emas di latar terang (satu-satunya emas yang boleh jadi warna teks) |

### 3.2 Netral & permukaan

| Token | Terang | Gelap | Pakai untuk |
|---|---|---|---|
| `bg` | `#F7F9F8` | `#0C1211` | Latar layar |
| `surface` | `#FFFFFF` | `#141C1A` | Kartu, sheet, list |
| `surfaceMuted` | `#EFF2F1` | `#1C2624` | Input field, segmented control, skeleton |
| `border` | `#E2E7E5` | `#2A3533` | Garis kartu 1 px, divider |
| `textPrimary` | `#121917` | `#E8EEEC` | Teks utama, nominal |
| `textSecondary` | `#5C6865` | `#A7B3B0` | Subjudul, metadata |
| `textTertiary` | `#6B7774` | `#7A8683` | Placeholder, caption non-penting |

### 3.3 Semantik

| Token | Terang | Gelap | Aturan |
|---|---|---|---|
| `income` | `teal700` | `teal400` | Nominal masuk, selalu dengan tanda `+` |
| `expense` | `textPrimary` | `textPrimary` | Nominal keluar tampil **netral** dengan tanda `−` (bukan merah). Merah membuat mencatat terasa seperti dimarahi. |
| `danger` | `#C53B3B` | `#F07070` | Hanya untuk error, hapus, dan melewati anggaran |
| `warning` | `gold800` | `gold300` | Mendekati batas anggaran/kebiasaan |
| `success` | `teal700` | `teal400` | Konfirmasi |

### 3.4 Kontras (sudah dihitung, WCAG 2.2 AA butuh 4,5:1 untuk teks normal)

| Pasangan | Rasio |
|---|---|
| `textPrimary` di `bg` terang | 16,87 |
| `textSecondary` di `surface` terang | 5,80 |
| `textTertiary` di `surface` terang | 4,65 |
| `teal700` di `surface` terang (dan putih di `teal700`) | 6,61 |
| `teal700` di `teal50` | 5,77 |
| `teal900` di `gold500` | 6,52 |
| `gold800` di `surface` terang | 5,38 |
| `danger` di `surface` terang | 5,17 |
| `textSecondary` di `surface` gelap | 8,03 |
| `textTertiary` di `surface` gelap | 4,60 |
| `teal400` di `surface` gelap | 7,10 |

Kombinasi yang **dilarang** karena gagal kontras: teks putih di `teal400`/`teal500` (4,23), teks `gold500` di latar putih (<3), teks putih di `gold500`.

### 3.5 Warna kategori & dompet

Kategori dan dompet memilih dari **8 warna preset** (bukan color picker bebas), masing-masing punya versi `bg` (tint 12%) dan `fg` (warna ikon):

`teal`, `gold`, `coral #D9655B`, `violet #7C6BC4`, `blue #3F7FD1`, `green #3E9A5C`, `rose #C45A8A`, `slate #5F6F7A`.

Ikon kategori selalu tampil sebagai ikon `fg` di dalam lingkaran/rounded square `bg`. Tidak ada latar warna penuh.

## 4. Tipografi

**Font: Plus Jakarta Sans** (open source, Google Fonts). Dirancang oleh Tokotype untuk program "Jakarta City of Collaboration" tahun 2020. Pilihan ini punya cerita lokal yang bagus untuk portofolio, geometris-humanis, dan angkanya jelas. Menggantikan Poppins v1.

- Font **dibundel sebagai aset** lewat `fonts:` di `pubspec.yaml` (bukan paket `google_fonts`), supaya jalan offline dan tidak ada kedipan font. File `OFL.txt` disertakan dan didaftarkan ke `LicenseRegistry`.
- **Semua nominal uang wajib memakai angka tabular** (`FontFeature.tabularFigures()`) supaya digit sejajar di list.
- Maksimal **2 ketebalan per layar** selain nominal utama.

| Token | Ukuran / tinggi baris (sp) | Tebal | Pakai untuk |
|---|---|---|---|
| `amountHero` | 34 / 40, tracking −0.5 | 700 | Total saldo di Beranda, nominal di keypad |
| `titleLarge` | 24 / 30, tracking −0.3 | 700 | Judul besar layar (large title) |
| `titleMedium` | 18 / 24 | 600 | Judul sheet, judul kartu utama |
| `titleSmall` | 16 / 22 | 600 | Judul section, item list utama |
| `body` | 15 / 22 | 400 | Teks isi |
| `bodyStrong` | 15 / 22 | 600 | Nominal di list, penekanan |
| `bodySmall` | 13 / 18 | 400 | Metadata, subjudul list |
| `label` | 14 / 20 | 600 | Tombol, chip, tab |
| `caption` | 12 / 16 | 500 | Keterangan grafik, timestamp |
| `overline` | 11 / 14, tracking +0.4 | 600 | Label kecil di atas angka ("TOTAL SALDO"), satu-satunya yang boleh kapital semua |

Perbandingan v1 → v2: saldo 38 → 34, judul 28 → 24, header section 18 → 16, teks list 16 → 15. Target: layar terasa lebih ringan tanpa mengorbankan keterbacaan.

Text scaling: layout wajib tetap utuh sampai `textScaler` 1,3. Nominal hero boleh mengecil otomatis (`FittedBox`) tapi tidak boleh terpotong.

## 5. Jarak, grid, bentuk

**Grid dasar 4 dp.** Nilai jarak hanya boleh dari skala ini:

| Token | dp | Pakai untuk |
|---|---|---|
| `space1` | 4 | Jarak ikon–teks rapat |
| `space2` | 8 | Jarak antar elemen dalam satu grup |
| `space3` | 12 | Padding chip, jarak list rapat |
| `space4` | 16 | Padding kartu, jarak antar kartu |
| `space5` | 20 | **Margin horizontal layar** |
| `space6` | 24 | Jarak antar section |
| `space8` | 32 | Jarak antar section besar, atas empty state |
| `space10` | 40 | Ruang atas/bawah hero |

| Token radius | dp | Pakai untuk |
|---|---|---|
| `radiusSm` | 10 | Chip kecil, input |
| `radiusMd` | 14 | Tombol, tile kebiasaan |
| `radiusLg` | 20 | Kartu |
| `radiusXl` | 28 | Sudut atas bottom sheet |
| `radiusFull` | 999 | Pill, avatar, lingkaran |

**Elevasi:** default datar. Kartu = `surface` + border 1 px `border`. Bayangan hanya untuk elemen melayang (bottom sheet, tombol tambah tengah, snackbar): `0 4 16 rgba(0,0,0,0.06)` di tema terang, tanpa bayangan di tema gelap (pakai `surface` yang lebih terang).

**Target sentuh:** minimal 48×48 dp untuk semua yang bisa di-tap (sesuai Material). Ikon boleh 20–24 dp, tapi area tap-nya tetap 48.

## 6. Ikonografi

- **Satu set ikon: Phosphor Icons** (lisensi MIT), **dibundel sebagai font** (`Phosphor-Regular.ttf`, `Phosphor-Fill.ttf`) dan dipetakan di `AppIcons`. Paket `phosphor_flutter` tidak dipakai karena rilis terakhirnya (Mei 2024) tidak bisa dikompilasi di Flutter 3.43+ (keputusan Fase 0). Varian `regular` untuk default, `fill` untuk tab aktif dan status selesai. Jangan campur dengan `Icons.*` Material kecuali ikon sistem yang tidak ada padanannya. Lisensi MIT disertakan dan didaftarkan ke `LicenseRegistry`.
- Ukuran: 20 dp (dalam list/chip), 24 dp (tab bar, app bar), 28 dp (tile kebiasaan).
- Ikon kategori, dompet, dan kebiasaan dipilih dari **daftar kurasi ±48 ikon** (disimpan sebagai `iconKey` string, lihat `05-architecture-and-data.md`). Jangan simpan codepoint mentah.
- **Tidak ada emoji** di UI mana pun, termasuk nama template, notifikasi, dan empty state.

## 7. Komponen

Semua komponen dibuat sekali di `lib/core/design/components/` dan dipakai ulang. Nama di bawah adalah nama widget yang disarankan.

### 7.1 Navigasi
- **`AppBottomNav`**: 5 slot: Beranda, Kebiasaan, **[Tambah]**, Wawasan, Profil. Slot tengah adalah tombol bulat 56 dp `teal700` dengan ikon plus putih, sedikit naik 8 dp dari baris tab (pola aksi utama di tengah, seperti tombol bayar di e-wallet). Tab lain: ikon 24 + label `caption`, aktif = ikon `fill` + `teal700`, non-aktif = `textTertiary`. Latar `surface` dengan border atas 1 px. Tinggi 64 dp + safe area.
- **`AppLargeTitle`**: judul layar gaya iOS: `titleLarge` rata kiri di bawah status bar, menyusut jadi judul kecil di app bar saat di-scroll (`SliverAppBar` + `FlexibleSpaceBar`). Aksi di kanan maksimal 2 ikon.

### 7.2 Tombol
| Varian | Spesifikasi |
|---|---|
| `PrimaryButton` | Tinggi 52, radius `radiusMd`, latar `teal700` (gelap: `teal400` dengan teks `teal900`), teks `label` putih. Lebar penuh di form/sheet. |
| `SecondaryButton` | Tinggi 52, latar `teal50` (gelap: tint teal 16%), teks `teal700`/`teal400`. |
| `GhostButton` | Tanpa latar, teks `teal700`, untuk aksi ketiga ("Lewati", "Nanti saja"). |
| `DestructiveButton` | Seperti Secondary tapi warna `danger`. Hanya di sheet konfirmasi. |
| `IconButtonTonal` | Lingkaran 40 dp latar `surfaceMuted`, ikon 20. Area tap 48. |

State: pressed = warna 1 tingkat lebih gelap + skala 0,98 (`motionFast`, 120 ms). Disabled = opacity 40%, tidak bisa di-tap. Loading = spinner 20 dp menggantikan teks, lebar tombol tetap.

### 7.3 Kartu & list
- **`AppCard`**: `surface`, radius `radiusLg`, border 1 px, padding 16.
- **`BalanceHeader`**: overline "TOTAL SALDO", `amountHero`, tombol mata di sebelah kanan angka. Di bawahnya dua pill kecil berlatar `surfaceMuted`: ikon Phosphor `ArrowDownLeft` + "Masuk Rp …" (warna `income`) dan ikon `ArrowUpRight` + "Keluar Rp …" (warna `textPrimary`). Tanpa kartu berwarna penuh.
- **`TransactionTile`**: tinggi 64. Kiri: ikon kategori (lingkaran 40, `bg`/`fg` kategori). Tengah: nama kategori (`titleSmall`) + catatan atau dompet (`bodySmall`, `textSecondary`, 1 baris ellipsis). Kanan: nominal (`bodyStrong`, tabular, `+` teal atau `−` netral) + jam (`caption`). Label kecil "Kebiasaan" kalau berasal dari check-in.
- **`DayHeader`**: "Hari ini" / "Kemarin" / "Senin, 21 Sep" (`label`, `textSecondary`) + subtotal hari di kanan.
- **`SectionHeader`**: `titleSmall` + aksi teks "Lihat semua" di kanan.

### 7.4 Kebiasaan
- **`HabitChip`** (strip Beranda): lingkaran 56 dp dengan ikon kebiasaan, ring progres 3 dp di sekelilingnya, nama di bawah (`caption`, 1 baris). Belum = ring `border`, ikon warna kebiasaan di latar `surface`. Selesai = lingkaran terisi `teal700` (gelap: `teal400`) dengan ikon putih (gelap: `teal900`). Kurangi yang sudah tercatat = ring `teal700` + badge angka jumlah. Animasi ring terisi 250 ms + haptic ringan. Emas **tidak** dipakai untuk status selesai supaya tetap jadi aksen langka (streak, angka hemat).
- **`HabitTile`** (tab Kebiasaan): tinggi 72, radius `radiusMd`, ikon kiri, nama + jadwal/biaya, di kanan tombol check 44 dp (lingkaran). Info streak kecil dengan ikon api Phosphor `gold800`/`gold300` (bukan emoji).
- **`HabitCalendar`**: grid bulan 7 kolom, sel 36 dp. Selesai = lingkaran `teal700`, hari longgar = lingkaran outline `gold500`, terlewat = titik `border`, tidak terjadwal = kosong.

### 7.5 Input
- **`AmountKeypad`**: grid 3×4 (1–9, `000`, 0, hapus), tombol 56 dp tinggi dengan jarak 8, teks `titleMedium`, latar tombol `surfaceMuted`, radius `radiusMd`. Long-press hapus = kosongkan. Haptic `selectionClick` per tap.
- **`AmountDisplay`**: "Rp" (`titleMedium`, `textSecondary`) + angka `amountHero`, rata tengah, placeholder "0" `textTertiary`.
- **`SegmentedToggle`**: 2–3 opsi, tinggi 40, latar `surfaceMuted`, thumb `surface` dengan border (gaya iOS).
- **`CategoryChips`**: wrap/horizontal scroll, chip tinggi 40, ikon 20 + nama. Terpilih = latar `teal50`, border `teal700`.
- **`AppTextField`**: tinggi 52, latar `surfaceMuted`, tanpa garis bawah, radius `radiusSm`, label di atas field (bukan floating label), error di bawah (`bodySmall`, `danger`).
- **`RowPicker`**: baris 56 dp "Dompet · GoPay ›" untuk membuka picker sheet.

### 7.6 Feedback
- **`UndoSnackbar`**: melayang di atas bottom nav, `textPrimary` inverse, radius `radiusMd`, teks + aksi "Urungkan". 4 detik.
- **`EmptyState`**: ikon Phosphor 48 dp di lingkaran `teal50` 88 dp, judul `titleSmall`, penjelasan `body` `textSecondary` maksimal 2 baris, satu tombol. Tidak ada ilustrasi kartun generik.
- **`Skeleton`**: blok `surfaceMuted` dengan shimmer halus (opacity 0,5↔1, 1.200 ms). Hanya jika loading > 300 ms.
- **`ErrorState`**: seperti EmptyState dengan ikon peringatan dan tombol "Coba lagi". Detail teknis hanya di log.

### 7.7 Grafik (pakai `fl_chart`)
- Donut kategori: ketebalan 20, celah 2°, maksimal 6 segmen + "Lainnya". Label di list di bawahnya, bukan di dalam donut.
- Bar mingguan kebiasaan: bar radius atas 6, warna kebiasaan, sumbu minimal (tanpa grid tebal).
- Tap segmen/bar = sorot + tooltip kecil. Tidak ada animasi masuk lebih dari 400 ms.

## 8. Motion & haptic

| Token | Durasi | Kurva | Contoh |
|---|---|---|---|
| `motionFast` | 120 ms | easeOut | Pressed state, chip terpilih |
| `motionBase` | 250 ms | easeOutCubic | Ring check-in, pergantian tab konten |
| `motionSheet` | 320 ms | easeOutCubic (masuk) / easeInCubic (keluar) | Bottom sheet |

- Hormati pengaturan "kurangi animasi" di perangkat (`MediaQuery.disableAnimations`).
- Haptic: `selectionClick` (chip, keypad, tab), `lightImpact` (check-in), `mediumImpact` (hapus). Tidak ada getaran untuk hal lain.
- Tidak ada animasi mantul/berlebihan. Splash tidak dianimasikan (satu splash native, lihat `04-brand-assets.md`).

## 9. Suara & penulisan (copywriting)

- **Sapaan "kamu"** (ID) / **"you"** (EN). Kalimat pendek, sentence case ("Tambah dompet", bukan "TAMBAH DOMPET" atau "Tambah Dompet").
- **Tanpa emoji. Tanpa tanda seru beruntun. Tanpa kata "Sultan", "Mantap!", atau emoji roket seperti v1.**
- Angka jujur dan spesifik: "Kopi = 18% pengeluaranmu bulan ini" lebih baik dari "Kamu boros banget!".
- Tidak menyalahkan: "Belum ada catatan hari ini" bukan "Kamu lupa mencatat!".
- Tombol = kata kerja: "Simpan", "Catat", "Check-in", "Urungkan".
- Uang: selalu `Rp 25.000` (spasi setelah Rp, titik sebagai pemisah ribuan, tanpa desimal) **di kedua bahasa**, karena mata uangnya IDR dan format Indonesia yang dikenal pengguna. Singkatan hanya di sumbu/label grafik: `25 rb` / `1,2 jt` (ID) dan `25K` / `1.2M` (EN).

Contoh pasangan string:

| Konteks | Indonesia | English |
|---|---|---|
| Empty Beranda | Belum ada transaksi. Catat yang pertama, cuma butuh beberapa detik. | No transactions yet. Log your first one, it only takes a few seconds. |
| Setelah check-in | Dicatat · Urungkan | Logged · Undo |
| Hari longgar | Kemarin terlewat, tidak apa-apa. Lanjutkan hari ini. | You missed yesterday, that's okay. Keep going today. |
| Insight utama | Kebiasaan yang ingin kamu kurangi menyumbang 18% pengeluaran bulan ini. | Habits you want to cut make up 18% of this month's spending. |
| Disclaimer simulasi | Simulasi, bukan saran keuangan. | Simulation only, not financial advice. |
| Error umum | Gagal menyimpan. Coba lagi. | Couldn't save. Please try again. |

## 10. Daftar larangan "AI slop"

Checklist ini wajib dicek di setiap review layar:

- [ ] Tidak ada `LinearGradient`/`RadialGradient` di UI (kecuali di aset brand yang sudah disetujui, dan saat ini **tidak ada**).
- [ ] Tidak ada emoji di string mana pun.
- [ ] Tidak ada warna/ukuran/jarak angka lepas di widget. Semua dari token.
- [ ] Tidak ada lingkaran dekoratif transparan, blob, atau glow.
- [ ] Tidak ada data dummy, tombol yang tidak berfungsi, atau teks "Segera hadir" di UI rilis.
- [ ] Tidak ada nama pengguna hardcoded.
- [ ] Maksimal satu elemen emas (`gold500`) yang menonjol per layar.
- [ ] Setiap layar punya empty, loading, dan error state.
- [ ] Tidak ada komentar kode seperti `// PERBAIKAN DISINI`, `// AJAIB`, `// --- SULTAN ---`.

## 11. Tema gelap

Tema gelap bukan inversi. Gunakan kolom "Gelap" di tabel token. Aturan tambahan:
- Primary pindah ke `teal400` dengan teks `teal900` di atas tombol.
- Aksen emas pindah ke `gold300`.
- Tanpa bayangan. Elevasi = `surface` → `surfaceMuted`.
- Teks utama `#E8EEEC` (bukan putih murni) untuk mengurangi silau.
- Warna pressed dan tint tema gelap diturunkan di `tokens.dart` pada Fase 0 (kontras sudah dicek). Nilainya ditambahkan ke bagian ini oleh Claude Code di Fase 1, supaya dokumen tetap jadi sumber kebenaran.

## 12. Implementasi di Flutter (ringkas)

- `lib/core/design/tokens.dart`: `AppColors` (terang & gelap), `AppSpacing`, `AppRadius`, `AppDurations`.
- `lib/core/design/typography.dart`: `AppTextStyles` dari tabel §4.
- `lib/core/design/theme.dart`: `ThemeData` M3 (`useMaterial3: true`) + `ThemeExtension<AppTokens>` untuk token yang tidak ada di `ColorScheme` (income, expense, gold, surfaceMuted, dll.). Widget membaca token lewat `context.tokens`, bukan `Colors.*`.
- Lint kustom sederhana di review: cari `Color(0x`, `Colors.`, `fontSize:`, `EdgeInsets.all(<angka>)` di luar folder `core/design`. Seharusnya 0 hasil.

## Sumber

- Material Design 3 (target sentuh 48 dp, M3 theming): https://m3.material.io
- WCAG 2.2 SC 1.4.3 Contrast (Minimum): https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- Plus Jakarta Sans (Tokotype): https://github.com/tokotype/PlusJakartaSans dan https://fonts.google.com/specimen/Plus+Jakarta+Sans
- DANA v2.0: https://medium.com/dana-engineering/small-steps-big-impact-journey-to-dana-v2-0-e2ec0a63838f
- Studi kasus GoPay: https://medium.com/@katherinenatalia2/ui-ux-case-study-gopay-app-5cb7c1c001f8
- Copilot Money design guide: https://blakecrosley.com/guides/design/copilot-money
- Streaks 3 review: https://www.macstories.net/reviews/streaks-3-review/

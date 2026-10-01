# CompoundMe v2.0 — Laporan Audit Fase 6

Audit terhadap `02-design-system.md` §10, `03-ux-flows-and-screens.md` §4–§5 dan PRD §8, dengan grep dan test otomatis (bukan membaca semua file). Test-nya tinggal di `test/audit/` dan ikut CI, jadi temuan yang sudah beres tidak bisa kembali diam-diam.

| # | Area | Cara cek | Temuan (sebelum) | Setelah | Status |
|---|---|---|---|---|---|
| 1 | Angka lepas di luar `lib/core/design` (`Color(0x`, `Colors.`, `fontSize:`, angka di `EdgeInsets`/`SizedBox`/`Radius`/`Duration`, `width:`/`height:`/`size:`) | `test/audit/design_rules_test.dart` | 0 | 0 | Lulus |
| 2 | Gradasi, blur, emoji, komentar "PERBAIKAN/AJAIB/SULTAN", teks "segera hadir", data dummy | idem | 0 | 0 | Lulus |
| 3 | Kunci terjemahan `app_id.arb` = `app_en.arb` | idem | sama | sama | Lulus |
| 4 | Aksi tanpa nama untuk pembaca layar (tombol ikon, kartu, baris) | `test/audit/accessibility_audit_test.dart`: 16 rute, 3 sheet, onboarding, id & en, 360 dp, textScaler 1,3; ada kontrol negatif (`IconButton` tanpa tooltip terdeteksi) | 0 | 0 | Lulus |
| 5 | Nominal dibaca lengkap | `spokenRupiah` + test | "Rp 22.000" dibaca apa adanya (suara Inggris: "twenty-two point zero zero zero") | "dua puluh dua ribu rupiah" / "twenty-two thousand rupiah" di saldo, ringkasan, baris dan header transaksi, input nominal, detail transaksi, daftar Wawasan, simulator, check-in | Diperbaiki. Kalimat yang memuat nominal (kartu insight, keterangan) dibaca apa adanya: uji TalkBack manual |
| 6 | Overflow di 360 dp, textScaler 1,3 | audit a11y di atas + `layout` emulator Fase 5 | S-41 baris dompet melewati 41 px (saldo jutaan); editor dompet (en) 64 px ("Starting balance"); Wawasan memotong kata dan pil bulan menimpa judul | Saldo mengecil di baris (`BalanceText.shrinkToFit`); `RowPicker` menumpuk label di atas nilai di atas 1,15×; `InsightHabitTile`; pil bulan di bawah judul | Diperbaiki, 0 overflow |
| 7 | Skeleton hanya jika > 300 ms | grep `Skeleton` | semua lewat `DelayedReveal` / `AsyncBody` | sama | Lulus |
| 8 | Error state dengan "Coba lagi" di layar yang membaca data | `test/audit/error_states_test.dart` memaksa error di Beranda, S-13, S-20, S-30 (dua sumber), S-41, S-42 dan memeriksa pemulihan setelah retry | tidak ada test tingkat layar | 7 layar lulus, Beranda pulih. S-40, S-43, Tentang hanya membaca jumlah dompet dan versi dan jatuh ke tanpa angka | Lulus, dengan catatan |
| 9 | Scroll riwayat, 1.000 transaksi (profile, emulator) | `integration_test/perf_history_test.dart` | — | Thread UI: build rata-rata 0,35 ms, p99 1,0 ms, 0 frame terlewat. Raster: rata-rata 38,5 ms, p99 50 ms; `ListView` polos 1.000 tile di emulator yang sama: 30,5 ms, p99 50 ms | Thread UI lulus. Raster dibatasi jembatan GPU emulator; angka HP sungguhan di QA manual |
| 10 | Cold start sampai frame pertama (profile, `--trace-startup`, ±1.000 transaksi) | `flutter run --profile --trace-startup` ×3 | — | 1,60 / 1,34 / 1,44 detik (target ≤ 2) | Lulus |
| 11 | Build release (R8) di emulator | `qa_phase6.py release` | — | 8/8: onboarding, transaksi lewat Drift, check-in, Wawasan, Tentang (2.0.0), force stop + buka lagi, logcat tanpa `FATAL EXCEPTION`/`ClassNotFoundException`/`NoSuchMethodError`/`UnsatisfiedLinkError`, proses hidup | Lulus |
| 12 | Page size 16 KB | `zipalign -c -P 16 -v 4` dan `p_align` segmen LOAD tiap `.so` (lihat dokumentasi Android) | — | "Verification successful"; arm64-v8a dan x86_64: `libapp`/`libflutter` 0x10000, `libsqlite3`/`libdartjni`/`libdatastore_shared_counter` 0x4000; tidak ada di bawah 0x4000 | Lulus. Tidak diuji di image emulator 16 KB (tidak diunduh) |
| 13 | Alat debug (data contoh 60 hari) tidak ikut rilis | scan `libapp.so` tiga ABI | — | 0 kemunculan | Lulus |
| 14 | Maksimal satu elemen emas per layar | grep pemakaian `accent`/`accentText` per berkas | — | satu kartu atau ikon per layar | Lulus |
| 15 | Nama pengguna hardcoded | grep | — | hanya "Hisyam Khaeru Umam" di Tentang (l10n), sesuai 03 S-40 | Lulus |
| 16 | README: klaim Web | baca ulang | "Berjalan di Android, iOS, dan Web" | README baru (Inggris), tanpa Web | Diperbaiki |
| 17 | Versi | `pubspec.yaml` | 1.0.0+1 | 2.0.0+2 | Selesai |
| 18 | Tanda tangan rilis | tag `v1-legacy` | v1 memakai kunci debug | upload keystore baru di luar repo, `key.properties` di `.gitignore`; tanpa kunci build rilis jatuh ke kunci debug | Selesai |

Suite akhir: `flutter analyze` 0 issue, `flutter test` 353 hijau.

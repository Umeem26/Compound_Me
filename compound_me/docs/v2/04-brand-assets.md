# CompoundMe v2.0 — Brand Assets: Icon, Splash, Logo

| | |
|---|---|
| Status | Aset siap pakai (di `assets/brand/`), bisa diganti kalau ada versi desain final lain |
| Generator | `tool/generate_brand_assets.py` (reproducible, tinggal jalankan ulang kalau geometri/warna diubah) |

---

## 1. Kenapa icon & splash v1 bermasalah

| Gejala di v1 | Penyebab teknis |
|---|---|
| Icon terlihat "nge-zoom" dan terpotong | `adaptive_icon_foreground` memakai gambar logo penuh (`app_icon.png`) tanpa ruang aman. Di adaptive icon, layer berukuran 108 dp tapi yang terlihat hanya ±72 dp di tengah, dan area aman yang dijamin tidak terpotong hanya **66 dp**. Logo yang memenuhi kanvas pasti terpotong dan terlihat membesar. |
| Logo splash juga terpotong | Ikon splash Android 12+ dimasking lingkaran: tanpa latar ikon, gambar 1152×1152 px harus muat di lingkaran diameter **768 px**. Logo v1 memenuhi kanvas. |
| Ada dua splash berturut-turut | Splash native (`flutter_native_splash`) lalu `SplashScreen` widget Flutter dengan `Icons.account_balance_wallet_rounded` (ikon bawaan Material) dan `Future.delayed(3 detik)`. Dokumentasi Android menyarankan memakai SplashScreen API, bukan splash kustom kedua. |

## 2. Logo mark

**Konsep: tiga titik yang tumbuh.** Setiap titik 1,5× lebih besar dari sebelumnya (radius 50 → 75 → 112,5), bergerak naik ke kanan, dan warnanya berubah dari teal pudar → putih → emas.

Ceritanya: kebiasaan kecil (titik kecil), kalau diulang, menggulung jadi hasil yang berarti (titik emas). Rasio 1,5× itu sendiri adalah compounding. Bentuknya sederhana sehingga tetap terbaca di 32 px, tanpa gradasi, tanpa teks.

| Elemen | Warna |
|---|---|
| Titik 1 (kecil) | `teal200` `#99CBC3` |
| Titik 2 (sedang) | Off-white `#F7F9F8` |
| Titik 3 (besar) | `gold500` `#E0A91B` |
| Latar icon | `teal700` `#00695C` |

Aturan pemakaian:
- Jangan diputar, dibalik, atau diberi bayangan/gradasi.
- Jangan ubah urutan warna. Emas selalu titik terbesar.
- Ruang kosong di sekitar mark minimal setara radius titik terbesar.
- Di latar terang tanpa kotak teal: pakai versi di dalam lingkaran/kotak teal (app icon), jangan titik lepas (titik putih akan hilang).

**Wordmark:** "CompoundMe" ditulis dengan Plus Jakarta Sans Bold, tracking −0,5, warna `textPrimary`. Di v2.0 wordmark hanya dipakai sebagai teks di layar Tentang dan onboarding, jadi tidak perlu file gambar.

## 3. Daftar aset (`assets/brand/`)

| File | Ukuran | Pakai untuk |
|---|---|---|
| `app_icon_1024.png` (+ `.svg`) | 1024×1024, latar teal, tanpa transparansi | Icon iOS, icon Android lama (< 8.0), Play Store/README |
| `adaptive_foreground.png` | 1024×1024, transparan | Layer depan adaptive icon Android. Mark sudah di dalam safe zone (radius terjauh 302 px dari batas 313 px) |
| `adaptive_monochrome.png` | 1024×1024, putih + alpha | Themed icon Android 13+ |
| `splash_mark_1152.png` | 1152×1152, transparan | Icon splash Android 12+ dan gambar splash lama (radius terjauh 339 px dari batas 384 px) |
| `ic_stat_mark_96.png` | 96×96, putih + alpha | Ikon kecil notifikasi (dipakai mulai v2.1 untuk pengingat) |
| `preview_sheet.png` | — | Pratinjau: bentuk mask berbeda, themed icon, ukuran kecil, splash terang/gelap |

Latar adaptive icon = warna solid `#00695C` (bukan gambar).

## 4. Konfigurasi `pubspec.yaml`

> Cek versi terbaru di pub.dev sebelum menulis constraint. Saat dokumen ini ditulis: `flutter_launcher_icons` 0.14.4, `flutter_native_splash` 2.4.8.

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.8

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/brand/app_icon_1024.png"
  remove_alpha_ios: true
  min_sdk_android: 26
  adaptive_icon_background: "#00695C"
  adaptive_icon_foreground: "assets/brand/adaptive_foreground.png"
  adaptive_icon_foreground_inset: 0     # mark sudah punya padding sendiri; default 16% akan membuatnya terlalu kecil
  adaptive_icon_monochrome: "assets/brand/adaptive_monochrome.png"

flutter_native_splash:
  color: "#00695C"
  color_dark: "#0C1211"
  image: "assets/brand/splash_mark_1152.png"
  android_12:
    color: "#00695C"
    color_dark: "#0C1211"
    image: "assets/brand/splash_mark_1152.png"
  fullscreen: false
```

Lalu jalankan:
```
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Hapus aset lama yang tidak dipakai lagi: `assets/icon/app_icon.png`, dan hasil generate lama di `android/app/src/main/res/mipmap-*` / `drawable-*` akan ditimpa otomatis oleh perintah di atas.

## 5. Aturan splash (satu splash saja)

```dart
Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // inisialisasi cepat: buka DB, baca preferensi (tema, bahasa, onboarding), muat locale data
  final bootstrap = await AppBootstrap.load();
  runApp(ProviderScope(overrides: bootstrap.overrides, child: const CompoundMeApp()));
  // remove() dipanggil setelah frame pertama router siap (di widget root, addPostFrameCallback)
}
```

- **Hapus `splash_screen.dart` v1 beserta `Future.delayed`.**
- Tidak ada animasi splash di v2.0. Kalau nanti mau animasi, pakai Animated Vector Drawable sesuai spesifikasi Android (432 dp, area terlihat 288 dp), bukan widget Flutter kedua.
- Tema terang/gelap splash mengikuti mode sistem (`color` / `color_dark`). Setelah splash, app memakai tema pilihan pengguna.

## 6. Aset gambar lain

| Aset | Status | Catatan |
|---|---|---|
| Ilustrasi onboarding (3) | **Belum dibuat** | Gaya garis 2 dp, satu warna `teal700` + satu aksen `gold500`, tanpa karakter/wajah. Bisa dibuat sebagai SVG sederhana (pakai `flutter_svg`) atau di-*generate* ulang lewat Claude Design. Subjek: (1) titik-titik tumbuh jadi grafik, (2) jempol + keypad, (3) HP dengan gembok. |
| Ikon empty state | Pakai Phosphor | Tidak perlu aset khusus |
| Screenshot Play Store / LinkedIn | Nanti | Dibuat setelah UI v2.0 jadi (fase media Canva) |

## Sumber

- Android adaptive icons (108 dp layer, safe zone 66 dp, monochrome Android 13+): https://developer.android.com/develop/ui/views/launch/icon_design_adaptive
- Android splash screens (1152/768 px, satu splash lewat SplashScreen API): https://developer.android.com/develop/ui/views/launch/splash-screen
- flutter_launcher_icons: https://pub.dev/packages/flutter_launcher_icons
- flutter_native_splash: https://pub.dev/packages/flutter_native_splash

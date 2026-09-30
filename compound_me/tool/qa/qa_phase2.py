"""Phase 2 checks that need adb rather than an integration test (06 §1).

  python tool/qa/qa_phase2.py resume        # f. force stop at the wallet step
  python tool/qa/qa_phase2.py screens       # g. font 1.3 + dark, every screen
  python tool/qa/qa_phase2.py github-link   # h. the source link's intent
  python tool/qa/qa_phase2.py all

Needs a running emulator with the debug build installed (see README.md).
`resume` and `screens` clear the app's data. Prints PASS/FAIL per check and
exits non-zero when any check fails.
"""
import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from adb_driver import (  # noqa: E402
    back, font_scale, force_stop, fresh_start, hide_keyboard, labels, launch,
    logcat, night, nodes, screenshot, shell, tap, tap_scroll, type_text)

results = []


def check(name, ok, detail=''):
    results.append((name, ok, detail))
    print(('PASS ' if ok else 'FAIL ') + name + (f' ({detail})' if detail else ''))


def onboard_quickly():
    """Language, skip the value pages, a name, the default wallet, no habits."""
    tap('Bahasa Indonesia')
    tap('Lanjut')
    tap('Lewati')
    type_text('Raka')
    hide_keyboard()
    tap('Lanjut')
    tap('Lanjut')
    tap('Lewati dulu', wait=2)
    if 'Mengerti' in labels():
        tap('Mengerti')


def resume():
    """f. Closing the app at the wallet step resumes there with its input."""
    fresh_start()
    tap('Bahasa Indonesia')
    tap('Lanjut')
    tap('Lewati')
    type_text('Sari')
    hide_keyboard()
    tap('Lanjut')
    field = [n for n in nodes() if n['cls'].endswith('EditText')][0]
    x, y = field['center']
    shell(f'input tap {x} {y}')
    shell('input keyevent KEYCODE_MOVE_END')
    for _ in range(len('Tunai')):
        shell('input keyevent KEYCODE_DEL')
    type_text('Dompet Sari')
    tap_scroll('Saldo awal, Rp 0')
    for key in ['2', '5', '000']:
        tap(key, wait=0.4)
    tap('Simpan')

    force_stop()
    launch()
    now = labels()
    check('f. dibuka lagi di langkah dompet', 'Dompet pertama' in now, str(now[:3]))
    check('f. nama dompet masih ada', 'Dompet Sari' in now)
    check('f. saldo awal masih ada', 'Saldo awal, Rp 25.000' in now)
    back()
    check('f. back ke langkah nama, nama tetap', 'Sari' in labels())


def screens(out_dir):
    """g. Every phase 2 screen at font scale 1.3 in dark mode."""
    os.makedirs(out_dir, exist_ok=True)
    shots = []

    def shot(name):
        path = os.path.join(out_dir, f'{name}.png')
        screenshot(path)
        shots.append(path)

    try:
        font_scale(1.3)
        night(True)
        fresh_start()
        tap('Bahasa Indonesia')
        shot('01-bahasa')
        for name in ['02-nilai-1', '03-nilai-2', '04-nilai-3']:
            tap('Lanjut')
            shot(name)
        tap('Lanjut')
        type_text('Raka')
        hide_keyboard()
        shot('05-nama')
        tap('Lanjut')
        shot('06-dompet')
        tap('Lanjut')
        shot('07-kebiasaan')
        tap('Baca 10 halaman', contains=True)
        tap_scroll('Mulai', wait=2)
        shot('08-beranda')
        if 'Mengerti' in labels():
            tap('Mengerti')

        tap('Profil')
        shot('09-profil')
        tap('Dompet', contains=True)
        shot('10-dompet')
        tap('Tunai', contains=True)
        shot('11-editor-dompet')
        field = [n for n in nodes() if n['cls'].endswith('EditText')][0]
        x, y = field['center']
        shell(f'input tap {x} {y}')
        type_text('x')
        hide_keyboard()
        tap('Tutup')
        shot('12-buang-perubahan')
        tap('Buang')
        back()

        tap('Kategori')
        shot('13-kategori-pengeluaran')
        tap('Pemasukan')
        shot('14-kategori-pemasukan')
        tap('Pengeluaran')
        tap('Makanan & minuman')
        shot('15-editor-kategori')
        back()
        back()

        tap('Pengaturan')
        shot('16-pengaturan')
        tap('Hapus semua data')
        shot('17-hapus-semua-1')
        tap('Lanjutkan')
        hide_keyboard()
        shot('18-hapus-semua-2')
        tap('Batal')
        back()

        tap('Tentang CompoundMe', contains=True)
        shot('19-tentang')
        tap('Lisensi open source', wait=2)
        shot('20-lisensi')
        back()
        back()
    finally:
        font_scale(1.0)
        night(False)

    log = logcat()
    overflows = len(re.findall('overflowed', log))
    errors = [l for l in log.splitlines() if ' E flutter' in l or 'EXCEPTION CAUGHT' in l]
    check('g. tanpa overflow (font 1,3, gelap)', overflows == 0, f'{overflows} overflow')
    check('g. tanpa error Flutter di logcat', not errors, '; '.join(errors[:2]))
    check('g. screenshot semua layar', len(shots) == 20, f'{len(shots)} file di {out_dir}')
    restored = shell('settings get system font_scale').strip()
    check('g. pengaturan emulator dikembalikan', restored in ('1.0', '1'), f'font_scale {restored}')


def github_link():
    """h. The source code row sends a VIEW intent for GitHub to Chrome.

    Android 15 redacts URI paths in every log and dumpsys record
    (`dat=https://github.com/...`), so on the device only the scheme, host
    and target can be checked. The exact URL is asserted by
    test/features/settings/presentation/settings_screens_test.dart with a
    fake url_launcher platform.
    """
    force_stop()
    launch()
    if 'Pilih bahasa' in labels() or 'Choose your language' in labels():
        onboard_quickly()
    tap('Profil')
    tap('Tentang CompoundMe', contains=True)
    shell('logcat -c')
    tap('Kode sumber di GitHub', wait=3)
    starts = [l for l in logcat().splitlines()
              if 'START' in l and 'android.intent.action.VIEW' in l]
    line = next((l for l in starts if 'dat=https://github.com/' in l), '')
    check('h. intent VIEW ke https://github.com', bool(line), line.strip()[:170] or str(starts[:1]))
    check('h. intent ditujukan ke Chrome', 'cmp=com.android.chrome/' in line)
    launch(wait=3)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('check', choices=['resume', 'screens', 'github-link', 'all'])
    parser.add_argument('--out', default=os.path.join('build', 'qa', 'phase2'))
    args = parser.parse_args()
    if args.check in ('resume', 'all'):
        resume()
    if args.check in ('screens', 'all'):
        screens(args.out)
    if args.check in ('github-link', 'all'):
        github_link()
    failed = [r for r in results if not r[1]]
    print(f'\n{len(results) - len(failed)}/{len(results)} lulus')
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()

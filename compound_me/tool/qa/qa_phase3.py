"""Phase 3 checks that need adb rather than an integration test (06 §1).

  python tool/qa/qa_phase3.py flow-b        # tap count, Tambah to saved
  python tool/qa/qa_phase3.py hide-balance  # hidden at a real relaunch
  python tool/qa/qa_phase3.py screens       # light + dark, every new screen
  python tool/qa/qa_phase3.py layout        # font 1.3 + dark, no overflow
  python tool/qa/qa_phase3.py all

Needs a running emulator with the debug build installed (see README.md).
Every check starts from cleared app data and seeds it through the UI.
Prints PASS/FAIL per check and exits non-zero when any check fails.
"""
import argparse
import datetime
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from adb_driver import (  # noqa: E402
    back, font_scale, force_stop, fresh_start, hide_keyboard, labels,
    launch, logcat, night, nodes, screenshot, shell, tap, tap_scroll,
    tap_where, type_text)

results = []


def check(name, ok, detail=''):
    results.append((name, ok, detail))
    print(('PASS ' if ok else 'FAIL ') + name + (f' ({detail})' if detail else ''))


def onboard(balance_keys):
    """Language, name, the default wallet with an opening balance."""
    tap('Bahasa Indonesia')
    tap('Lanjut')
    tap('Lewati')
    type_text('Raka')
    hide_keyboard()
    tap('Lanjut')
    tap_scroll('Saldo awal, Rp 0')
    for key in balance_keys:
        tap(key, wait=0.4)
    tap('Simpan')
    tap('Lanjut')
    tap('Lewati dulu', wait=2)
    if 'Mengerti' in labels():
        tap('Mengerti')


def device_today():
    return datetime.date.fromisoformat(shell('date +%Y-%m-%d').strip())


def pick_yesterday():
    """Opens the date row and picks yesterday in the calendar sheet."""
    today = device_today()
    yesterday = today - datetime.timedelta(days=1)
    tap('Tanggal', contains=True)
    if yesterday.month != today.month:
        tap('Bulan sebelumnya')
    # Material day cells read "30, Rabu, 30 September 2026".
    tap_where(lambda l: l.startswith(f'{yesterday.day}, '), f'day {yesterday.day}')


def add(keys, category, note=None, income=False, yesterday=False):
    """One transaction through the form (S-11)."""
    tap('Tambah transaksi', wait=1.5)
    if income:
        tap('Pemasukan')
    for key in keys:
        tap(key, wait=0.3)
    tap(category, wait=0.5)
    if yesterday:
        pick_yesterday()
    if note:
        tap('Catatan', contains=True)
        type_text(note)
        hide_keyboard()
    tap('Simpan', wait=1.5)


def seed():
    """Clean install with Tunai Rp 1.000.000 and four transactions."""
    fresh_start()
    onboard(['1', '000', '000'])
    add(['2', '2', '000'], 'Makanan & minuman', note='kopi susu')
    add(['2', '5', '000'], 'Transportasi')
    add(['4', '8', '000'], 'Belanja', yesterday=True)
    add(['2', '5', '0', '0', '000'], 'Uang saku / gaji', income=True,
        yesterday=True)


def flow_b():
    """a. "kopi Rp 22.000" with the last category already chosen."""
    fresh_start()
    onboard(['1', '000', '000'])
    add(['1', '5', '000'], 'Makanan & minuman')
    taps = 0

    def counted(label, **kwargs):
        nonlocal taps
        tap(label, **kwargs)
        taps += 1

    counted('Tambah transaksi', wait=1.5)
    chip = [n for n in nodes() if n['label'] == 'Makanan & minuman']
    check('a. kategori terakhir sudah terpilih', bool(chip) and chip[0]['selected'])
    for key in ['2', '2', '000']:
        counted(key, wait=0.3)
    counted('Simpan', wait=1.5)
    now = labels()
    check('a. tersimpan dengan snackbar', 'Tersimpan' in now)
    check('a. saldo Beranda ter-update', 'Rp 963.000' in now, str(now[3:6]))
    check('a. jumlah tap Tambah sampai tersimpan', taps == 5,
          f'{taps} tap: Tambah, 2, 2, 000, Simpan')


def settings_toggle():
    tap('Profil')
    tap('Pengaturan')
    tap('Sembunyikan saldo', contains=True)
    state = [n for n in nodes() if 'Sembunyikan saldo' in n['label']]
    back()
    tap('Beranda')
    return bool(state) and state[0]['checked']


def hide_balance():
    """b. The setting hides balances at every real launch; the eye doesn't
    change it."""
    fresh_start()
    onboard(['1', '000', '000'])
    check('b. toggle Pengaturan aktif', settings_toggle())

    force_stop()
    launch()
    now = labels()
    check('b. saldo tertutup saat app dibuka',
          'Saldo disembunyikan' in now and 'Rp 1.000.000' not in now, str(now[3:6]))
    tap('Tampilkan saldo')
    check('b. ikon mata membuka saldo', 'Rp 1.000.000' in labels())
    tap('Profil')
    tap('Dompet', contains=True)
    check('b. Dompet (S-41) ikut terbuka', 'Saldo disembunyikan' not in labels())
    back()
    tap('Pengaturan')
    state = [n for n in nodes() if 'Sembunyikan saldo' in n['label']]
    check('b. pengaturan tidak berubah oleh mata', bool(state) and state[0]['checked'])

    force_stop()
    launch()
    check('b. dibuka lagi: tertutup lagi', 'Saldo disembunyikan' in labels())
    check('b. toggle dimatikan', not settings_toggle())
    force_stop()
    launch()
    now = labels()
    check('b. toggle mati: saldo terlihat saat dibuka',
          'Rp 1.000.000' in now and 'Saldo disembunyikan' not in now)


def walk(shot):
    """Every new phase 3 screen, from Home. Leaves the data unchanged."""
    force_stop()
    launch()
    shot('home')
    tap('Sembunyikan saldo')
    shot('home-hidden')
    tap('Profil')
    tap('Dompet', contains=True)
    shot('wallets-hidden')
    back()
    tap('Beranda')
    tap('Tampilkan saldo')

    tap('Tambah transaksi', wait=1.5)
    shot('add-empty')
    for key in ['2', '2', '000']:
        tap(key, wait=0.3)
    shot('add')
    tap('Tutup')
    shot('add-discard')
    tap('Buang')

    tap('Tambah transaksi', wait=1.5)
    tap('Catatan', contains=True, wait=1.5)
    shot('add-note')
    hide_keyboard()
    tap('Tanggal', contains=True)
    shot('add-date')
    back()
    tap('Tutup')

    tap('kopi susu', contains=True)
    shot('detail')
    tap('Edit', wait=1.5)
    shot('edit')
    tap('Tutup')

    tap('Lihat semua', wait=1.5)
    shot('history')
    tap('Kategori')
    shot('history-category')
    back()
    field = [n for n in nodes() if n['cls'].endswith('EditText')][0]
    x, y = field['center']
    shell(f'input tap {x} {y}')
    type_text('zzz')
    hide_keyboard()
    shot('history-no-match')
    back()


def screens(out_dir, docs_names):
    """c. Light and dark screenshots of every new screen."""
    os.makedirs(out_dir, exist_ok=True)
    shots = []
    seed()
    try:
        for theme in ('light', 'dark'):
            night(theme == 'dark')

            def shot(name):
                file = f'phase-3-{name}-{theme}.png' if docs_names else f'{theme}-{name}.png'
                path = os.path.join(out_dir, file)
                screenshot(path)
                shots.append(path)

            walk(shot)
    finally:
        night(False)
    check('c. screenshot terang & gelap', len(shots) == 26, f'{len(shots)} file di {out_dir}')


def layout(out_dir):
    """d. Font 1.3 in dark mode: no overflow, no Flutter errors."""
    os.makedirs(out_dir, exist_ok=True)
    shots = []

    def shot(name):
        path = os.path.join(out_dir, f'{name}.png')
        screenshot(path)
        shots.append(path)

    try:
        font_scale(1.3)
        night(True)
        seed()
        shell('logcat -c')
        walk(shot)
        log = logcat()
    finally:
        font_scale(1.0)
        night(False)
    overflows = len(re.findall('overflowed', log))
    errors = [l for l in log.splitlines() if ' E flutter' in l or 'EXCEPTION CAUGHT' in l]
    check('d. tanpa overflow (font 1,3, gelap)', overflows == 0, f'{overflows} overflow')
    check('d. tanpa error Flutter di logcat', not errors, '; '.join(errors[:2]))
    check('d. screenshot font 1,3', len(shots) == 13, f'{len(shots)} file di {out_dir}')
    restored = shell('settings get system font_scale').strip()
    check('d. pengaturan emulator dikembalikan', restored in ('1.0', '1'), f'font_scale {restored}')


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('check', choices=['flow-b', 'hide-balance', 'screens', 'layout', 'all'])
    parser.add_argument('--out', default=os.path.join('build', 'qa', 'phase3'))
    parser.add_argument('--docs', action='store_true',
                        help='name screenshots phase-3-<screen>-<theme>.png for docs/v2/screens')
    args = parser.parse_args()
    if args.check in ('flow-b', 'all'):
        flow_b()
    if args.check in ('hide-balance', 'all'):
        hide_balance()
    if args.check in ('screens', 'all'):
        screens(args.out, args.docs)
    if args.check in ('layout', 'all'):
        layout(os.path.join(args.out, 'font-1.3'))
    failed = [r for r in results if not r[1]]
    print(f'\n{len(results) - len(failed)}/{len(results)} lulus')
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()

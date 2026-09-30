"""Phase 3 checks that need adb rather than an integration test (06 §1).

  python tool/qa/qa_phase3.py flow-b        # tap count, Tambah to saved
  python tool/qa/qa_phase3.py hide-balance  # hidden at a real relaunch
  python tool/qa/qa_phase3.py history       # strict month, "Lihat", search
  python tool/qa/qa_phase3.py screens       # light + dark, every new screen
  python tool/qa/qa_phase3.py layout        # 360 dp + font 1.3 + dark
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
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from adb_driver import (  # noqa: E402
    back, font_scale, force_stop, fresh_start, hide_keyboard, labels,
    launch, logcat, night, nodes, screen_width_dp, screenshot, shell, tap, tap_scroll,
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


MONTHS = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember']


def month_label(date):
    return f'{MONTHS[date.month - 1]} {date.year}'


def previous_month(date):
    first = date.replace(day=1)
    return (first - datetime.timedelta(days=1)).replace(day=10)


def pick_date(date):
    """Opens the date row and picks [date] (this month or the one before)."""
    today = device_today()
    tap('Tanggal', contains=True)
    if (date.year, date.month) != (today.year, today.month):
        tap('Bulan sebelumnya')
    # Material day cells read "30, Rabu, 30 September 2026".
    tap_where(lambda l: l.startswith(f'{date.day}, '), f'day {date.day}')


def add(keys, category, note=None, income=False, on=None):
    """One transaction through the form (S-11), dated [on] if given."""
    tap('Tambah transaksi', wait=1.5)
    if income:
        tap('Pemasukan')
    for key in keys:
        tap(key, wait=0.3)
    tap(category, wait=0.5)
    if on:
        pick_date(on)
    if note:
        tap('Catatan', contains=True)
        type_text(note)
        hide_keyboard()
    tap('Simpan', wait=1.5)


def seed():
    """Clean install with Tunai Rp 1.000.000, four transactions of today
    and yesterday and one of last month."""
    today = device_today()
    yesterday = today - datetime.timedelta(days=1)
    fresh_start()
    onboard(['1', '000', '000'])
    add(['4', '5', '000'], 'Transportasi', note='parkir bulan lalu',
        on=previous_month(today))
    add(['2', '2', '000'], 'Makanan & minuman', note='kopi susu')
    add(['2', '5', '000'], 'Transportasi')
    add(['4', '8', '000'], 'Belanja', on=yesterday)
    add(['2', '5', '0', '0', '000'], 'Uang saku / gaji', income=True,
        on=yesterday)


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
    tap_in_sheet('Catatan', contains=True, wait=1.5)
    shot('add-note')
    hide_keyboard()
    tap_in_sheet('Tanggal', contains=True)
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
    tap_scroll(f'Lihat {month_label(previous_month(device_today()))}', wait=1.5)
    shot('history-previous')
    search('parkir')
    shot('history-search')
    search('zzz')
    shot('history-no-match')
    back()


def tap_in_sheet(label, contains=False, wait=1.0):
    """Taps [label] in a sheet's scrolling middle, scrolling it up first
    when a narrow screen or large text pushes it below the fold."""
    for _ in range(4):
        hits = [n for n in nodes() if (label in n['label'] if contains else n['label'] == label)]
        if hits:
            x, y = hits[0]['center']
            shell(f'input tap {x} {y}')
            time.sleep(wait)
            return
        shell('input swipe 400 1000 400 600 400')
        time.sleep(0.8)
    tap(label, contains=contains, wait=wait)


def search(text):
    field = [n for n in nodes() if n['cls'].endswith('EditText')][0]
    x, y = field['center']
    shell(f'input tap {x} {y}')
    shell('input keyevent KEYCODE_MOVE_END')
    for _ in range(12):
        shell('input keyevent KEYCODE_DEL')
    type_text(text)
    hide_keyboard()
    time.sleep(1)


def summary_one_row():
    """Whether Masuk, Keluar and Selisih on screen share one row."""
    cells = [n for n in nodes()
             if n['label'].startswith(('Masuk, ', 'Keluar, ', 'Selisih, '))]
    if len(cells) != 3:
        return False, f'{len(cells)} kolom'
    top = max(n['bounds'][1] for n in cells)
    bottom = min(n['bounds'][3] for n in cells)
    return top < bottom, ' | '.join(n['label'] for n in cells)


def history():
    """e. History: the month is a strict filter; "Lihat" steps back a month;
    a search covers every month."""
    seed()
    today = device_today()
    last = previous_month(today)
    # Belanja Rp 48.000 is dated yesterday, which may be last month.
    yesterday_here = (today - datetime.timedelta(days=1)).month == today.month
    this_out = 47000 + (48000 if yesterday_here else 0)
    last_out = 45000 + (0 if yesterday_here else 48000)

    def rp(value):
        return 'Rp ' + f'{value:,}'.replace(',', '.')

    tap('Lihat semua', wait=1.5)
    now = labels()
    check('e. chip bulan = bulan ini', month_label(today) in now)
    check('e. transaksi bulan lalu tidak ikut', not any('parkir' in l for l in now))
    check('e. ringkasan = bulan ini saja', f'Keluar, {rp(this_out)}' in now,
          next((l for l in now if l.startswith('Keluar, ')), ''))
    tap_scroll(f'Lihat {month_label(last)}', wait=1.5)
    now = labels()
    check('e. "Lihat" mengganti filter ke bulan lalu', month_label(last) in now)
    check('e. bulan lalu tampil sendiri',
          any('parkir' in l for l in now) and not any('kopi susu' in l for l in now))
    check('e. ringkasan bulan lalu', f'Keluar, {rp(last_out)}' in now,
          next((l for l in now if l.startswith('Keluar, ')), ''))
    check('e. tidak ada "Lihat" sebelum bulan tertua',
          not any(l.startswith('Lihat ') and l != 'Lihat semua' for l in now))
    search('kopi')
    now = labels()
    check('e. pencarian: chip "Semua bulan"', 'Semua bulan' in now)
    check('e. pencarian menemukan bulan ini dari bulan lalu',
          any('kopi susu' in l for l in now))
    search('parkir')
    check('e. pencarian lintas bulan', any('parkir' in l for l in labels()))
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
    check('c. screenshot terang & gelap', len(shots) == 30, f'{len(shots)} file di {out_dir}')


def layout(out_dir):
    """d. 360 dp, font 1.3, dark mode: no overflow, no Flutter errors."""
    os.makedirs(out_dir, exist_ok=True)
    shots = []

    def shot(name):
        path = os.path.join(out_dir, f'{name}.png')
        screenshot(path)
        shots.append(path)

    seed()
    try:
        font_scale(1.3)
        night(True)
        screen_width_dp(360)
        shell('logcat -c')
        force_stop()
        launch()
        one_row, detail = summary_one_row()
        check('d. kartu ringkasan satu baris (360 dp, font 1,3)', one_row, detail)
        walk(shot)
        log = logcat()
    finally:
        screen_width_dp(None)
        font_scale(1.0)
        night(False)
    overflows = len(re.findall('overflowed', log))
    errors = [l for l in log.splitlines() if ' E flutter' in l or 'EXCEPTION CAUGHT' in l]
    check('d. tanpa overflow (360 dp, font 1,3, gelap)', overflows == 0, f'{overflows} overflow')
    check('d. tanpa error Flutter di logcat', not errors, '; '.join(errors[:2]))
    check('d. screenshot font 1,3', len(shots) == 15, f'{len(shots)} file di {out_dir}')
    restored = shell('settings get system font_scale').strip()
    check('d. pengaturan emulator dikembalikan', restored in ('1.0', '1'), f'font_scale {restored}')


def main():
    # Amounts carry U+2212 (−), which a Windows console can't print.
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('check', choices=['flow-b', 'hide-balance', 'history', 'screens', 'layout', 'all'])
    parser.add_argument('--out', default=os.path.join('build', 'qa', 'phase3'))
    parser.add_argument('--docs', action='store_true',
                        help='name screenshots phase-3-<screen>-<theme>.png for docs/v2/screens')
    args = parser.parse_args()
    if args.check in ('flow-b', 'all'):
        flow_b()
    if args.check in ('hide-balance', 'all'):
        hide_balance()
    if args.check in ('history', 'all'):
        history()
    if args.check in ('screens', 'all'):
        screens(args.out, args.docs)
    if args.check in ('layout', 'all'):
        layout(os.path.join(args.out, 'font-1.3'))
    failed = [r for r in results if not r[1]]
    print(f'\n{len(results) - len(failed)}/{len(results)} lulus')
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()

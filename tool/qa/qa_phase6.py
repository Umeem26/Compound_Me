"""Phase 6 checks on the emulator with the signed release build (06 §1).

  python tool/qa/qa_phase6.py release      # R8 build: no crash, data kept
  python tool/qa/qa_phase6.py video-flow-b # Flow B recording, 20 s at most
  python tool/qa/qa_phase6.py video-habit  # habit check-in recording

Install the release APK first (`flutter build apk --release`; uninstall a
debug build before, the signing key differs). `release` clears the app's
data and walks onboarding with two habit templates, a transaction, a
check-in, Insights, About, a force stop and a relaunch, then reads logcat
for crashes (missing keep rules, drift, sqlite3). The videos are written to
--out (docs/media).
"""
import argparse
import os
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from adb_driver import (  # noqa: E402
    ADB, back, find, force_stop, fresh_start, labels, launch, logcat, shell,
    tap, tap_scroll, type_text)

results = []

CRASH_MARKERS = (
    'FATAL EXCEPTION', 'ClassNotFoundException',
    'NoSuchMethodError', 'UnsatisfiedLinkError', 'EXCEPTION CAUGHT', 'Unhandled Exception',
)


def check(name, ok, detail=''):
    results.append((name, ok, detail))
    print(('PASS ' if ok else 'FAIL ') + name + (f' ({detail})' if detail else ''))


def onboard_with_habits():
    """Tunai Rp 1.000.000 and two templates: Kopi kekinian (reduce) and
    Olahraga (build)."""
    tap('Bahasa Indonesia')
    tap('Lanjut')
    tap('Lewati')
    type_text('Raka')
    # Back would leave the page instead of closing the keyboard.
    tap('Lanjut')
    tap_scroll('Saldo awal, Rp 0')
    for key in ['1', '000', '000']:
        tap(key, wait=0.4)
    tap('Simpan')
    tap('Lanjut')
    tap('Kopi kekinian\n', contains=True, wait=0.6)
    tap('Olahraga\n', contains=True, wait=0.6)
    tap('Mulai', contains=True, wait=3)
    if 'Mengerti' in labels():
        tap('Mengerti')


def add_expense(keys, category):
    tap('Tambah transaksi', wait=1.5)
    for key in keys:
        tap(key, wait=0.4)
    tap(category, wait=0.6)
    tap('Simpan', wait=1.8)


def release():
    shell('logcat -c')
    fresh_start()
    onboard_with_habits()
    home = labels()
    check('a. onboarding selesai, Beranda tampil', any('Selamat' in l for l in home))

    add_expense(['2', '2', '000'], 'Makanan & minuman')
    check('b. transaksi tersimpan lewat Drift (R8)',
          any('Makanan & minuman, minus dua puluh dua ribu rupiah' in l for l in labels()))

    tap('Kopi kekinian, ', contains=True, wait=2)
    check('c. check-in kebiasaan mencatat pengeluaran',
          any(l.startswith('Kopi kekinian, sudah check-in') for l in labels()))

    tap('Wawasan', wait=1.5)
    check('d. Wawasan tampil (empty state)', '1 dari 7 hari' in labels(), 'hari pertama')
    tap('Profil', wait=1.5)
    tap('Tentang CompoundMe', contains=True, wait=1.5)
    about = labels()
    check('e. Tentang menampilkan versi 2.0.0', any('2.0.0' in l for l in about),
          next((l for l in about if 'Versi' in l or 'Version' in l), ''))
    back()

    force_stop()
    launch()
    after = labels()
    check('f. data tetap ada setelah force stop', 'Selamat' in ' '.join(after), 'saldo ' + next(
        (l for l in after if 'rupiah' in l), '?'))
    log = logcat()
    hits = [m for m in CRASH_MARKERS if m in log]
    check('g. logcat tanpa crash atau error Flutter', not hits, ', '.join(hits))
    pid = shell('pidof com.umem.compound_me').strip()
    check('h. proses masih hidup', bool(pid))


def record(out_dir, name, steps, seconds=18):
    """Runs [steps] while the screen is recorded; saves out_dir/name.mp4."""
    os.makedirs(out_dir, exist_ok=True)
    remote = f'/sdcard/{name}.mp4'
    recorder = subprocess.Popen(
        [ADB, 'shell', 'screenrecord', '--size', '540x1212', '--bit-rate', '3000000',
         '--time-limit', str(seconds), remote])
    time.sleep(1.5)
    started = time.time()
    steps()
    left = seconds - (time.time() - started) + 1
    if left > 0:
        time.sleep(left)
    recorder.wait(timeout=30)
    time.sleep(1)
    local = os.path.join(out_dir, name + '.mp4')
    subprocess.run([ADB, 'pull', remote, local], check=True, capture_output=True)
    shell(f'rm {remote}')
    size = os.path.getsize(local)
    check(f'{name}.mp4 direkam', 0 < size < 5_000_000, f'{size // 1024} KB, {seconds} dtk')


def prepare():
    fresh_start()
    onboard_with_habits()
    force_stop()
    launch(wait=6)


def spot(label, contains=False):
    """Where [label] is on screen right now, for taps during a recording
    (looking it up while recording costs seconds per tap)."""
    return find(label, contains=contains)['center']


def tap_at(point, wait=0.8):
    shell(f'input tap {point[0]} {point[1]}')
    time.sleep(wait)


def video_flow_b(out_dir):
    """Flow B: "kopi Rp 22.000" from the Home tab to the saved snackbar."""
    prepare()
    add = spot('Tambah transaksi')
    tap_at(add, 1.5)
    points = {key: spot(key) for key in ['2', '000']}
    points['category'] = spot('Makanan & minuman')
    points['save'] = spot('Simpan')
    tap('Tutup', wait=1.2)

    def steps():
        time.sleep(1.5)
        tap_at(add, 1.2)
        tap_at(points['2'], 0.7)
        tap_at(points['2'], 0.7)
        tap_at(points['000'], 0.9)
        tap_at(points['category'], 1.0)
        tap_at(points['save'], 3.5)

    record(out_dir, 'flow-b-catat-kopi', steps, seconds=14)


def video_habit(out_dir):
    """Flow C: one-tap check-in on Home, then the habit's detail."""
    prepare()
    chip = spot('Kopi kekinian, ', contains=True)
    tab = spot('Kebiasaan')
    home_tab = spot('Beranda')
    tap_at(tab, 1.5)
    x1, y1, x2, y2 = find('Kopi kekinian', contains=True)['bounds']
    tile = (x1 + 200, y1 + 40)
    tap_at(home_tab, 1.5)

    def steps():
        time.sleep(1.5)
        tap_at(chip, 3.5)
        tap_at(tab, 1.8)
        tap_at(tile, 2.5)
        shell('input swipe 540 1800 540 900 600')
        time.sleep(2.5)

    record(out_dir, 'checkin-kebiasaan', steps, seconds=15)


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('check', choices=['release', 'video-flow-b', 'video-habit'])
    parser.add_argument('--out', default=os.path.join('..', 'docs', 'v2', 'media'))
    args = parser.parse_args()
    if args.check == 'release':
        release()
    if args.check == 'video-flow-b':
        video_flow_b(args.out)
    if args.check == 'video-habit':
        video_habit(args.out)
    failed = [r for r in results if not r[1]]
    print(f'\n{len(results) - len(failed)}/{len(results)} lulus')
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()

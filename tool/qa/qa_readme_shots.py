"""Screenshots for the README (docs/screenshots), taken on the emulator.

  python tool/qa/qa_readme_shots.py

Needs the debug build installed (the sample data row only exists there).
Clears the app's data, onboards with Rp 1.000.000, fills 60 days of sample
data from Settings, then shoots Habits and History (light), and Home,
Habits and Insights in dark mode. The other README images are reused from
docs/process/phase-screens.
"""
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from adb_driver import (  # noqa: E402
    find, force_stop, fresh_start, labels, launch, night, screenshot, shell, tap,
    tap_scroll)
from qa_phase3 import month_label, onboard, previous_month, device_today  # noqa: E402

OUT = os.path.join('docs', 'screenshots')


def shot(name):
    screenshot(os.path.join(OUT, name + '.png'))


def main():
    os.makedirs(OUT, exist_ok=True)
    night(False)
    fresh_start()
    onboard(['1', '000', '000'])
    tap('Profil', wait=1.5)
    tap('Pengaturan', wait=1.5)
    tap_scroll('Isi data contoh', contains=True)
    find('Data contoh terisi', contains=True, tries=60)
    force_stop()
    launch()

    shot('home-light')
    tap('Kebiasaan', wait=2)
    tap('Semua', wait=1)
    shot('habits-light')
    tap('Beranda', wait=1.5)
    tap('Lihat semua', wait=2)
    shot('history-light')
    force_stop()

    night(True)
    launch()
    shot('home-dark')
    tap('Kebiasaan', wait=2)
    tap('Semua', wait=1)
    shot('habits-dark')
    night(False)


if __name__ == '__main__':
    main()

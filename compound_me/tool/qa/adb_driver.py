"""Small adb driver for the on-device QA scripts (06 §1).

Finds elements through `uiautomator dump`, which sees Flutter semantics
labels, so scripts tap by label instead of by pixel.
"""
import html
import os
import re
import shutil
import subprocess
import time

PKG = 'com.umem.compound_me'


def _find_adb():
    if os.environ.get('ADB'):
        return os.environ['ADB']
    exe = 'adb.exe' if os.name == 'nt' else 'adb'
    for root in (os.environ.get('ANDROID_HOME'), os.environ.get('ANDROID_SDK_ROOT'),
                 os.path.join(os.environ.get('LOCALAPPDATA', ''), 'Android', 'Sdk')):
        if root:
            path = os.path.join(root, 'platform-tools', exe)
            if os.path.exists(path):
                return path
    found = shutil.which('adb')
    if not found:
        raise SystemExit('adb not found: set ADB or ANDROID_HOME')
    return found


ADB = _find_adb()
# Git Bash would rewrite /data/... device paths into Windows paths.
ENV = dict(os.environ, MSYS_NO_PATHCONV='1')


def adb(*args, check=True):
    out = subprocess.run([ADB, *args], capture_output=True, env=ENV)
    if check and out.returncode != 0:
        raise RuntimeError(out.stderr.decode(errors='replace'))
    return out.stdout


def shell(cmd):
    return adb('shell', cmd).decode(errors='replace')


def nodes():
    """Visible nodes with their label, class and center."""
    shell('uiautomator dump /sdcard/ui.xml')
    xml = adb('exec-out', 'cat', '/sdcard/ui.xml').decode(errors='replace')
    found = []
    for match in re.finditer(r'<node ([^>]*)>', xml):
        attrs = dict(re.findall(r'([\w-]+)="([^"]*)"', match.group(1)))
        bounds = [int(n) for n in re.findall(r'\d+', attrs.get('bounds', ''))]
        if len(bounds) != 4:
            continue
        x1, y1, x2, y2 = bounds
        label = attrs.get('content-desc') or attrs.get('text') or ''
        found.append({'label': html.unescape(label), 'cls': attrs.get('class', ''),
                      'center': ((x1 + x2) // 2, (y1 + y2) // 2)})
    return found


def labels():
    return [n['label'] for n in nodes() if n['label']]


def find(label, contains=False, index=0, tries=8):
    for _ in range(tries):
        hits = [n for n in nodes() if (label in n['label'] if contains else n['label'] == label)]
        if len(hits) > index:
            return hits[index]
        time.sleep(0.8)
    raise LookupError(f'{label!r} not found; on screen: {labels()}')


def tap(label, contains=False, index=0, wait=1.0):
    x, y = find(label, contains=contains, index=index)['center']
    shell(f'input tap {x} {y}')
    time.sleep(wait)


def keyboard_shown():
    # input_method's own flags go stale; the IME window's visibility doesn't.
    return 'isVisible=true' in shell('dumpsys window InputMethod')


def hide_keyboard():
    if keyboard_shown():
        shell('input keyevent KEYCODE_BACK')
        time.sleep(0.8)


def tap_scroll(label, contains=False, swipes=4, wait=1.0):
    """Closes the keyboard, then scrolls down until [label] shows."""
    hide_keyboard()
    for _ in range(swipes):
        hits = [n for n in nodes() if (label in n['label'] if contains else n['label'] == label)]
        if hits:
            x, y = hits[0]['center']
            shell(f'input tap {x} {y}')
            time.sleep(wait)
            return
        shell('input swipe 540 1700 540 900 400')
        time.sleep(0.8)
    tap(label, contains=contains, wait=wait)


def type_text(text):
    shell('input text ' + text.replace(' ', '%s'))
    time.sleep(0.6)


def back(wait=1.2):
    shell('input keyevent KEYCODE_BACK')
    time.sleep(wait)


def screenshot(path, wait=0.8):
    time.sleep(wait)
    with open(path, 'wb') as file:
        file.write(adb('exec-out', 'screencap', '-p'))


def launch(wait=10):
    shell('logcat -c')
    shell(f'am start -n {PKG}/.MainActivity')
    time.sleep(wait)


def force_stop():
    shell(f'am force-stop {PKG}')


def fresh_start():
    force_stop()
    shell(f'pm clear {PKG}')
    launch()


def night(on):
    shell('cmd uimode night ' + ('yes' if on else 'no'))
    time.sleep(1.5)


def font_scale(scale):
    shell(f'settings put system font_scale {scale}')
    time.sleep(1)


def logcat():
    return shell('logcat -d')

"""Builds docs/social-preview.png (1280x640) for the GitHub social preview:
logo, name, tagline and three screens on flat teal. Run from the repo root:

  python tool/generate_social_preview.py
"""
from PIL import Image, ImageDraw, ImageFont

TEAL700 = (0, 105, 92)
TEAL900 = (0, 51, 46)
GOLD500 = (224, 169, 27)
WHITE = (255, 255, 255)
TEAL100 = (204, 229, 225)

W, H = 1280, 640
bold = 'assets/fonts/PlusJakartaSans-Bold.ttf'
regular = 'assets/fonts/PlusJakartaSans-Medium.ttf'

canvas = Image.new('RGB', (W, H), TEAL700)
draw = ImageDraw.Draw(canvas)
# A darker band on the right holds the screens.
draw.rectangle([(700, 0), (W, H)], fill=TEAL900)
draw.rectangle([(64, 330), (64 + 96, 330 + 6)], fill=GOLD500)

icon = Image.open('assets/brand/app_icon_1024.png').convert('RGBA').resize((112, 112))
mask = Image.new('L', (112, 112), 0)
ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (111, 111)], radius=26, fill=255)
canvas.paste(icon, (64, 96), mask)

draw.text((64, 232), 'CompoundMe', font=ImageFont.truetype(bold, 76), fill=WHITE)
tag = ImageFont.truetype(regular, 32)
draw.text((64, 360), 'See what your small habits', font=tag, fill=TEAL100)
draw.text((64, 404), 'really cost.', font=tag, fill=TEAL100)
small = ImageFont.truetype(regular, 24)
draw.text((64, 540), 'Offline finance + habit tracker  |  Flutter, Android', font=small, fill=GOLD500)

shots = ['docs/screenshots/01-home-light.png', 'docs/screenshots/03-habits-light.png',
         'docs/screenshots/04-insights-light.png']
sw = 170
x = 722
for i, path in enumerate(shots):
    im = Image.open(path).convert('RGB')
    sh = round(im.height * sw / im.width)
    im = im.resize((sw, sh), Image.Resampling.LANCZOS)
    top = 90 + (i % 2) * 70
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).rounded_rectangle([(0, 0), (im.width - 1, im.height - 1)], radius=22, fill=255)
    canvas.paste(im, (x + i * (sw + 14), top), m)

canvas.save('docs/social-preview.png', optimize=True)
print('docs/social-preview.png')

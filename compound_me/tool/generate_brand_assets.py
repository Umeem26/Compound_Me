"""Generate CompoundMe v2 brand assets (app icon, adaptive layers, splash, notification icon).

Mark: three dots growing by x1.5 each step (50 -> 75 -> 112.5), from faint teal to white to gold.
Story: small habits compound into a result that matters.

Requires: pip install cairosvg pillow
Run from repo root: python tool/generate_brand_assets.py
"""
import os
import cairosvg

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "brand")
TEAL700 = "#00695C"
TEAL200 = "#99CBC3"
OFFWHITE = "#F7F9F8"
GOLD500 = "#E0A91B"
BG_DARK = "#0C1211"

# Dot geometry on a 1024 canvas, relative to centre. Radii grow x1.5 each step.
DOTS = [(-170, 150, 50.0), (-45, 40, 75.0), (125, -110, 112.5)]
MARK_SCALE = 1.08  # farthest edge ~301px from centre -> fits the 66/108 adaptive safe zone (313px)


def mark(colors, canvas=1024, scale=MARK_SCALE, opacities=(1, 1, 1)):
    c = canvas / 2
    k = canvas / 1024 * scale
    return "".join(
        f'<circle cx="{c + x * k:.2f}" cy="{c + y * k:.2f}" r="{r * k:.2f}" fill="{col}" fill-opacity="{op}"/>'
        for (x, y, r), col, op in zip(DOTS, colors, opacities)
    )


def svg(inner, canvas=1024, bg=None):
    b = f'<rect width="{canvas}" height="{canvas}" fill="{bg}"/>' if bg else ""
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{canvas}" height="{canvas}" '
            f'viewBox="0 0 {canvas} {canvas}">{b}{inner}</svg>')


def write(name, content, px):
    with open(os.path.join(OUT, name.replace(".png", ".svg")), "w") as f:
        f.write(content)
    cairosvg.svg2png(bytestring=content.encode(), write_to=os.path.join(OUT, name),
                     output_width=px, output_height=px)


def main():
    os.makedirs(OUT, exist_ok=True)
    colors = [TEAL200, OFFWHITE, GOLD500]
    # 1. Full icon (iOS + legacy Android): opaque teal background.
    write("app_icon_1024.png", svg(mark(colors), bg=TEAL700), 1024)
    # 2. Adaptive foreground: transparent, mark already inside safe zone -> use inset 0.
    write("adaptive_foreground.png", svg(mark(colors)), 1024)
    # 3. Adaptive monochrome (Android 13+ themed icons): single colour, alpha keeps the progression.
    write("adaptive_monochrome.png", svg(mark(["#FFFFFF"] * 3, opacities=(0.45, 0.75, 1))), 1024)
    # 4. Android 12+ splash icon without icon background: 1152 canvas, must fit a 768px circle.
    write("splash_mark_1152.png", svg(mark(colors, canvas=1152), canvas=1152), 1152)
    # 5. Notification small icon (white + alpha only), for reminders in v2.1.
    write("ic_stat_mark_96.png", svg(mark(["#FFFFFF"] * 3, canvas=96, scale=1.45, opacities=(0.55, 0.8, 1)), canvas=96), 96)
    print("Brand assets written to", os.path.abspath(OUT))


if __name__ == "__main__":
    main()

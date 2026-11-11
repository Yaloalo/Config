#!/usr/bin/env python3
"""Render the deepfield splash's static images (2x, scaled down at boot)."""
import subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = Path(__file__).resolve().parent
MUTED = (129, 144, 165, 255)   # Theme.muted in quickshell/blackhole
WHITE = (247, 251, 255, 255)


def font(size):
    path = subprocess.run(["fc-match", "-f", "%{file}", "JetBrainsMono Nerd Font"],
                          capture_output=True, text=True, check=True).stdout
    return ImageFont.truetype(path, size)


def text(name, s, size, color, spacing):
    f = font(size)
    widths = [f.getbbox(ch)[2] for ch in s]
    w = int(sum(widths) + spacing * (len(s) - 1)) + 8
    asc, desc = f.getmetrics()
    img = Image.new("RGBA", (w, asc + desc + 8), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    x = 4
    for ch, cw in zip(s, widths):
        d.text((x, 4), ch, font=f, fill=color)
        x += cw + spacing
    img.save(OUT / name)


def star(name, radius):
    size = int(radius * 6) + 4
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = size / 2
    d.ellipse((c - radius, c - radius, c + radius, c + radius), fill=(255, 255, 255, 255))
    img = img.filter(ImageFilter.GaussianBlur(radius * 0.35))
    img.save(OUT / name)


def pixel(name, rgba):
    Image.new("RGBA", (1, 1), rgba).save(OUT / name)


text("title.png", "DEEP FIELD", 30, WHITE, 18)
text("stage-boot.png", "DRIFTING IN", 20, MUTED, 10)
text("stage-halt.png", "POWERING DOWN", 20, MUTED, 10)
text("stage-reboot.png", "RESTARTING", 20, MUTED, 10)
text("pass.png", "PASSPHRASE", 20, MUTED, 10)
for i, r in enumerate((1.4, 2.2, 3.2)):
    star(f"star-{i}.png", r)
pixel("px-white.png", WHITE)
pixel("px-line.png", (80, 80, 80, 255))
pixel("px-glass.png", (0, 0, 0, 170))

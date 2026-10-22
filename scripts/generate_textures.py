#!/usr/bin/env python3
"""
generate_textures.py
Tự động tạo placeholder textures cho Naruto mod (16x16 PNG)
Chạy: python generate_textures.py
"""

import os
import struct
import zlib

TEXTURE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mods", "naruto", "textures")
os.makedirs(TEXTURE_DIR, exist_ok=True)

def make_png(width: int, height: int, pixels: list[tuple[int,int,int,int]]) -> bytes:
    """Tạo file PNG tối giản từ danh sách pixel RGBA."""
    def write_chunk(chunk_type: bytes, data: bytes) -> bytes:
        chunk_len = len(data)
        chunk_data = chunk_type + data
        crc = zlib.crc32(chunk_data) & 0xFFFFFFFF
        return struct.pack(">I", chunk_len) + chunk_data + struct.pack(">I", crc)

    # PNG header
    sig = b'\x89PNG\r\n\x1a\n'

    # IHDR
    ihdr_data = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    # Color type 2 = RGB (no alpha for simplicity in most), but let's do RGBA (color type 6)
    ihdr_data = struct.pack(">II", width, height) + bytes([8, 6, 0, 0, 0])
    ihdr = write_chunk(b'IHDR', ihdr_data)

    # IDAT - image data
    raw_rows = b''
    for y in range(height):
        raw_rows += b'\x00'  # filter type None
        for x in range(width):
            idx = y * width + x
            if idx < len(pixels):
                r, g, b, a = pixels[idx]
            else:
                r, g, b, a = 0, 0, 0, 0
            raw_rows += bytes([r, g, b, a])

    compressed = zlib.compress(raw_rows, 9)
    idat = write_chunk(b'IDAT', compressed)

    # IEND
    iend = write_chunk(b'IEND', b'')

    return sig + ihdr + idat + iend


def solid(w, h, r, g, b, a=255):
    return [(r, g, b, a)] * (w * h)


def gradient_v(w, h, top, bottom):
    pixels = []
    for y in range(h):
        t = y / max(h-1, 1)
        pix = tuple(int(top[i] + (bottom[i]-top[i])*t) for i in range(4))
        pixels.extend([pix] * w)
    return pixels


def cross_pattern(w, h, fg, bg):
    """Hình chữ thập (shuriken đơn giản)"""
    pixels = []
    cx, cy = w//2, h//2
    for y in range(h):
        for x in range(w):
            if x == cx or y == cy or (abs(x-cx)==abs(y-cy) and abs(x-cx)<w//4):
                pixels.append(fg)
            else:
                pixels.append(bg)
    return pixels


def circle_pattern(w, h, fg, bg):
    pixels = []
    cx, cy = w/2, h/2
    r = min(w,h)/2 - 1
    for y in range(h):
        for x in range(w):
            if (x-cx)**2 + (y-cy)**2 <= r**2:
                pixels.append(fg)
            else:
                pixels.append(bg)
    return pixels


# ── Định nghĩa textures ──────────────────────────────────────
TEXTURES = {
    # Vũ khí
    "naruto_kunai.png":         solid(16, 16, 150, 150, 160),      # Xám kim loại
    "naruto_shuriken.png":      cross_pattern(16, 16, (180,180,190,255), (0,0,0,0)),
    "naruto_katana.png":        solid(16, 16, 200, 200, 210),
    "naruto_kusanagi.png":      solid(16, 16, 100, 180, 255),      # Xanh sét

    # Jutsu
    "naruto_rasengan.png":      circle_pattern(32, 32, (80,160,255,220), (0,0,0,0)),
    "naruto_fireball.png":      circle_pattern(32, 32, (255,100,20,220), (0,0,0,0)),
    "naruto_chidori.png":       circle_pattern(32, 32, (150,150,255,220), (0,0,0,0)),
    "naruto_wind_blade.png":    solid(32, 8, 200, 255, 200, 180),
    "naruto_water_dragon.png":  solid(32, 32, 20, 120, 220, 200),

    # Particles
    "naruto_chakra_particle.png":    circle_pattern(8, 8, (80,180,255,200), (0,0,0,0)),
    "naruto_lightning_particle.png": solid(4, 16, 220, 220, 255, 230),
    "naruto_smoke_particle.png":     circle_pattern(8, 8, (100,100,100,150), (0,0,0,0)),
    "naruto_poison_particle.png":    circle_pattern(8, 8, (180,0,220,180), (0,0,0,0)),
    "naruto_wind_particle.png":      circle_pattern(8, 8, (200,255,200,150), (0,0,0,0)),
    "naruto_rasengan_explosion.png": circle_pattern(16, 16, (100,180,255,200), (0,0,0,0)),

    # HUD
    "naruto_chakra_icon.png":    circle_pattern(24, 24, (0,180,255,255), (0,0,60,180)),
    "naruto_chakra_icon_bg.png": circle_pattern(24, 24, (0,60,100,100), (0,0,0,0)),

    # Nhân vật (sprite placeholder)
    "naruto_clone_front.png":    gradient_v(16, 32, (255,140,0,255), (30,30,150,255)),
    "naruto_clone_back.png":     gradient_v(16, 32, (220,120,0,255), (20,20,120,255)),

    # Boss
    "naruto_orochimaru.png":     gradient_v(24, 48, (80,0,80,255), (20,0,40,255)),
    "naruto_pain.png":           gradient_v(24, 48, (60,0,120,255), (20,0,60,255)),

    # Items
    "naruto_ramen.png":          solid(16, 16, 220, 160, 60),       # Cam nâu
    "naruto_soldier_pill.png":   circle_pattern(16, 16, (0,220,220,255), (0,0,0,0)),
    "naruto_sake.png":           solid(16, 16, 240, 240, 255),
    "naruto_ration_bar.png":     solid(16, 16, 180, 130, 60),
    "naruto_hokage_cloak.png":   solid(16, 16, 220, 40, 20),
    "naruto_headband_leaf.png":  solid(16, 8, 80, 160, 80),
    "naruto_headband_sand.png":  solid(16, 8, 200, 160, 60),

    # Scrolls
    "naruto_scroll_fire.png":    gradient_v(16, 16, (255,80,0,255), (200,200,200,255)),
    "naruto_scroll_wind.png":    gradient_v(16, 16, (100,255,100,255), (200,200,200,255)),

    # Jutsu scrolls (inventory icons)
    "naruto_jutsu_rasengan.png": circle_pattern(16, 16, (80,160,255,255), (30,30,30,255)),
    "naruto_jutsu_fire.png":     circle_pattern(16, 16, (255,80,0,255), (30,30,30,255)),
    "naruto_jutsu_lightning.png":circle_pattern(16, 16, (180,180,255,255), (20,20,40,255)),
    "naruto_jutsu_clone.png":    solid(16, 16, 240, 220, 80, 255),
    "naruto_jutsu_wind.png":     circle_pattern(16, 16, (180,255,180,255), (20,40,20,255)),
    "naruto_jutsu_water.png":    circle_pattern(16, 16, (0,120,255,255), (0,20,60,255)),
}


def main():
    count = 0
    for filename, pixels in TEXTURES.items():
        # Xác định kích thước từ số pixels
        n = len(pixels)
        # Tìm w, h phù hợp (ưu tiên hình vuông hoặc đã biết)
        if "lightning_particle" in filename:
            w, h = 4, 16
        elif "wind_blade" in filename:
            w, h = 32, 8
        elif "clone" in filename or "orochimaru" in filename or "pain" in filename:
            # Sprite cao hơn
            if "clone" in filename:
                w, h = 16, 32
            else:
                w, h = 24, 48
        elif "chakra_icon" in filename:
            w, h = 24, 24
        elif "rasengan.png" in filename or "fireball" in filename or \
             "chidori" in filename or "water_dragon" in filename:
            w, h = 32, 32
        elif "headband" in filename:
            w, h = 16, 8
        else:
            w, h = 16, 16

        # Pad pixels nếu cần
        needed = w * h
        if len(pixels) < needed:
            pixels = pixels + [(0,0,0,0)] * (needed - len(pixels))
        pixels = pixels[:needed]

        path = os.path.join(TEXTURE_DIR, filename)
        with open(path, 'wb') as f:
            f.write(make_png(w, h, pixels))
        count += 1

    print(f"[OK] Da tao {count} placeholder textures trong {TEXTURE_DIR}")
    print("     Thay the bang anh thuc te de game dep hon!")


if __name__ == "__main__":
    main()

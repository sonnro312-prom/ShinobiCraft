# ============================================================
# 🍥 ShinobiCraft - Minecraft Naruto cho iOS
# ============================================================

## Giới thiệu

**ShinobiCraft** là game voxel sandbox phong cách Naruto, dựa trên engine Luanti (Minetest), chạy trên iPhone thông qua sideloading miễn phí. Chơi chung với bạn bè từ xa qua Internet, có voice chat tích hợp, hoàn toàn tiếng Việt.

## Tính năng

- 🍥 **Naruto Mod đầy đủ**: Chakra, Jutsu (Rasengan, Chidori, Phân Thân, Hỏa Cầu, Phong Nhẫn, Thủy Long), Vũ khí ninja, Boss (Orochimaru, Pain), Làng Ninja
- 🎤 **Voice Chat**: Nói chuyện với đồng đội trong game (LiveKit)
- 🏷️ **Nametag**: Hiển thị tên + nhân vật + cấp bậc trên đầu người chơi
- 🇻🇳 **Tiếng Việt**: Toàn bộ UI, item, tutorial tiếng Việt
- 📱 **iOS**: Cài miễn phí không qua App Store (SideStore)
- 🌐 **Multiplayer**: Chơi chung từ xa qua Internet

## Cấu trúc dự án

```
ShinobiCraft/
├── luanti-ios/          # Luanti engine fork cho iOS
│   └── .github/
│       └── workflows/
│           └── build-ios.yml    ← GitHub Actions build IPA
├── mods/
│   └── naruto/          # Naruto Mod (Lua)
│       ├── chakra.lua   # Hệ thống chakra
│       ├── hud.lua      # HUD + lệnh chat
│       ├── nametag.lua  # Tên trên đầu
│       ├── tutorial.lua # Hướng dẫn người mới
│       ├── jutsu/       # Các jutsu
│       ├── weapons/     # Vũ khí ninja
│       ├── items/       # Vật phẩm tiêu thụ
│       ├── bosses/      # Boss fights
│       ├── villages/    # Làng ninja
│       ├── textures/    # Textures (36 file)
│       └── locale/      # Tiếng Việt
├── server/
│   ├── minetest.conf    # Config game server
│   ├── setup-server.sh  # Script cài server tự động
│   └── docker-compose.yml
├── voice/
│   ├── livekit.yaml     # LiveKit voice server config
│   └── token-service/   # Token API (Node.js)
└── scripts/
    └── generate_textures.py  # Tạo textures
```

## Hướng dẫn nhanh

### 1. Build IPA (chỉ cần làm 1 lần)

```bash
# Tạo GitHub repo → Push code → GitHub Actions tự build
cd luanti-ios
git push origin main
# → Tab Actions trên GitHub → Tải ShinobiCraft.ipa khi xong
```

### 2. Cài lên iPhone

```
1. Cài SideStore (xem docs/install-ios.md)
2. Import ShinobiCraft.ipa vào SideStore
3. Mở game!
```

### 3. Setup Server

```bash
# Trên Ubuntu (Oracle Cloud Free Tier)
chmod +x server/setup-server.sh
./server/setup-server.sh
```

### 4. Chơi chung

```
Multiplayer → nhập IP server → Join → /chonninja naruto → Chơi!
```

## Lệnh trong game

| Lệnh | Mô tả |
|---|---|
| `/chonninja naruto` | Chọn nhân vật |
| `/info` | Xem thông tin ninja |
| `/huongdan` | Xem lại hướng dẫn |
| `/help_vn` | Danh sách lệnh |
| `/xayland konoha` | Xây Làng Lá (server) |
| `/bossspawn orochimaru` | Spawn boss (server) |

## Jutsu có sẵn

| Jutsu | Chakra | Mô tả |
|---|---|---|
| Rasengan | 30 | Cầu chakra xoáy, AoE khi nổ |
| Chidori | 35 | Tia sét, xuyên nhiều kẻ địch |
| Hỏa Cầu | 20 | Quả cầu lửa, AoE khi nổ |
| Phân Thân | 40 | 3 phân thân tự tấn công (30s) |
| Phong Nhẫn | 18 | Lưỡi gió nhanh, knockback |
| Thủy Long | 25 | Rồng nước to, knockback cao |

## Boss

| Boss | HP | Skill đặc biệt | Loot |
|---|---|---|---|
| Orochimaru | 200 | Nọc độc, tốc độ phase 2 | Kusanagi, Jutsu |
| Pain | 350 | Shinra Tensei AoE mọi người | Rasengan, Chidori, thăng Hokage |

## Credits

- Engine: [Luanti/Minetest](https://luanti.org) (LGPL)
- Voice: [LiveKit](https://livekit.io) (Apache 2.0)
- Mod: ShinobiCraft Team

---
*Chỉ sử dụng cá nhân. Naruto © Masashi Kishimoto / Shueisha.*

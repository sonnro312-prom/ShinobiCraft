#!/bin/bash
# ============================================================
# setup-server.sh - Script tự động cài server ShinobiCraft
# Chạy trên Ubuntu 22.04 (Oracle Cloud Free Tier)
# Cách dùng: chmod +x setup-server.sh && ./setup-server.sh
# ============================================================

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${GREEN}🍥 Bắt đầu cài đặt ShinobiCraft Server...${NC}"

# ── 1. Cập nhật hệ thống ─────────────────────────────────────
echo -e "${YELLOW}[1/8] Cập nhật Ubuntu...${NC}"
sudo apt-get update -y
sudo apt-get upgrade -y

# ── 2. Cài dependencies ──────────────────────────────────────
echo -e "${YELLOW}[2/8] Cài dependencies...${NC}"
sudo apt-get install -y \
    build-essential cmake git \
    libsqlite3-dev liblua5.1-dev libluajit-5.1-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libvorbis-dev libogg-dev \
    libcurl4-openssl-dev libzstd-dev \
    libgmp-dev libjsoncpp-dev \
    ufw docker.io docker-compose

# ── 3. Cài Luanti (Minetest) server ─────────────────────────
echo -e "${YELLOW}[3/8] Cài Luanti Server...${NC}"
if ! command -v minetest &> /dev/null; then
    sudo add-apt-repository -y ppa:minetestdevs/stable
    sudo apt-get update -y
    sudo apt-get install -y minetest minetest-server
fi

# ── 4. Tạo thư mục game ──────────────────────────────────────
echo -e "${YELLOW}[4/8] Tạo cấu trúc thư mục...${NC}"
GAME_DIR="$HOME/.minetest"
mkdir -p "$GAME_DIR/worlds/ShinobiWorld"
mkdir -p "$GAME_DIR/worlds/ShinobiWorld/worldmods"

# ── 5. Copy mod Naruto ───────────────────────────────────────
echo -e "${YELLOW}[5/8] Cài Naruto Mod...${NC}"
if [ -d "./mods/naruto" ]; then
    cp -r ./mods/naruto "$GAME_DIR/worlds/ShinobiWorld/worldmods/"
    echo -e "${GREEN}✅ Naruto mod đã cài!${NC}"
else
    echo -e "${RED}⚠️  Không tìm thấy ./mods/naruto - Hãy chạy từ thư mục dự án${NC}"
fi

# ── 6. Copy cấu hình server ──────────────────────────────────
echo -e "${YELLOW}[6/8] Cấu hình server...${NC}"
cp ./server/minetest.conf "$GAME_DIR/worlds/ShinobiWorld/"

# Tạo world.mt
cat > "$GAME_DIR/worlds/ShinobiWorld/world.mt" << 'EOF'
enable_damage = true
creative_mode = false
auth_backend = sqlite3
player_backend = sqlite3
gameid = minetest
backend = sqlite3
EOF

# ── 7. Mở firewall ───────────────────────────────────────────
echo -e "${YELLOW}[7/8] Cấu hình firewall...${NC}"
sudo ufw allow 30000/udp comment 'Luanti Game Server'
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 7880/tcp comment 'LiveKit Voice'
sudo ufw allow 7882/udp comment 'LiveKit Voice UDP'
sudo ufw --force enable

# ── 8. Tạo systemd service (auto-start) ──────────────────────
echo -e "${YELLOW}[8/8] Tạo service tự khởi động...${NC}"
sudo bash -c "cat > /etc/systemd/system/shinobicraft.service" << SYSTEMD
[Unit]
Description=ShinobiCraft Luanti Game Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$GAME_DIR
ExecStart=/usr/bin/minetestserver \
    --world $GAME_DIR/worlds/ShinobiWorld \
    --config $GAME_DIR/worlds/ShinobiWorld/minetest.conf \
    --logfile $GAME_DIR/debug.log
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SYSTEMD

sudo systemctl daemon-reload
sudo systemctl enable shinobicraft
sudo systemctl start shinobicraft

# ── 9. Cài LiveKit Voice Server (Docker) ─────────────────────
echo -e "${YELLOW}[Bonus] Cài LiveKit Voice Chat Server...${NC}"
if command -v docker &> /dev/null; then
    docker pull livekit/livekit-server:latest
    # Tạo config LiveKit
    cat > "$HOME/livekit.yaml" << 'LIVEKIT'
port: 7880
bind_addresses:
    - ""
rtc:
    port_range_start: 50000
    port_range_end:   60000
    use_external_ip:  true
turn:
    enabled: false
keys:
    APIKey_ShinobiCraft: Secret_ShinobiCraft_2026
logging:
    level: info
LIVEKIT

    # Tạo docker-compose cho LiveKit
    cat > "$HOME/docker-compose.yml" << 'COMPOSE'
version: '3'
services:
  livekit:
    image: livekit/livekit-server:latest
    ports:
      - "7880:7880"
      - "7882:7882/udp"
      - "50000-60000:50000-60000/udp"
    volumes:
      - ./livekit.yaml:/livekit.yaml
    command: --config /livekit.yaml
    restart: unless-stopped
COMPOSE

    cd "$HOME" && docker-compose up -d
    echo -e "${GREEN}✅ LiveKit Voice Server đang chạy!${NC}"
fi

# ── Kết quả ──────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   🍥 ShinobiCraft Server Ready!      ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════╣${NC}"
echo -e "${GREEN}║ Game Server: Port 30000 (UDP)        ║${NC}"
echo -e "${GREEN}║ Voice Chat:  Port 7880 (TCP)         ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════╣${NC}"
echo -e "${GREEN}║ Lệnh hữu ích:                        ║${NC}"
echo -e "${GREEN}║  sudo systemctl status shinobicraft  ║${NC}"
echo -e "${GREEN}║  sudo systemctl restart shinobicraft ║${NC}"
echo -e "${GREEN}║  tail -f ~/.minetest/debug.log       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📱 Cho bạn bè kết nối: Mở game → Multiplayer → nhập IP này${NC}"
curl -s https://api.ipify.org && echo ""

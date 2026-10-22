// ============================================================
// token-service/server.js
// Tạo LiveKit token cho người chơi khi họ join game
// Node.js + Express
// ============================================================

const express    = require('express');
const { AccessToken } = require('livekit-server-sdk');

const app  = express();
const PORT = process.env.PORT || 8080;

const API_KEY    = process.env.LIVEKIT_API_KEY    || 'APIKey_ShinobiCraft';
const API_SECRET = process.env.LIVEKIT_API_SECRET || 'Secret_ShinobiCraft_2026';

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'ShinobiCraft Token Service' });
});

// Tạo token cho người chơi
// GET /token?playerName=NarutoFan123&room=ShinobiWorld
app.get('/token', async (req, res) => {
    const { playerName, room } = req.query;

    if (!playerName || !room) {
        return res.status(400).json({
            error: 'Thiếu playerName hoặc room',
            example: '/token?playerName=NarutoFan&room=ShinobiWorld'
        });
    }

    try {
        // Tạo AccessToken với quyền publish audio
        const token = new AccessToken(API_KEY, API_SECRET, {
            identity: playerName,
            name:     playerName,
            ttl:      '24h',  // Token có giá trị 24 giờ
        });

        token.addGrant({
            room:          room,
            roomJoin:      true,
            canPublish:    true,   // Được phép bật mic
            canSubscribe:  true,   // Được phép nghe người khác
            canPublishData: true,
        });

        const jwt = await token.toJwt();

        res.json({
            token:      jwt,
            playerName: playerName,
            room:       room,
            expires_in: '24h',
        });

    } catch (err) {
        console.error('Token error:', err);
        res.status(500).json({ error: 'Không thể tạo token: ' + err.message });
    }
});

// Danh sách phòng đang hoạt động
app.get('/rooms', async (req, res) => {
    res.json({
        rooms: ['ShinobiWorld'],
        note: 'Kết nối game trước, voice chat tự động join cùng phòng'
    });
});

app.listen(PORT, () => {
    console.log(`🎤 ShinobiCraft Token Service chạy tại port ${PORT}`);
    console.log(`   GET /token?playerName=<tên>&room=ShinobiWorld`);
});

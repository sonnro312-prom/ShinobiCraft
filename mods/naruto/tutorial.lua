-- ============================================================
-- tutorial.lua - Hướng dẫn cho người mới (Tiếng Việt)
-- ============================================================

local tutorial_steps = {
    {delay=2,  msg="🍥 Chào mừng đến ShinobiCraft! Hãy bắt đầu hành trình ninja!"},
    {delay=6,  msg="💡 Dùng ngón tay chạm để di chuyển. Thanh trái = đi, phải = nhìn."},
    {delay=12, msg="💡 Chạm và giữ vào khối để ĐÀO. Chạm vào inventory để XEM đồ."},
    {delay=20, msg="⚡ Thanh XANH bên dưới HP là CHAKRA - năng lượng để dùng Jutsu!"},
    {delay=28, msg="🍃 Gõ /chonninja naruto để chọn nhân vật (naruto/sasuke/sakura/kakashi...)"},
    {delay=36, msg="⚔️  Craft Kunai: đặt 1 thanh sắt + 1 gậy = 8 Kunai phi tiêu!"},
    {delay=44, msg="🔥 Craft cuộn thuật: giấy + than/lá để học Jutsu!"},
    {delay=52, msg="📜 Dùng cuộn thuật (click phải) để học Jutsu, rồi tìm item trong craft."},
    {delay=60, msg="🎤 Bấm nút MIC (góc phải màn hình) để nói chuyện với đồng đội!"},
    {delay=68, msg="💀 Boss xuất hiện ngẫu nhiên! Hợp tác để đánh bại chúng!"},
    {delay=76, msg="📋 Gõ /info để xem thông tin ninja. /help để xem tất cả lệnh."},
    {delay=84, msg="🏆 Tiêu diệt Boss để nhận loot hiếm và tăng cấp bậc ninja!"},
    {delay=92, msg="✅ Hướng dẫn hoàn tất! Chúc bạn vui vẻ - Dattebayo! 🍥"},
}

-- Biến theo dõi người đã xem tutorial
local seen_tutorial = {}

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if seen_tutorial[name] then return end
    seen_tutorial[name] = true

    -- Hiển thị từng bước với delay
    for _, step in ipairs(tutorial_steps) do
        minetest.after(step.delay, function()
            if minetest.get_player_by_name(name) then
                minetest.chat_send_player(name,
                    minetest.colorize("#FFD700", "[Hướng Dẫn] ") .. step.msg)
            end
        end)
    end
end)

-- Command xem lại tutorial
minetest.register_chatcommand("huongdan", {
    description = "Xem lại hướng dẫn cho người mới",
    func = function(name, param)
        seen_tutorial[name] = nil
        local player = minetest.get_player_by_name(name)
        if player then
            minetest.registered_on_joinplayers[#minetest.registered_on_joinplayers](player)
        end
        return true, "✅ Bắt đầu lại hướng dẫn!"
    end
})

-- Help command tiếng Việt
minetest.register_chatcommand("help_vn", {
    description = "Danh sách lệnh tiếng Việt",
    func = function(name, param)
        local help = {
            "=== 🍥 LỆNH SHINOBICRAFT ===",
            "/chonninja <tên> - Chọn nhân vật (naruto/sasuke/sakura/...)",
            "/info             - Xem thông tin ninja của bạn",
            "/huongdan         - Xem lại hướng dẫn",
            "/bossspawn <tên>  - Spawn Boss (cần quyền server)",
            "/jutsu list       - (Sắp ra) Danh sách jutsu đã học",
            "=== VÍ DỤ CRAFT ===",
            "Kunai:    Sắt + Gậy",
            "Shuriken: 4 Sắt (hình thập)",
            "Ramen:    Giấy + Nước + Lúa mì",
            "Thuốc:    Kim cương + Mese + Táo",
        }
        return true, table.concat(help, "\n")
    end
})

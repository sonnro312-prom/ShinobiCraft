-- ============================================================
-- nametag.lua - Hiển thị tên + nhân vật + làng trên đầu
-- ============================================================

-- Màu sắc theo làng
local village_colors = {
    ["Làng Lá"]    = 0x00CC44,  -- Xanh lá
    ["Làng Cát"]   = 0xFFAA00,  -- Vàng cát
    ["Làng Sương"] = 0x00AAFF,  -- Xanh nước
    ["Làng Sương Mù"] = 0x88CCFF,
    ["Làng Mây"]   = 0xFFFFAA,  -- Vàng nhạt
    ["Làng Đá"]    = 0x888888,  -- Xám đá
    ["Vô Gia Cư"]  = 0xCCCCCC,  -- Trắng
}

function naruto.update_nametag(player)
    local name = player:get_player_name()
    local d    = naruto.player_data and naruto.player_data[name]
    if not d then
        player:set_nametag_attributes({
            text  = name,
            color = {r=255, g=255, b=255, a=255},
        })
        return
    end

    local color_hex = village_colors[d.village] or 0xFFFFFF
    local r = math.floor(color_hex / 0x10000) % 0x100
    local g = math.floor(color_hex / 0x100)   % 0x100
    local b = color_hex % 0x100

    -- Dòng 1: tên người chơi
    -- Dòng 2: nhân vật | cấp bậc
    player:set_nametag_attributes({
        text    = name .. "\n" .. d.character .. " [" .. d.rank .. "]",
        color   = {r=r, g=g, b=b, a=255},
        bgcolor = {r=0, g=0, b=0, a=160},
    })
end

-- Cập nhật nametag khi join
minetest.register_on_joinplayer(function(player)
    minetest.after(0.5, function()
        if player and player:is_player() then
            naruto.update_nametag(player)
        end
    end)
end)

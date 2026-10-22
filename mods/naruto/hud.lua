-- ============================================================
-- hud.lua - HUD tổng hợp: nhân vật, làng, cấp độ
-- ============================================================

naruto.player_data = naruto.player_data or {}

-- Lưu thông tin nhân vật người chơi
local function init_player_data(name)
    if not naruto.player_data[name] then
        naruto.player_data[name] = {
            character = "Lãng Khách",
            village   = "Vô Gia Cư",
            rank      = "Genin",
            kills     = 0,
        }
    end
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    init_player_data(name)

    -- HUD hiển thị nhân vật + cấp bậc góc trên trái
    player:hud_add({
        hud_elem_type = "text",
        position      = {x = 0, y = 0},
        offset        = {x = 8, y = 8},
        text          = "🍥 ShinobiCraft",
        number        = 0xFF8C00,
        alignment     = {x = 1, y = 1},
        scale         = {x = 200, y = 20},
    })
end)

-- Chat command xem thông tin bản thân
minetest.register_chatcommand("info", {
    description = "Xem thông tin ninja của bạn",
    func = function(name, param)
        local d = naruto.player_data[name]
        if not d then return false, "Không tìm thấy dữ liệu." end
        return true, ("=== 🍥 Hồ Sơ Ninja ===\n" ..
            "Tên: " .. name .. "\n" ..
            "Nhân Vật: " .. d.character .. "\n" ..
            "Làng: " .. d.village .. "\n" ..
            "Cấp Bậc: " .. d.rank .. "\n" ..
            "Boss Đã Tiêu Diệt: " .. d.kills)
    end
})

-- Chat command chọn nhân vật
minetest.register_chatcommand("chonninja", {
    description = "Chọn nhân vật ninja. VD: /chonninja naruto",
    params      = "<tên>",
    func = function(name, param)
        local choices = {
            naruto  = {character="Naruto Uzumaki",  village="Làng Lá",     rank="Hokage"},
            sasuke  = {character="Sasuke Uchiha",   village="Làng Lá",     rank="Jonin"},
            sakura  = {character="Sakura Haruno",   village="Làng Lá",     rank="Jonin"},
            kakashi = {character="Kakashi Hatake",  village="Làng Lá",     rank="Jonin"},
            gaara   = {character="Gaara",           village="Làng Cát",    rank="Kazekage"},
            itachi  = {character="Itachi Uchiha",   village="Làng Lá",     rank="Anbu"},
            minato  = {character="Minato Namikaze", village="Làng Lá",     rank="Hokage"},
            jiraiya = {character="Jiraiya",         village="Làng Lá",     rank="Sannin"},
            tsunade = {character="Tsunade",         village="Làng Lá",     rank="Hokage"},
            rock    = {character="Rock Lee",        village="Làng Lá",     rank="Jonin"},
        }
        local choice = choices[param:lower()]
        if not choice then
            local list = {}
            for k in pairs(choices) do list[#list+1] = k end
            return false, "Nhân vật không hợp lệ. Chọn: " .. table.concat(list, ", ")
        end
        init_player_data(name)
        naruto.player_data[name].character = choice.character
        naruto.player_data[name].village   = choice.village
        naruto.player_data[name].rank      = choice.rank

        -- Cập nhật nametag
        local player = minetest.get_player_by_name(name)
        if player then naruto.update_nametag(player) end

        return true, ("✅ Bạn đã chọn: " .. choice.character .. " từ " .. choice.village)
    end
})

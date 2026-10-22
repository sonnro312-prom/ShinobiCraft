-- ============================================================
-- bosses/boss_base.lua - Hệ thống Boss cơ bản
-- ============================================================

naruto.bosses = {}

-- Helper: hiển thị thanh máu boss trên chat
local function announce_boss_hp(boss_name, hp, max_hp)
    local pct   = math.floor(hp / max_hp * 20)
    local bar   = string.rep("█", pct) .. string.rep("░", 20 - pct)
    local color = pct > 10 and "#FF4444" or "#FF0000"
    minetest.chat_send_all(
        minetest.colorize(color,
        "💀 [BOSS] " .. boss_name .. " HP: [" .. bar .. "] " ..
        math.floor(hp) .. "/" .. max_hp))
end

-- Helper: loot drop khi boss chết
function naruto.bosses.drop_loot(pos, loot_table)
    for _, loot in ipairs(loot_table) do
        if math.random() < loot.chance then
            local amount = math.random(loot.min or 1, loot.max or 1)
            for _ = 1, amount do
                local offset = {
                    x = pos.x + math.random(-2, 2),
                    y = pos.y + 1,
                    z = pos.z + math.random(-2, 2),
                }
                minetest.add_item(offset, loot.item)
            end
        end
    end
end

-- Helper: spawn boss tại vị trí
function naruto.bosses.spawn(entity_name, pos, announce)
    local ent = minetest.add_entity(pos, entity_name)
    if ent and announce then
        minetest.chat_send_all(
            minetest.colorize("#FF0000",
            "⚠️ BOSS XUẤT HIỆN: " .. announce ..
            " tại " .. minetest.pos_to_string(pos, 0) .. "!"))
        minetest.sound_play("default_dig_cracky",
            {pos=pos, gain=2.0, max_hear_distance=100})
    end
    return ent
end

-- Lệnh /bossspawn để GM spawn boss
minetest.register_chatcommand("bossspawn", {
    description = "Spawn boss. VD: /bossspawn orochimaru",
    privs       = {server=true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Không tìm thấy người chơi." end
        local pos = player:get_pos()
        pos.x = pos.x + 3

        local bosses_map = {
            orochimaru = "naruto:boss_orochimaru",
            pain       = "naruto:boss_pain",
            madara     = "naruto:boss_madara",
        }
        local entity = bosses_map[param:lower()]
        if not entity then
            return false, "Boss không hợp lệ. Chọn: orochimaru, pain, madara"
        end
        naruto.bosses.spawn(entity, pos, param)
        return true, "✅ Đã spawn boss: " .. param
    end
})

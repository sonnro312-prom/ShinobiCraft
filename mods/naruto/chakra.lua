-- ============================================================
-- chakra.lua - Hệ thống Chakra (năng lượng ninja)
-- ============================================================

naruto.chakra = {}

local chakra_data = {}    -- { [player_name] = current_chakra }
local max_chakra = 100
local regen_rate = 2      -- hồi 2 chakra/giây
local hud_ids = {}        -- HUD element IDs per player

-- ── Khởi tạo chakra khi người chơi vào game ──────────────────
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    chakra_data[name] = max_chakra

    -- Thêm HUD bar chakra (màu xanh lam, bên dưới thanh máu)
    hud_ids[name] = {}
    hud_ids[name].bar = player:hud_add({
        hud_elem_type = "statbar",
        position      = {x = 0.5, y = 1},
        text          = "naruto_chakra_icon.png",
        text2         = "naruto_chakra_icon_bg.png",
        number        = max_chakra * 2,
        item          = max_chakra * 2,
        direction     = 0,
        size          = {x = 24, y = 24},
        offset        = {x = -263, y = -134},
    })
    hud_ids[name].label = player:hud_add({
        hud_elem_type = "text",
        position      = {x = 0.5, y = 1},
        text          = "⚡ Chakra: " .. max_chakra .. "/" .. max_chakra,
        number        = 0x00BFFF,
        alignment     = {x = -1, y = -1},
        offset        = {x = -263, y = -150},
    })
end)

-- ── Dọn dẹp khi người chơi rời game ─────────────────────────
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    chakra_data[name] = nil
    hud_ids[name]     = nil
end)

-- ── Hồi Chakra theo thời gian ────────────────────────────────
local regen_timer = 0
minetest.register_globalstep(function(dtime)
    regen_timer = regen_timer + dtime
    if regen_timer < 1 then return end
    regen_timer = 0

    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        if chakra_data[name] then
            local old = chakra_data[name]
            chakra_data[name] = math.min(old + regen_rate, max_chakra)
            if chakra_data[name] ~= old then
                naruto.chakra.update_hud(player)
            end
        end
    end
end)

-- ── API: cập nhật HUD ────────────────────────────────────────
function naruto.chakra.update_hud(player)
    local name = player:get_player_name()
    local cur  = chakra_data[name] or 0
    if not hud_ids[name] then return end
    player:hud_change(hud_ids[name].bar,   "number", cur * 2)
    player:hud_change(hud_ids[name].label, "text",
        "⚡ Chakra: " .. math.floor(cur) .. "/" .. max_chakra)
end

-- ── API: lấy chakra hiện tại ─────────────────────────────────
function naruto.chakra.get(player_name)
    return chakra_data[player_name] or 0
end

-- ── API: tiêu chakra (trả về true nếu đủ) ───────────────────
function naruto.chakra.use(player_name, amount)
    if not chakra_data[player_name] then return false end
    if chakra_data[player_name] < amount then
        -- Thông báo không đủ
        local player = minetest.get_player_by_name(player_name)
        if player then
            minetest.chat_send_player(player_name,
                minetest.colorize("#FF4444", "⚡ Không đủ Chakra! (" ..
                    math.floor(chakra_data[player_name]) .. "/" .. amount .. ")"))
        end
        return false
    end
    chakra_data[player_name] = chakra_data[player_name] - amount
    local player = minetest.get_player_by_name(player_name)
    if player then naruto.chakra.update_hud(player) end
    return true
end

-- ── API: hồi chakra tức thì ──────────────────────────────────
function naruto.chakra.restore(player_name, amount)
    if not chakra_data[player_name] then return end
    chakra_data[player_name] = math.min(
        chakra_data[player_name] + amount, max_chakra)
    local player = minetest.get_player_by_name(player_name)
    if player then naruto.chakra.update_hud(player) end
end

-- ── API: lấy max chakra ──────────────────────────────────────
function naruto.chakra.get_max()
    return max_chakra
end

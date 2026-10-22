-- ============================================================
-- items/consumables.lua - Vật phẩm tiêu thụ (đồ ăn, thuốc)
-- ============================================================

-- ── Mì Ramen Ichiraku (hồi máu) ─────────────────────────────
minetest.register_craftitem("naruto:ichiraku_ramen", {
    description    = "Mì Ramen Ichiraku 🍜\nHồi 8 HP khi ăn",
    inventory_image = "naruto_ramen.png",
    on_use          = minetest.item_eat(8),
    groups          = {food=1},
})

minetest.register_craft({
    output = "naruto:ichiraku_ramen",
    recipe = {
        {"default:paper",   "default:water_source", "default:paper"},
        {"farming:wheat",   "default:water_source",  "default:apple"},
        {"default:paper",   "default:water_source", "default:paper"},
    },
})

-- ── Binh Lương Hoàn (hồi chakra) ────────────────────────────
minetest.register_craftitem("naruto:soldier_pill", {
    description    = "Binh Lương Hoàn 💊\nHồi 50 Chakra ngay lập tức",
    inventory_image = "naruto_soldier_pill.png",
    stack_max      = 16,
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        naruto.chakra.restore(name, 50)
        minetest.sound_play("default_dig_snappy", {pos=user:get_pos(), gain=0.4})
        minetest.chat_send_player(name,
            minetest.colorize("#00FFFF", "💊 Hồi 50 Chakra!"))
        itemstack:take_item(1)
        return itemstack
    end,
})

minetest.register_craft({
    output = "naruto:soldier_pill 8",
    recipe = {
        {"default:diamond",  "default:gold_ingot", "default:diamond"},
        {"default:mese_crystal","default:apple","default:mese_crystal"},
        {"default:diamond",  "default:gold_ingot", "default:diamond"},
    },
})

-- ── Rượu Sake (buff tạm thời) ───────────────────────────────
minetest.register_craftitem("naruto:sake", {
    description    = "Rượu Sake 🍶\nHồi 4 HP + tăng tốc 10 giây",
    inventory_image = "naruto_sake.png",
    on_use = function(itemstack, user, pointed_thing)
        user:set_physics_override({speed = 1.5})
        minetest.after(10, function()
            if user and user:is_player() then
                user:set_physics_override({speed = 1.0})
            end
        end)
        user:set_hp(math.min(user:get_hp() + 4, user:get_properties().hp_max))
        minetest.chat_send_player(user:get_player_name(),
            minetest.colorize("#FFAA44", "🍶 Tăng tốc 10 giây!"))
        itemstack:take_item(1)
        return itemstack
    end,
})

-- ── Ration Bar (hồi nhiều hp) ───────────────────────────────
minetest.register_craftitem("naruto:ration_bar", {
    description     = "Khẩu Phần Chiến Trường 🍱\nHồi đầy HP",
    inventory_image = "naruto_ration_bar.png",
    on_use = function(itemstack, user, pointed_thing)
        local max_hp = user:get_properties().hp_max or 20
        user:set_hp(max_hp)
        minetest.chat_send_player(user:get_player_name(),
            minetest.colorize("#00FF88", "🍱 Hồi đầy HP!"))
        itemstack:take_item(1)
        return itemstack
    end,
})

minetest.register_craft({
    output = "naruto:ration_bar 2",
    recipe = {
        {"naruto:ichiraku_ramen", "naruto:soldier_pill", "naruto:ichiraku_ramen"},
    },
})

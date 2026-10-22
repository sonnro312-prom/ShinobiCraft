-- ============================================================
-- items/armor.lua - Trang phục & Giáp Ninja
-- ============================================================

-- Băng Trán Làng Lá
minetest.register_craftitem("naruto:headband_leaf", {
    description    = "Băng Trán Làng Lá 🍃\n+5 Chakra tối đa",
    inventory_image = "naruto_headband_leaf.png",
    groups         = {armor_head=1, armor_heal=0, armor_use=200},
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        naruto.player_data[name] = naruto.player_data[name] or {}
        naruto.player_data[name].village = "Làng Lá"
        naruto.update_nametag(user)
        minetest.chat_send_player(name,
            minetest.colorize("#00CC44",
            "🍃 Bạn đã gia nhập Làng Lá! Konoha no Kage!"))
        return itemstack
    end,
})

-- Băng Trán Làng Cát
minetest.register_craftitem("naruto:headband_sand", {
    description    = "Băng Trán Làng Cát 🏜️\n+10 HP tối đa",
    inventory_image = "naruto_headband_sand.png",
    groups         = {armor_head=1},
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        naruto.player_data[name] = naruto.player_data[name] or {}
        naruto.player_data[name].village = "Làng Cát"
        naruto.update_nametag(user)
        minetest.chat_send_player(name,
            minetest.colorize("#FFAA00",
            "🏜️ Bạn đã gia nhập Làng Cát! Suna no Kaze!"))
        return itemstack
    end,
})

-- Áo Khoác Hokage (item hiếm)
minetest.register_craftitem("naruto:hokage_cloak", {
    description    = "Áo Khoác Hokage 🔴\nSiêu hiếm - Chỉ Hokage mới có",
    inventory_image = "naruto_hokage_cloak.png",
    groups         = {not_in_creative_inventory=0},
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        naruto.player_data[name] = naruto.player_data[name] or {}
        naruto.player_data[name].rank = "Hokage"
        naruto.update_nametag(user)
        minetest.chat_send_all(
            minetest.colorize("#FF4400",
            "🔴 " .. name .. " đã trở thành HOKAGE! Dattebayo!"))
        return itemstack
    end,
})

-- Crafts
minetest.register_craft({
    output = "naruto:headband_leaf",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"default:cloth",       "default:leaves",      "default:cloth"},
    },
})

minetest.register_craft({
    output = "naruto:headband_sand",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"default:cloth",       "default:sand",         "default:cloth"},
    },
})

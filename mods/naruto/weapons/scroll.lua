-- ============================================================
-- weapons/scroll.lua - Cuộn Thuật (chứa Jutsu)
-- ============================================================

-- Cuộn thuật Hỏa Độn
minetest.register_tool("naruto:scroll_fire", {
    description = "Cuộn Thuật: Hỏa Độn\nDùng để học Hỏa Cầu Thuật",
    inventory_image = "naruto_scroll_fire.png",
    stack_max = 4,
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        minetest.chat_send_player(name,
            minetest.colorize("#FF6600",
            "📜 Bạn đã học: Hỏa Độn - Hào Cầu Thuật!\n" ..
            "Dùng lệnh /jutsu fire để đặt vào tay."))
        naruto.player_data[name] = naruto.player_data[name] or {}
        naruto.player_data[name].jutsu_fire = true
        itemstack:take_item(1)
        return itemstack
    end,
})

-- Cuộn thuật Phong Độn
minetest.register_tool("naruto:scroll_wind", {
    description = "Cuộn Thuật: Phong Độn\nDùng để học Phong Nhẫn",
    inventory_image = "naruto_scroll_wind.png",
    stack_max = 4,
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        minetest.chat_send_player(name,
            minetest.colorize("#AAFFAA",
            "📜 Bạn đã học: Phong Độn - Phong Nhẫn Thuật!"))
        naruto.player_data[name] = naruto.player_data[name] or {}
        naruto.player_data[name].jutsu_wind = true
        itemstack:take_item(1)
        return itemstack
    end,
})

-- Craft cuộn thuật
minetest.register_craft({
    output = "naruto:scroll_fire",
    recipe = {
        {"default:paper", "default:paper", "default:paper"},
        {"default:torch",  "default:coal_lump", "default:torch"},
        {"default:paper", "default:paper", "default:paper"},
    },
})

minetest.register_craft({
    output = "naruto:scroll_wind",
    recipe = {
        {"default:paper",    "default:paper", "default:paper"},
        {"default:leaves",   "default:paper", "default:leaves"},
        {"default:paper",    "default:paper", "default:paper"},
    },
})

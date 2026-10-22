-- ============================================================
-- weapons/katana.lua - Kiếm Katana & Kusanagi
-- ============================================================

-- Katana thường
minetest.register_tool("naruto:katana", {
    description = "Kiếm Katana\nVũ khí cận chiến mạnh",
    inventory_image = "naruto_katana.png",
    range = 4,
    tool_capabilities = {
        full_punch_interval = 0.6,
        max_drop_level = 2,
        groupcaps = {
            fleshy = {times={[1]=2.5, [2]=1.2, [3]=0.6}, uses=80, maxlevel=3},
        },
        damage_groups = {fleshy = 9},
    },
})

-- Kiếm Kusanagi (Sasuke) - đặc biệt
minetest.register_tool("naruto:kusanagi", {
    description = "Kiếm Kusanagi của Sasuke\nMỗi đòn đánh gây thêm hiệu ứng Lôi",
    inventory_image = "naruto_kusanagi.png",
    range = 4.5,
    tool_capabilities = {
        full_punch_interval = 0.5,
        max_drop_level = 3,
        groupcaps = {
            fleshy = {times={[1]=1.5, [2]=0.8, [3]=0.4}, uses=120, maxlevel=3},
        },
        damage_groups = {fleshy = 12},
    },
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "object" then
            local target = pointed_thing.ref
            -- Hiệu ứng sét nhỏ
            local pos = target:get_pos()
            minetest.add_particlespawner({
                amount   = 15, time = 0.2,
                minpos   = pos, maxpos = pos,
                minvel   = {x=-2,y=2,z=-2}, maxvel = {x=2,y=4,z=2},
                minacc   = {x=0,y=-5,z=0},  maxacc = {x=0,y=-5,z=0},
                minexptime = 0.3, maxexptime = 0.6,
                minsize  = 0.5,   maxsize = 1,
                texture  = "naruto_lightning_particle.png",
                glow     = 14,
            })
            minetest.sound_play("default_dig_cracky", {pos=pos, gain=0.8})
        end
    end,
})

-- Craft
minetest.register_craft({
    output = "naruto:katana",
    recipe = {
        {"", "", "default:steel_ingot"},
        {"", "default:steel_ingot", ""},
        {"default:stick", "", ""},
    },
})

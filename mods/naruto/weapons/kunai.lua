-- ============================================================
-- weapons/kunai.lua - Phi tiêu Kunai
-- ============================================================

-- ── Entity phi tiêu bay ──────────────────────────────────────
minetest.register_entity("naruto:kunai_entity", {
    initial_properties = {
        visual            = "sprite",
        visual_size       = {x = 0.3, y = 0.3},
        textures          = {"naruto_kunai.png"},
        physical          = true,
        collide_with_objects = true,
        collisionbox      = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
        is_visible        = true,
    },
    owner  = nil,
    damage = 6,
    timer  = 0,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 5 then
            self.object:remove()
            return
        end
        -- Kiểm tra va chạm với thực thể khác
        local pos = self.object:get_pos()
        local objs = minetest.get_objects_inside_radius(pos, 0.6)
        for _, obj in ipairs(objs) do
            if obj ~= self.object then
                local is_owner = (obj:is_player() and
                    obj:get_player_name() == self.owner)
                if not is_owner then
                    obj:punch(self.object, 1.0,
                        {full_punch_interval=0.5, damage_groups={fleshy=self.damage}},
                        self.object:get_velocity())
                    -- Hiệu ứng âm thanh
                    minetest.sound_play("default_dig_metal",
                        {pos=pos, gain=0.5, max_hear_distance=16})
                    self.object:remove()
                    return
                end
            end
        end
    end,
})

-- ── Item Kunai ───────────────────────────────────────────────
minetest.register_tool("naruto:kunai", {
    description     = "Phi Tiêu Kunai\nChạm: Đâm | Click phải: Ném (3 Chakra)",
    inventory_image = "naruto_kunai.png",
    range           = 3,
    tool_capabilities = {
        full_punch_interval = 0.4,
        max_drop_level      = 1,
        groupcaps = {
            fleshy = {times={[1]=1.5, [2]=0.8, [3]=0.4}, uses=30, maxlevel=2},
        },
        damage_groups = {fleshy = 5},
    },
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        -- Click phải: ném kunai
        if not naruto.chakra.use(name, 3) then return end

        local pos = user:get_pos()
        pos.y = pos.y + 1.5
        local dir = user:get_look_dir()

        local ent = minetest.add_entity(pos, "naruto:kunai_entity")
        if ent then
            ent:set_velocity(vector.multiply(dir, 25))
            local luaent = ent:get_luaentity()
            if luaent then luaent.owner = name end
        end
        minetest.sound_play("default_dig_metal",
            {pos=pos, gain=0.3, max_hear_distance=12})

        -- Giảm số lần sử dụng
        itemstack:add_wear(1000)
        return itemstack
    end,
})

-- ── Craft recipe ─────────────────────────────────────────────
minetest.register_craft({
    output = "naruto:kunai 8",
    recipe = {
        {"", "default:steel_ingot", ""},
        {"", "default:stick", ""},
        {"", "", ""},
    },
})

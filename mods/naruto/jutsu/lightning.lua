-- ============================================================
-- jutsu/lightning.lua - Lôi Độn: Chidori / Raikiri
-- ============================================================

-- Entity tia sét
minetest.register_entity("naruto:chidori_entity", {
    initial_properties = {
        visual        = "sprite",
        visual_size   = {x = 1.8, y = 1.8},
        textures      = {"naruto_chidori.png"},
        physical      = true,
        collisionbox  = {-0.6, -0.6, -0.6, 0.6, 0.6, 0.6},
        glow          = 15,
    },
    owner  = nil,
    damage = 22,
    timer  = 0,
    pierced = 0,  -- số thực thể xuyên qua

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 1.5 or self.pierced >= 3 then
            self.object:remove()
            return
        end
        local pos = self.object:get_pos()
        -- Lightning particle
        minetest.add_particlespawner({
            amount   = 20, time = 0.04,
            minpos   = pos, maxpos = pos,
            minvel   = {x=-3,y=-3,z=-3}, maxvel = {x=3,y=3,z=3},
            minacc   = {x=0,y=0,z=0},
            minexptime = 0.1, maxexptime = 0.25,
            minsize  = 1.5, maxsize = 2.5,
            texture  = "naruto_lightning_particle.png",
            glow     = 15,
        })
        -- Xuyên nhiều kẻ thù
        local objs = minetest.get_objects_inside_radius(pos, 0.9)
        for _, obj in ipairs(objs) do
            if obj ~= self.object then
                local skip = obj:is_player() and obj:get_player_name() == self.owner
                if not skip then
                    obj:punch(self.object, 1.0,
                        {full_punch_interval=1.0, damage_groups={fleshy=self.damage}}, nil)
                    self.pierced = self.pierced + 1
                    minetest.sound_play("default_dig_cracky",
                        {pos=pos, gain=0.9, max_hear_distance=20})
                end
            end
        end
    end,
})

-- Jutsu Chidori
minetest.register_tool("naruto:jutsu_chidori", {
    description = "Lôi Độn: Chidori ⚡\n" ..
                  "Tốn 35 Chakra | Xuyên nhiều kẻ địch\n" ..
                  "Đặc kỹ của Sasuke & Kakashi",
    inventory_image = "naruto_jutsu_lightning.png",
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        if not naruto.chakra.use(name, 35) then return end

        local pos = user:get_pos()
        pos.y = pos.y + 1.5
        local dir = user:get_look_dir()

        local ent = minetest.add_entity(pos, "naruto:chidori_entity")
        if ent then
            ent:set_velocity(vector.multiply(dir, 28))
            local le = ent:get_luaentity()
            if le then le.owner = name end
        end

        -- Âm thanh đặc trưng Chidori (chim hót)
        minetest.sound_play("default_dig_cracky",
            {pos=pos, gain=1.5, max_hear_distance=30})
        minetest.chat_send_player(name,
            minetest.colorize("#AAAAFF", "⚡ LÔI ĐỘN: CHIDORI!"))

        itemstack:add_wear(6553)
        return itemstack
    end,
})

minetest.register_craft({
    output = "naruto:jutsu_chidori",
    recipe = {
        {"default:mese_crystal",  "default:mese_crystal",  "default:mese_crystal"},
        {"default:mese_crystal",  "naruto:scroll_fire",    "default:mese_crystal"},
        {"default:mese_crystal",  "default:mese_crystal",  "default:mese_crystal"},
    },
})

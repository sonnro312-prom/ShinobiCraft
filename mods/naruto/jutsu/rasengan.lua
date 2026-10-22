-- ============================================================
-- jutsu/rasengan.lua - Thuật Rasengan của Naruto
-- ============================================================

-- Entity Rasengan bay
minetest.register_entity("naruto:rasengan_entity", {
    initial_properties = {
        visual          = "sprite",
        visual_size     = {x = 1.2, y = 1.2},
        textures        = {"naruto_rasengan.png"},
        physical        = true,
        collisionbox    = {-0.4, -0.4, -0.4, 0.4, 0.4, 0.4},
        is_visible      = true,
        glow            = 14,
    },
    owner  = nil,
    damage = 18,
    timer  = 0,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 2.5 then
            self:_explode()
            return
        end

        local pos = self.object:get_pos()

        -- Particle xoáy
        minetest.add_particlespawner({
            amount      = 8, time = 0.05,
            minpos      = {x=pos.x-0.3,y=pos.y-0.3,z=pos.z-0.3},
            maxpos      = {x=pos.x+0.3,y=pos.y+0.3,z=pos.z+0.3},
            minvel      = {x=-2,y=-2,z=-2}, maxvel = {x=2,y=2,z=2},
            minacc      = {x=0,y=0,z=0},
            minexptime  = 0.2, maxexptime = 0.4,
            minsize     = 1.5, maxsize    = 2.5,
            texture     = "naruto_chakra_particle.png",
            glow        = 14,
        })

        -- Hit detection
        local objs = minetest.get_objects_inside_radius(pos, 0.7)
        for _, obj in ipairs(objs) do
            if obj ~= self.object then
                local skip = obj:is_player() and obj:get_player_name() == self.owner
                if not skip then
                    obj:punch(self.object, 1.0,
                        {full_punch_interval=1.0, damage_groups={fleshy=self.damage}}, nil)
                    self:_explode()
                    return
                end
            end
        end
    end,

    _explode = function(self)
        local pos = self.object:get_pos()
        -- Vụ nổ chakra
        minetest.add_particlespawner({
            amount   = 40, time = 0.1,
            minpos   = pos, maxpos = pos,
            minvel   = {x=-8,y=-8,z=-8}, maxvel = {x=8,y=8,z=8},
            minacc   = {x=0,y=-5,z=0},
            minexptime = 0.5, maxexptime = 1.0,
            minsize  = 2,    maxsize    = 4,
            texture  = "naruto_rasengan_explosion.png",
            glow     = 14,
        })
        minetest.sound_play("tnt_explode", {pos=pos, gain=0.5, max_hear_distance=32})
        -- AoE nhỏ quanh điểm nổ
        local affected = minetest.get_objects_inside_radius(pos, 2.5)
        for _, obj in ipairs(affected) do
            if obj ~= self.object then
                local skip = obj:is_player() and obj:get_player_name() == self.owner
                if not skip then
                    obj:punch(self.object, 1.0,
                        {full_punch_interval=1.0, damage_groups={fleshy=8}}, nil)
                end
            end
        end
        self.object:remove()
    end,
})

-- Cuộn Thuật Rasengan
minetest.register_tool("naruto:jutsu_rasengan", {
    description = "Thuật: Rasengan 🍥\n" ..
                  "Tốn 30 Chakra | Sát thương cao\n" ..
                  "Chỉ Naruto/Minato sử dụng được tốt nhất",
    inventory_image = "naruto_jutsu_rasengan.png",
    range = 0,
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        if not naruto.chakra.use(name, 30) then return end

        local pos = user:get_pos()
        pos.y = pos.y + 1.5
        local dir = user:get_look_dir()

        local ent = minetest.add_entity(pos, "naruto:rasengan_entity")
        if ent then
            ent:set_velocity(vector.multiply(dir, 18))
            local le = ent:get_luaentity()
            if le then le.owner = name end
        end

        minetest.sound_play("default_dig_cracky",
            {pos=pos, gain=1.0, max_hear_distance=24})
        minetest.chat_send_player(name,
            minetest.colorize("#FF8800", "🍥 RASENGAN!"))

        -- Cooldown qua wear
        itemstack:add_wear(6553)
        return itemstack
    end,
})

minetest.register_craft({
    output = "naruto:jutsu_rasengan",
    recipe = {
        {"naruto:scroll_wind", "naruto:scroll_wind", "naruto:scroll_wind"},
        {"naruto:scroll_wind", "default:mese_crystal", "naruto:scroll_wind"},
        {"naruto:scroll_wind", "naruto:scroll_wind", "naruto:scroll_wind"},
    },
})

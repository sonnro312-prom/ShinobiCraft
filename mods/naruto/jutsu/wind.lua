-- ============================================================
-- jutsu/wind.lua - Phong Độn Jutsu (Wind Style)
-- ============================================================

minetest.register_entity("naruto:wind_blade_entity", {
    initial_properties = {
        visual        = "sprite",
        visual_size   = {x = 1.0, y = 0.4},
        textures      = {"naruto_wind_blade.png"},
        physical      = true,
        collisionbox  = {-0.4, -0.1, -0.4, 0.4, 0.1, 0.4},
        glow          = 6,
    },
    owner  = nil,
    damage = 12,
    timer  = 0,
    bounce = 0,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 4 then
            self.object:remove()
            return
        end
        local pos  = self.object:get_pos()
        -- Trail gió
        minetest.add_particlespawner({
            amount   = 5, time = 0.05,
            minpos   = pos, maxpos = pos,
            minvel   = {x=-1,y=-1,z=-1}, maxvel = {x=1,y=1,z=1},
            minacc   = {x=0,y=0,z=0},
            minexptime = 0.2, maxexptime = 0.5,
            minsize  = 1, maxsize = 2,
            texture  = "naruto_wind_particle.png",
            glow     = 5,
        })
        local objs = minetest.get_objects_inside_radius(pos, 0.6)
        for _, obj in ipairs(objs) do
            if obj ~= self.object then
                local skip = obj:is_player() and obj:get_player_name() == self.owner
                if not skip then
                    obj:punch(self.object, 1.0,
                        {full_punch_interval=0.8, damage_groups={fleshy=self.damage}}, nil)
                    -- Knockback
                    local vel = self.object:get_velocity()
                    local dir = vector.normalize(vel)
                    obj:add_velocity({x=dir.x*8, y=4, z=dir.z*8})
                    self.object:remove()
                    return
                end
            end
        end
    end,
})

minetest.register_tool("naruto:jutsu_wind_blade", {
    description = "Phong Độn: Phong Nhẫn 🌪️\n" ..
                  "Tốn 18 Chakra | Bay nhanh + Knockback",
    inventory_image = "naruto_jutsu_wind.png",
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        if not naruto.chakra.use(name, 18) then return end

        local pos = user:get_pos()
        pos.y = pos.y + 1.5
        local dir = user:get_look_dir()

        -- Ném 1 lưỡi gió lớn
        local ent = minetest.add_entity(pos, "naruto:wind_blade_entity")
        if ent then
            ent:set_velocity(vector.multiply(dir, 30))
            local le = ent:get_luaentity()
            if le then le.owner = name end
        end

        minetest.sound_play("default_dig_snappy",
            {pos=pos, gain=0.8, max_hear_distance=18})
        minetest.chat_send_player(name,
            minetest.colorize("#AAFFAA", "🌪️ PHONG ĐỘN: PHONG NHẪN!"))

        itemstack:add_wear(4000)
        return itemstack
    end,
})

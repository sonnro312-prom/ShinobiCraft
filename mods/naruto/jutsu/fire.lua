-- ============================================================
-- jutsu/fire.lua - Hỏa Độn Jutsu (Fire Style)
-- ============================================================

-- Entity quả cầu lửa
minetest.register_entity("naruto:fireball_entity", {
    initial_properties = {
        visual        = "sprite",
        visual_size   = {x = 1.5, y = 1.5},
        textures      = {"naruto_fireball.png"},
        physical      = true,
        collisionbox  = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        glow          = 15,
    },
    owner  = nil,
    damage = 14,
    timer  = 0,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 3 then
            self:_burst()
            return
        end
        local pos = self.object:get_pos()
        -- Trail lửa
        minetest.add_particlespawner({
            amount   = 12, time = 0.05,
            minpos   = pos, maxpos = pos,
            minvel   = {x=-1,y=-1,z=-1}, maxvel = {x=1,y=2,z=1},
            minacc   = {x=0,y=1,z=0},
            minexptime = 0.3, maxexptime = 0.7,
            minsize  = 2, maxsize = 4,
            texture  = "fire_basic_flame.png",
            glow     = 15,
        })
        -- Đốt node lá/gỗ gần đó (không đốt stone/dirt để an toàn)
        -- Hit
        local objs = minetest.get_objects_inside_radius(pos, 0.8)
        for _, obj in ipairs(objs) do
            if obj ~= self.object then
                local skip = obj:is_player() and obj:get_player_name() == self.owner
                if not skip then
                    obj:punch(self.object, 1.0,
                        {full_punch_interval=1.0, damage_groups={fleshy=self.damage}}, nil)
                    self:_burst()
                    return
                end
            end
        end
    end,

    _burst = function(self)
        local pos = self.object:get_pos()
        minetest.add_particlespawner({
            amount   = 50, time = 0.15,
            minpos   = {x=pos.x-1,y=pos.y-1,z=pos.z-1},
            maxpos   = {x=pos.x+1,y=pos.y+1,z=pos.z+1},
            minvel   = {x=-6,y=-6,z=-6}, maxvel = {x=6,y=6,z=6},
            minacc   = {x=0,y=2,z=0},
            minexptime = 0.5, maxexptime = 1.2,
            minsize  = 3, maxsize = 6,
            texture  = "fire_basic_flame.png",
            glow     = 15,
        })
        minetest.sound_play("default_dig_cracky", {pos=pos, gain=1.2})
        local aoe = minetest.get_objects_inside_radius(pos, 3)
        for _, obj in ipairs(aoe) do
            if obj ~= self.object then
                local skip = obj:is_player() and obj:get_player_name() == self.owner
                if not skip then
                    obj:punch(self.object,1.0,{full_punch_interval=1,damage_groups={fleshy=6}},nil)
                end
            end
        end
        self.object:remove()
    end,
})

-- Jutsu Hỏa Cầu
minetest.register_tool("naruto:jutsu_fireball", {
    description = "Hỏa Độn: Hào Cầu Thuật 🔥\n" ..
                  "Tốn 20 Chakra | Đốt và gây AoE\n" ..
                  "Ấn chuột phải để phóng",
    inventory_image = "naruto_jutsu_fire.png",
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        if not naruto.chakra.use(name, 20) then return end

        local pos = user:get_pos()
        pos.y = pos.y + 1.5
        local dir = user:get_look_dir()

        local ent = minetest.add_entity(pos, "naruto:fireball_entity")
        if ent then
            ent:set_velocity(vector.multiply(dir, 16))
            local le = ent:get_luaentity()
            if le then le.owner = name end
        end

        minetest.sound_play("default_dig_cracky", {pos=pos, gain=0.8, max_hear_distance=20})
        minetest.chat_send_player(name,
            minetest.colorize("#FF4400", "🔥 HỎA ĐỘN: HÀO CẦU THUẬT!"))

        itemstack:add_wear(5000)
        return itemstack
    end,
})

minetest.register_craft({
    output = "naruto:jutsu_fireball",
    recipe = {
        {"naruto:scroll_fire", "naruto:scroll_fire", "naruto:scroll_fire"},
        {"naruto:scroll_fire", "default:torch",      "naruto:scroll_fire"},
        {"naruto:scroll_fire", "naruto:scroll_fire", "naruto:scroll_fire"},
    },
})

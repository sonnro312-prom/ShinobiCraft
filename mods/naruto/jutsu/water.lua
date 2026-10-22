-- ============================================================
-- jutsu/water.lua - Thủy Độn Jutsu (Water Style)
-- ============================================================

minetest.register_entity("naruto:water_dragon_entity", {
    initial_properties = {
        visual        = "sprite",
        visual_size   = {x = 2.0, y = 2.0},
        textures      = {"naruto_water_dragon.png"},
        physical      = true,
        collisionbox  = {-0.8, -0.8, -0.8, 0.8, 0.8, 0.8},
        glow          = 8,
    },
    owner  = nil,
    damage = 16,
    timer  = 0,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer > 3 then self.object:remove() return end

        local pos = self.object:get_pos()
        minetest.add_particlespawner({
            amount   = 15, time = 0.05,
            minpos   = pos, maxpos = pos,
            minvel   = {x=-2,y=-2,z=-2}, maxvel = {x=2,y=2,z=2},
            minacc   = {x=0,y=-3,z=0},
            minexptime = 0.3, maxexptime = 0.6,
            minsize  = 2, maxsize = 4,
            texture  = "default_water_source_animated.png",
            glow     = 6,
        })
        local objs = minetest.get_objects_inside_radius(pos, 1.0)
        for _, obj in ipairs(objs) do
            if obj ~= self.object then
                local skip = obj:is_player() and obj:get_player_name() == self.owner
                if not skip then
                    obj:punch(self.object, 1.0,
                        {full_punch_interval=1.0, damage_groups={fleshy=self.damage}}, nil)
                    -- Làm chậm kẻ địch
                    if obj:is_player() then
                        obj:add_velocity({x=0,y=5,z=0})
                    end
                    self.object:remove()
                    return
                end
            end
        end
    end,
})

minetest.register_tool("naruto:jutsu_water_dragon", {
    description = "Thủy Độn: Thủy Long Đàn 💧\n" ..
                  "Tốn 25 Chakra | Con rồng nước to\n" ..
                  "Mạnh khi đứng gần nước",
    inventory_image = "naruto_jutsu_water.png",
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        if not naruto.chakra.use(name, 25) then return end

        local pos = user:get_pos()
        pos.y = pos.y + 1.5
        local dir = user:get_look_dir()

        local ent = minetest.add_entity(pos, "naruto:water_dragon_entity")
        if ent then
            ent:set_velocity(vector.multiply(dir, 14))
            local le = ent:get_luaentity()
            if le then le.owner = name end
        end

        minetest.sound_play("default_place_node_water",
            {pos=pos, gain=1.0, max_hear_distance=20})
        minetest.chat_send_player(name,
            minetest.colorize("#00AAFF", "💧 THỦY ĐỘN: THỦY LONG ĐÀN!"))

        itemstack:add_wear(5500)
        return itemstack
    end,
})

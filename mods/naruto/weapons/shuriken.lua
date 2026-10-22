-- ============================================================
-- weapons/shuriken.lua - Phi tiêu Shuriken (ném nhiều hướng)
-- ============================================================

minetest.register_entity("naruto:shuriken_entity", {
    initial_properties = {
        visual        = "sprite",
        visual_size   = {x = 0.4, y = 0.4},
        textures      = {"naruto_shuriken.png"},
        physical      = true,
        collisionbox  = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
        is_visible    = true,
    },
    owner  = nil,
    damage = 4,
    timer  = 0,
    spin   = 0,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        self.spin  = self.spin + dtime * 720  -- quay 720 độ/giây

        if self.timer > 4 then
            self.object:remove()
            return
        end

        local pos  = self.object:get_pos()
        local objs = minetest.get_objects_inside_radius(pos, 0.5)
        for _, obj in ipairs(objs) do
            if obj ~= self.object then
                local skip = obj:is_player() and
                    obj:get_player_name() == self.owner
                if not skip then
                    obj:punch(self.object, 1.0,
                        {full_punch_interval=0.3, damage_groups={fleshy=self.damage}},
                        nil)
                    self.object:remove()
                    return
                end
            end
        end
    end,
})

minetest.register_tool("naruto:shuriken", {
    description     = "Phi Tiêu Shuriken\nNém 3 cái cùng lúc (5 Chakra)",
    inventory_image = "naruto_shuriken.png",
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        if not naruto.chakra.use(name, 5) then return end

        local pos = user:get_pos()
        pos.y = pos.y + 1.5
        local dir  = user:get_look_dir()

        -- Ném 3 hướng: thẳng + 2 bên
        local dirs = {
            dir,
            vector.rotate(dir, {x=0, y=math.rad(20), z=0}),
            vector.rotate(dir, {x=0, y=math.rad(-20), z=0}),
        }
        for _, d in ipairs(dirs) do
            local ent = minetest.add_entity(pos, "naruto:shuriken_entity")
            if ent then
                ent:set_velocity(vector.multiply(d, 22))
                local le = ent:get_luaentity()
                if le then le.owner = name end
            end
        end
        minetest.sound_play("default_dig_metal", {pos=pos, gain=0.4})
        itemstack:add_wear(2000)
        return itemstack
    end,
})

minetest.register_craft({
    output = "naruto:shuriken 4",
    recipe = {
        {"default:steel_ingot", "", "default:steel_ingot"},
        {"", "default:steel_ingot", ""},
        {"default:steel_ingot", "", "default:steel_ingot"},
    },
})

-- ============================================================
-- jutsu/shadow_clone.lua - Thuật Phân Thân (Kage Bunshin)
-- ============================================================

local clone_data = {}  -- { [owner_name] = {entity_refs} }

-- Entity phân thân
minetest.register_entity("naruto:shadow_clone", {
    initial_properties = {
        visual            = "upright_sprite",
        visual_size       = {x=1, y=2},
        textures          = {"naruto_clone_front.png", "naruto_clone_back.png"},
        physical          = true,
        collisionbox      = {-0.3, 0, -0.3, 0.3, 1.8, 0.3},
        is_visible        = true,
        makes_footstep_sound = true,
        hp_max            = 5,
    },
    owner   = nil,
    lifetime = 0,
    max_life = 30,  -- Tự hủy sau 30 giây
    target  = nil,

    on_step = function(self, dtime)
        self.lifetime = self.lifetime + dtime
        if self.lifetime > self.max_life then
            self:_dispel()
            return
        end

        -- Tìm kẻ thù gần nhất và tấn công
        local pos  = self.object:get_pos()
        local objs = minetest.get_objects_inside_radius(pos, 8)
        for _, obj in ipairs(objs) do
            if obj ~= self.object then
                local is_friend = obj:is_player() and obj:get_player_name() == self.owner
                local is_clone  = obj:get_luaentity() and
                    obj:get_luaentity().name == "naruto:shadow_clone"
                if not is_friend and not is_clone then
                    -- Di chuyển về phía kẻ thù
                    local tpos = obj:get_pos()
                    local dir  = vector.subtract(tpos, pos)
                    local dist = vector.length(dir)
                    if dist > 1.5 then
                        dir = vector.normalize(dir)
                        self.object:set_velocity(
                            {x=dir.x*4, y=self.object:get_velocity().y, z=dir.z*4})
                    else
                        -- Tấn công
                        obj:punch(self.object, 1.0,
                            {full_punch_interval=1.0, damage_groups={fleshy=4}}, nil)
                        self.object:set_velocity({x=0,y=0,z=0})
                    end
                    return
                end
            end
        end
        -- Không có kẻ thù, đứng gần chủ
        local owner = minetest.get_player_by_name(self.owner)
        if owner then
            local opos = owner:get_pos()
            local dir  = vector.subtract(opos, pos)
            local dist = vector.length(dir)
            if dist > 3 then
                dir = vector.normalize(dir)
                self.object:set_velocity({x=dir.x*4,y=0,z=dir.z*4})
            else
                self.object:set_velocity({x=0,y=0,z=0})
            end
        end
    end,

    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        -- Phân thân bị đánh → bốc khói
        self:_dispel()
    end,

    _dispel = function(self)
        local pos = self.object:get_pos()
        minetest.add_particlespawner({
            amount   = 20, time = 0.1,
            minpos   = pos, maxpos = {x=pos.x,y=pos.y+1.5,z=pos.z},
            minvel   = {x=-2,y=1,z=-2}, maxvel = {x=2,y=3,z=2},
            minacc   = {x=0,y=-1,z=0},
            minexptime = 0.5, maxexptime = 1.0,
            minsize  = 2, maxsize = 4,
            texture  = "naruto_smoke_particle.png",
        })
        minetest.sound_play("default_dig_snappy", {pos=pos, gain=0.5})
        -- Xóa khỏi danh sách
        if self.owner and clone_data[self.owner] then
            local list = clone_data[self.owner]
            for i, e in ipairs(list) do
                if e == self.object then
                    table.remove(list, i)
                    break
                end
            end
        end
        self.object:remove()
    end,
})

-- Jutsu Phân Thân
minetest.register_tool("naruto:jutsu_shadow_clone", {
    description = "Thuật Phân Thân 👥\n" ..
                  "Tốn 40 Chakra | Triệu hồi 3 phân thân\n" ..
                  "Phân thân tự động tìm và tấn công kẻ địch (30 giây)",
    inventory_image = "naruto_jutsu_clone.png",
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        if not naruto.chakra.use(name, 40) then return end

        -- Hủy phân thân cũ nếu còn
        if clone_data[name] then
            for _, e in ipairs(clone_data[name]) do
                if e and e:get_luaentity() then
                    e:get_luaentity():_dispel()
                end
            end
        end
        clone_data[name] = {}

        -- Triệu hồi 3 phân thân quanh người chơi
        local pos = user:get_pos()
        local offsets = {
            {x= 2, y=0, z= 0},
            {x=-2, y=0, z= 0},
            {x= 0, y=0, z= 2},
        }
        for _, off in ipairs(offsets) do
            local sp = {x=pos.x+off.x, y=pos.y, z=pos.z+off.z}
            local ent = minetest.add_entity(sp, "naruto:shadow_clone")
            if ent then
                local le = ent:get_luaentity()
                if le then le.owner = name end
                table.insert(clone_data[name], ent)
            end
        end

        minetest.add_particlespawner({
            amount   = 30, time = 0.2,
            minpos   = {x=pos.x-2,y=pos.y,z=pos.z-2},
            maxpos   = {x=pos.x+2,y=pos.y+2,z=pos.z+2},
            minvel   = {x=-2,y=2,z=-2}, maxvel = {x=2,y=5,z=2},
            minacc   = {x=0,y=-2,z=0},
            minexptime = 0.4, maxexptime = 0.8,
            minsize  = 2, maxsize = 3,
            texture  = "naruto_smoke_particle.png",
        })
        minetest.sound_play("default_dig_snappy",
            {pos=pos, gain=1.0, max_hear_distance=16})
        minetest.chat_send_player(name,
            minetest.colorize("#FFFF00", "👥 KAGE BUNSHIN NO JUTSU! (3 phân thân - 30 giây)"))

        itemstack:add_wear(6553)
        return itemstack
    end,
})

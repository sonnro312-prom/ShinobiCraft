-- ============================================================
-- bosses/pain.lua - Boss Pain (Thiên Đạo)
-- ============================================================

local PAIN_HP  = 350
local PAIN_DMG = 18

minetest.register_entity("naruto:boss_pain", {
    initial_properties = {
        visual       = "upright_sprite",
        visual_size  = {x=1.5, y=3},
        textures     = {"naruto_pain.png"},
        physical     = true,
        collisionbox = {-0.4, 0, -0.4, 0.4, 2.5, 0.4},
        hp_max       = PAIN_HP,
        glow         = 8,
    },
    max_hp    = PAIN_HP,
    timer     = 0,
    atk_timer = 0,
    gravity_timer = 0,

    on_activate = function(self, staticdata)
        self.object:set_hp(PAIN_HP)
        minetest.chat_send_all(
            minetest.colorize("#8800FF",
            "👁️ PAIN - THIÊN ĐẠO xuất hiện! " ..
            "\"Ta là thượng đế! Ta là đau khổ! Ta là PAIN!\""))
    end,

    on_step = function(self, dtime)
        self.timer        = self.timer + dtime
        self.atk_timer    = self.atk_timer + dtime
        self.gravity_timer = self.gravity_timer + dtime

        local pos = self.object:get_pos()
        local target, min_dist = nil, 999
        for _, p in ipairs(minetest.get_connected_players()) do
            local d = vector.distance(pos, p:get_pos())
            if d < min_dist then min_dist=d; target=p end
        end
        if not target then return end

        -- Di chuyển
        if min_dist > 2.5 then
            local dir = vector.normalize(vector.subtract(target:get_pos(), pos))
            self.object:set_velocity({x=dir.x*4, y=self.object:get_velocity().y, z=dir.z*4})
        end

        -- Đòn cơ bản
        if self.atk_timer >= 1.8 and min_dist < 3.5 then
            self.atk_timer = 0
            target:punch(self.object, 1.0,
                {full_punch_interval=1.8, damage_groups={fleshy=PAIN_DMG}}, nil)
        end

        -- Skill đặc biệt: Shinra Tensei (đẩy ra xa) mỗi 10 giây
        if self.gravity_timer >= 10 then
            self.gravity_timer = 0
            minetest.chat_send_all(
                minetest.colorize("#CC44FF", "👁️ SHINRA TENSEI!"))
            -- Đẩy tất cả người chơi trong vòng 10 blocks
            for _, p in ipairs(minetest.get_connected_players()) do
                local d = vector.distance(pos, p:get_pos())
                if d < 10 then
                    local away = vector.normalize(vector.subtract(p:get_pos(), pos))
                    p:add_velocity({x=away.x*20, y=8, z=away.z*20})
                    p:punch(self.object, 1.0,
                        {full_punch_interval=10, damage_groups={fleshy=15}}, nil)
                end
            end
            minetest.add_particlespawner({
                amount   = 100, time = 0.5,
                minpos   = {x=pos.x-8,y=pos.y-2,z=pos.z-8},
                maxpos   = {x=pos.x+8,y=pos.y+4,z=pos.z+8},
                minvel   = {x=-15,y=-5,z=-15}, maxvel = {x=15,y=5,z=15},
                minacc   = {x=0,y=0,z=0},
                minexptime = 0.3, maxexptime = 0.8,
                minsize  = 2, maxsize = 5,
                texture  = "naruto_chakra_particle.png",
                glow     = 14,
            })
        end
    end,

    on_death = function(self, killer)
        local pos = self.object:get_pos()
        minetest.chat_send_all(
            minetest.colorize("#FFFF00",
            "🏆 PAIN bị đánh bại! Hòa bình đã trở lại Làng Lá!"))
        naruto.bosses.drop_loot(pos, {
            {item="naruto:soldier_pill",    chance=1.0, min=5,  max=8},
            {item="naruto:jutsu_chidori",   chance=0.9, min=1,  max=1},
            {item="naruto:jutsu_rasengan",  chance=0.7, min=1,  max=1},
            {item="naruto:hokage_cloak",    chance=0.15,min=1, max=1},
            {item="default:diamond",        chance=1.0, min=5,  max=10},
            {item="default:mese_crystal",   chance=0.8, min=3,  max=6},
        })
        if killer and killer:is_player() then
            local kname = killer:get_player_name()
            naruto.player_data[kname] = naruto.player_data[kname] or {}
            naruto.player_data[kname].kills = (naruto.player_data[kname].kills or 0) + 3
            naruto.player_data[kname].rank = "Hokage"
            naruto.update_nametag(killer)
            minetest.chat_send_all(
                minetest.colorize("#FFD700",
                "👑 " .. kname .. " đã được phong HOKAGE sau khi đánh bại Pain!"))
        end
    end,
})

-- ============================================================
-- bosses/orochimaru.lua - Boss Orochimaru
-- ============================================================

local OROCHIMARU_HP  = 200
local OROCHIMARU_DMG = 12

minetest.register_entity("naruto:boss_orochimaru", {
    initial_properties = {
        visual            = "upright_sprite",
        visual_size       = {x=1.5, y=3},
        textures          = {"naruto_orochimaru.png"},
        physical          = true,
        collisionbox      = {-0.4, 0, -0.4, 0.4, 2.5, 0.4},
        makes_footstep_sound = true,
        hp_max            = OROCHIMARU_HP,
        is_visible        = true,
    },
    max_hp   = OROCHIMARU_HP,
    hp       = OROCHIMARU_HP,
    timer    = 0,
    phase    = 1,   -- 1=bình thường, 2=phase 2 khi HP<50%
    atk_timer = 0,

    on_activate = function(self, staticdata)
        self.object:set_hp(OROCHIMARU_HP)
        minetest.chat_send_all(
            minetest.colorize("#AA00AA",
            "🐍 ORO-CHI-MA-RU xuất hiện! Hắn thèm khát thân thể của bạn!"))
    end,

    on_step = function(self, dtime)
        self.timer    = self.timer + dtime
        self.atk_timer = self.atk_timer + dtime

        local pos = self.object:get_pos()
        self.hp   = self.object:get_hp()

        -- Chuyển phase 2 khi HP < 50%
        if self.hp <= OROCHIMARU_HP * 0.5 and self.phase == 1 then
            self.phase = 2
            minetest.chat_send_all(
                minetest.colorize("#FF00FF",
                "🐍 Orochimaru BIẾN HÌNH! Cẩn thận với nọc độc!"))
        end

        -- Tìm người chơi gần nhất
        local target, min_dist = nil, 999
        for _, p in ipairs(minetest.get_connected_players()) do
            local ppos = p:get_pos()
            local d    = vector.distance(pos, ppos)
            if d < min_dist then
                min_dist = d
                target   = p
            end
        end

        if not target then return end

        local tpos = target:get_pos()

        -- Di chuyển về phía người chơi
        if min_dist > 2 then
            local dir = vector.normalize(vector.subtract(tpos, pos))
            local spd = self.phase == 2 and 5 or 3
            self.object:set_velocity({x=dir.x*spd, y=self.object:get_velocity().y, z=dir.z*spd})
        else
            self.object:set_velocity({x=0, y=self.object:get_velocity().y, z=0})
        end

        -- Tấn công: cắn + phun nọc
        if self.atk_timer >= 2.0 and min_dist < 3 then
            self.atk_timer = 0

            -- Đòn cắn
            target:punch(self.object, 1.0,
                {full_punch_interval=2.0, damage_groups={fleshy=OROCHIMARU_DMG}}, nil)
            minetest.sound_play("default_dig_snappy",
                {pos=pos, gain=1.0, max_hear_distance=20})

            -- Phase 2: phun nọc độc (giảm tốc)
            if self.phase == 2 then
                target:set_physics_override({speed=0.5})
                minetest.after(5, function()
                    if target and target:is_player() then
                        target:set_physics_override({speed=1.0})
                    end
                end)
                minetest.chat_send_player(target:get_player_name(),
                    minetest.colorize("#FF00FF", "🐍 Bị trúng nọc độc! Tốc độ giảm 5 giây!"))
            end
        end

        -- Hiệu ứng thị giác định kỳ
        if self.timer >= 3 then
            self.timer = 0
            minetest.add_particlespawner({
                amount   = 10, time = 0.2,
                minpos   = pos, maxpos = {x=pos.x,y=pos.y+2,z=pos.z},
                minvel   = {x=-1,y=0,z=-1}, maxvel = {x=1,y=2,z=1},
                minacc   = {x=0,y=-1,z=0},
                minexptime = 0.5, maxexptime = 1.0,
                minsize  = 1, maxsize = 2,
                texture  = "naruto_poison_particle.png",
                glow     = 6,
            })
        end
    end,

    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        self.hp = self.object:get_hp()
        -- Thông báo HP boss mỗi lần bị đánh
        minetest.after(0.1, function()
            if self.object and self.object:get_luaentity() then
                local cur_hp = self.object:get_hp()
                -- Chỉ announce mỗi 10% HP
                local pct_new = math.floor(cur_hp / OROCHIMARU_HP * 10)
                local pct_old = math.floor(self.hp / OROCHIMARU_HP * 10)
                if pct_new ~= pct_old then
                    minetest.chat_send_all(
                        minetest.colorize("#FF4444",
                        "🐍 Orochimaru HP: " .. cur_hp .. "/" .. OROCHIMARU_HP))
                end
            end
        end)
    end,

    on_death = function(self, killer)
        local pos = self.object:get_pos()
        -- Hiệu ứng chết
        minetest.add_particlespawner({
            amount   = 60, time = 0.3,
            minpos   = pos, maxpos = {x=pos.x,y=pos.y+2,z=pos.z},
            minvel   = {x=-5,y=-5,z=-5}, maxvel = {x=5,y=5,z=5},
            minacc   = {x=0,y=-5,z=0},
            minexptime = 0.5, maxexptime = 1.5,
            minsize  = 2, maxsize = 5,
            texture  = "naruto_smoke_particle.png",
        })
        minetest.chat_send_all(
            minetest.colorize("#FFFF00",
            "🏆 Orochimaru bị tiêu diệt! " ..
            (killer and killer:is_player() and
                killer:get_player_name() or "Ai đó") ..
            " đã chiến thắng!"))

        -- Drop loot
        naruto.bosses.drop_loot(pos, {
            {item="naruto:soldier_pill",   chance=1.0, min=3,  max=5},
            {item="naruto:jutsu_fireball", chance=0.8, min=1,  max=1},
            {item="naruto:kusanagi",       chance=0.3, min=1,  max=1},
            {item="naruto:hokage_cloak",   chance=0.05,min=1, max=1},
            {item="default:diamond",       chance=0.5, min=2,  max=5},
        })

        -- Cộng kills
        if killer and killer:is_player() then
            local kname = killer:get_player_name()
            naruto.player_data[kname] = naruto.player_data[kname] or {}
            naruto.player_data[kname].kills = (naruto.player_data[kname].kills or 0) + 1
        end
    end,
})

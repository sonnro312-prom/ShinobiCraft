-- ============================================================
-- villages/structures.lua - Sinh làng ninja tự động
-- ============================================================

naruto.villages = {}

-- ── Template nhà ninja đơn giản ──────────────────────────────
local function build_ninja_house(pos, material)
    local p = {x=pos.x, y=pos.y, z=pos.z}
    -- Nền
    for dx = 0, 5 do
        for dz = 0, 5 do
            minetest.set_node({x=p.x+dx, y=p.y, z=p.z+dz},
                {name = material .. "_planks"})
        end
    end
    -- Tường
    for dy = 1, 3 do
        for dx = 0, 5 do
            minetest.set_node({x=p.x+dx, y=p.y+dy, z=p.z},   {name=material.."_planks"})
            minetest.set_node({x=p.x+dx, y=p.y+dy, z=p.z+5}, {name=material.."_planks"})
        end
        for dz = 1, 4 do
            minetest.set_node({x=p.x,   y=p.y+dy, z=p.z+dz}, {name=material.."_planks"})
            minetest.set_node({x=p.x+5, y=p.y+dy, z=p.z+dz}, {name=material.."_planks"})
        end
    end
    -- Mái
    for dx = 0, 5 do
        for dz = 0, 5 do
            minetest.set_node({x=p.x+dx, y=p.y+4, z=p.z+dz}, {name="default:cobble"})
        end
    end
    -- Cửa ra vào
    minetest.set_node({x=p.x+2, y=p.y+1, z=p.z}, {name="air"})
    minetest.set_node({x=p.x+2, y=p.y+2, z=p.z}, {name="air"})
    minetest.set_node({x=p.x+3, y=p.y+1, z=p.z}, {name="air"})
    minetest.set_node({x=p.x+3, y=p.y+2, z=p.z}, {name="air"})
    -- Cửa sổ
    minetest.set_node({x=p.x+1, y=p.y+2, z=p.z+5}, {name="default:glass"})
    minetest.set_node({x=p.x+4, y=p.y+2, z=p.z+5}, {name="default:glass"})
    -- Đèn lồng
    minetest.set_node({x=p.x+2, y=p.y+3, z=p.z+2}, {name="default:torch"})
    minetest.set_node({x=p.x+3, y=p.y+3, z=p.z+3}, {name="default:torch"})
end

-- ── Sinh Làng Lá (Konoha) ────────────────────────────────────
function naruto.villages.spawn_konoha(center)
    local mat = "default:wood"  -- gỗ
    -- 4 nhà xung quanh trung tâm
    local house_positions = {
        {x=center.x-10, y=center.y, z=center.z-10},
        {x=center.x+4,  y=center.y, z=center.z-10},
        {x=center.x-10, y=center.y, z=center.z+4},
        {x=center.x+4,  y=center.y, z=center.z+4},
    }
    for _, hp in ipairs(house_positions) do
        build_ninja_house(hp, mat)
    end
    -- Đài phun nước trung tâm
    for dx = -1, 1 do
        for dz = -1, 1 do
            minetest.set_node({x=center.x+dx, y=center.y, z=center.z+dz},
                {name="default:water_source"})
        end
    end
    -- Biển làng
    minetest.set_node(center, {name="default:sign_wall_wood"})
    minetest.chat_send_all(
        minetest.colorize("#00CC44",
        "🍃 Làng Lá (Konoha) đã được xây tại " ..
        minetest.pos_to_string(center, 0) .. "!"))
end

-- Lệnh xây làng
minetest.register_chatcommand("xayland", {
    description = "Xây làng ninja tại vị trí hiện tại. VD: /xayland konoha",
    privs       = {server=true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Không tìm thấy người chơi." end
        local pos = vector.round(player:get_pos())

        if param == "konoha" or param == "la" then
            naruto.villages.spawn_konoha(pos)
            return true, "✅ Đang xây Làng Lá!"
        end
        return false, "Chọn: konoha/la"
    end
})

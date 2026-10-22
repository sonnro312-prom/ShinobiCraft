-- ============================================================
-- ShinobiCraft - Naruto Mod
-- init.lua - Entry Point
-- ============================================================

naruto = {}
naruto.modpath = minetest.get_modpath("naruto")

-- *** Nạp các module theo thứ tự ***
dofile(naruto.modpath .. "/chakra.lua")
dofile(naruto.modpath .. "/characters.lua")
dofile(naruto.modpath .. "/weapons/kunai.lua")
dofile(naruto.modpath .. "/weapons/shuriken.lua")
dofile(naruto.modpath .. "/weapons/katana.lua")
dofile(naruto.modpath .. "/weapons/scroll.lua")
dofile(naruto.modpath .. "/jutsu/fire.lua")
dofile(naruto.modpath .. "/jutsu/lightning.lua")
dofile(naruto.modpath .. "/jutsu/wind.lua")
dofile(naruto.modpath .. "/jutsu/water.lua")
dofile(naruto.modpath .. "/jutsu/shadow_clone.lua")
dofile(naruto.modpath .. "/jutsu/rasengan.lua")
dofile(naruto.modpath .. "/items/consumables.lua")
dofile(naruto.modpath .. "/items/armor.lua")
dofile(naruto.modpath .. "/bosses/boss_base.lua")
dofile(naruto.modpath .. "/bosses/orochimaru.lua")
dofile(naruto.modpath .. "/bosses/pain.lua")
dofile(naruto.modpath .. "/villages/structures.lua")
dofile(naruto.modpath .. "/hud.lua")
dofile(naruto.modpath .. "/nametag.lua")
dofile(naruto.modpath .. "/tutorial.lua")

minetest.log("action", "[Naruto Mod] ShinobiCraft Naruto Mod đã nạp thành công!")

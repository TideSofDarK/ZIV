-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('ziv')

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See ZIV:PostLoadPrecache() in ziv.lua for more information
  ]]

  DebugPrint("[ZIV] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/ziv_creep_modifier_color.vpcf", context)
  PrecacheResource("particle", "particles/ziv_creep_lord_modifier_regen_aura.vpcf", context)
  PrecacheResource("particle_folder", "particles/items", context)

  PrecacheResource("particle_folder", "particles/econ/courier/courier_flopjaw", context)
  PrecacheResource("particle_folder", "particles/econ/courier/courier_lockjaw", context)
  PrecacheResource("particle_folder", "particles/econ/courier/courier_mechjaw", context)
  PrecacheResource("particle_folder", "particles/econ/courier/courier_trapjaw", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/antimage", context)
  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  PrecacheModel("models/units/ironman/ironman.vmdl", context)

  -- Sounds can precached here like anything else
  PrecacheResource("soundfile", "soundevents/game_sounds_items.vsndevts", context)

  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)

  PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
  PrecacheUnitByNameSync("npc_dota_hero_beastmaster", context)
  PrecacheUnitByNameSync("npc_dota_hero_windrunner", context)
  PrecacheUnitByNameSync("npc_dota_hero_sniper", context)
  PrecacheUnitByNameSync("npc_dota_hero_drow_ranger", context)

  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_luna.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_treant.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_obsidian_destroyer.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_silencer.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lich.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_skeletonking.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds.vsndevts",context)
end

-- Create the game mode when we activate
function Activate()
  GameRules.ZIV = ZIV()
  GameRules.ZIV:InitZIV()
end

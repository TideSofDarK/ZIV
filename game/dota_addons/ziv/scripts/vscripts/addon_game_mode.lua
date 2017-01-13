-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('ziv')

function Precache( context )
  PrecacheResource("particle", "particles/ziv_creep_modifier_color.vpcf", context)
  PrecacheResource("particle", "particles/ziv_creep_lord_modifier_regen_aura.vpcf", context)
  PrecacheResource("particle_folder", "particles/items", context)

  PrecacheResource("particle_folder", "particles/econ/courier/courier_flopjaw", context)
  PrecacheResource("particle_folder", "particles/econ/courier/courier_lockjaw", context)
  PrecacheResource("particle_folder", "particles/econ/courier/courier_mechjaw", context)
  PrecacheResource("particle_folder", "particles/econ/courier/courier_trapjaw", context)
  
  local wearables = LoadKeyValues("scripts/kv/DefaultWearables.kv")
  for k,v in pairs(wearables) do
    for k2,v2 in pairs(v) do
      PrecacheModel(v2, context)
    end
  end

  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
  PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
  PrecacheUnitByNameSync("npc_dota_hero_beastmaster", context)
  PrecacheUnitByNameSync("npc_dota_hero_windrunner", context)
  PrecacheUnitByNameSync("npc_dota_hero_sniper", context)
  PrecacheUnitByNameSync("npc_dota_hero_drow_ranger", context)
  PrecacheUnitByNameSync("npc_dota_hero_sniper", context)
  PrecacheUnitByNameSync("npc_dota_hero_sven", context)

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
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds_items.vsndevts",context)
  PrecacheResource("soundfile","soundevents/game_sounds.vsndevts",context)
end

-- Create the game mode when we activate
function Activate()
  GameRules.ZIV = ZIV()
  GameRules.ZIV:InitZIV()

  SendToServerConsole( 'dota_create_fake_clients 3' )
end

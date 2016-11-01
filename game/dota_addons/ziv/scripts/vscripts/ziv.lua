ZIV_DEBUG_SPEW = false 

if ZIV == nil then
    DebugPrint( '[ZIV] creating ziv game mode' )
    _G.ZIV = class({})
end

require('libraries/timers')
require('libraries/physics')
require('libraries/projectiles')
require('libraries/notifications')
require('libraries/animations')
require('libraries/attachments')
require('libraries/wearables')
require('libraries/maths')
require('libraries/popups')
require('libraries/playertables')
require('libraries/worldpanels')
require('libraries/modmaker')
require('libraries/traps')
require('libraries/particles')
require('libraries/random')
require('libraries/pseudoRNG')
require('libraries/abilities')
require('libraries/keyvalues')
require('libraries/ai')
require('libraries/containers')
require('libraries/attributes')

require('internal/ziv')
require('internal/events')

require('items/items')
require('items/trade')
require('items/socketing')
require('items/crafting')
require('items/equipment')
require('items/vials')
require('items/runes')

require('gamesetup')
require('damage')
require('characters')
require('controls')
require('settings')
require('events')
require('filters')
require('director')
require('loot')
require('minimap')
require('balance')
require('debug_panel')
require('commands')
require('libraries/network')
require('network')

require('scenarios/temple')

LinkLuaModifier("modifier_custom_attack", "abilities/tools/modifier_custom_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fade_out_in", "abilities/tools/modifier_fade_out_in.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fade_out", "abilities/tools/modifier_fade_out.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_transparent", "abilities/tools/modifier_transparent.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_disable_auto_attack", "abilities/tools/modifier_disable_auto_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smooth_floating", "abilities/tools/modifier_smooth_floating.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_command_restricted", "abilities/tools/modifier_command_restricted.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_ai", "abilities/tools/modifier_boss_ai.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hide", "abilities/tools/modifier_hide.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_witch_doctor_curse_debuff", "abilities/heroes/witch_doctor/modifier_witch_doctor_curse_debuff.lua", LUA_MODIFIER_MOTION_NONE)

function ZIV:PostLoadPrecache()
  DebugPrint("[ZIV] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

function ZIV:OnFirstPlayerLoaded()
  DebugPrint("[ZIV] First Player has loaded")
end

function ZIV:OnAllPlayersLoaded()
  DebugPrint("[ZIV] All Players have loaded into the game")

  Timers:CreateTimer(1.0, function () 
    DoToAllPlayers(function ( player )
      CustomNetTables:SetTableValue( "settings", tostring(player:GetPlayerID()), {
        CustomSettingDamage = ZIV_CustomSettingDamage_DEFAULT, 
        CustomSettingAutoEquip = ZIV_CustomSettingAutoEquip_DEFAULT,
        CustomSettingShowTooltip = ZIV_CustomSettingShowTooltip_DEFAULT,
        CustomSettingControls = ZIV_CustomSettingControls_DEFAULT,
        CustomSettingMinimap = ZIV_CustomSettingMinimap_DEFAULT,
        })
    end)

    PlayerTables:CreateTable("kvs", { 
      items = ZIV.ItemKVs,
      heroes = ZIV.HeroesKVs,
      abilities = ZIV.AbilityKVs,
      units = ZIV.UnitKVs,
      presets = ZIV.PresetsKVs,
      recipes = ZIV.RecipesKVs,
      attributes = ZIV.AttributesKVs
      }, true)
    end)
end

function ZIV:OnHeroInGame(hero)
  DebugPrint("[ZIV] Hero spawned in game for first time -- " .. hero:GetUnitName())

  Timers:CreateTimer(function (  )
    if hero:IsIllusion() then return end

    local pid = hero:GetPlayerID()
    local player = PlayerResource:GetPlayer(pid)

    local hero_name = hero:GetUnitName()

    Timers:CreateTimer(function ()
      AddFOWViewer(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero:GetCurrentVisionRange(), 0.03, false)
      return 0.03
    end)
  end)
end

function ZIV:OnGameInProgress()
  DebugPrint("[ZIV] The game has officially begun")

  if Director.scenario then
    Director.scenario:NextStage()
  end

  Timers:CreateTimer(
    function()
      ZIV.TRUE_TIME = ZIV.TRUE_TIME + 0.03
      return 0.03
    end)

  Timers:CreateTimer(1.0, -- Hero statuses for UI
    function()
      local players = {}
      for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
          if not PlayerResource:IsBroadcaster(playerID) then
            local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
            if hero then
              local status_table = {}
              status_table["str"] = hero:GetStrength()
              status_table["agi"] = hero:GetAgility()
              status_table["int"] = hero:GetIntellect()
              status_table["damage"] = hero:GetAverageTrueAttackDamage(hero)
              CustomNetTables:SetTableValue("hero_status", tostring(playerID), status_table)
            end
          end
        end
      end

      return 0.5
    end)
end

function ZIV:InitZIV()
  ZIV = self
  DebugPrint('[ZIV] Starting to load ZIV ziv...')

  ZIV:_InitZIV()

  Convars:RegisterCommand( "print_hero_stats", Dynamic_Wrap(ZIV, 'PrintHeroStats'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "ai",   Dynamic_Wrap(ZIV, 'AddItemToContainer'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "sp",   Dynamic_Wrap(ZIV, 'SpawnBasicPack'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "sbd",  Dynamic_Wrap(ZIV, 'SpawnBasicDrop'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "mki",  Dynamic_Wrap(ZIV, 'MakeHeroInvisible'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "amth", Dynamic_Wrap(ZIV, 'AddModifierToHero'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "pcc",  Dynamic_Wrap(ZIV, 'PrintCreepCount'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "aath",  Dynamic_Wrap(ZIV, 'AddAbilityToHero'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "vt",  Dynamic_Wrap(ZIV, 'Test'), "", FCVAR_CHEAT )

  ZIV.ItemKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  ZIV.AbilityKVs = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  ZIV.UnitKVs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  ZIV.HeroesKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  ZIV.HerolistKVs = LoadKeyValues("scripts/npc/herolist.txt")
  ZIV.RecipesKVs = LoadKeyValues("scripts/kv/Recipes.kv")
  ZIV.PresetsKVs = LoadKeyValues("scripts/kv/CharacterPresets.kv")
  ZIV.AttributesKVs = LoadKeyValues("scripts/kv/Attributes.kv")
  ZIV.CaptionsKVs = LoadKeyValues("scripts/kv/Captions.kv")

  SendToServerConsole("dota_surrender_on_disconnect 0")
  SendToServerConsole( 'customgamesetup_set_auto_launch_delay 300' )
  Convars:SetInt( 'dota_auto_surrender_all_disconnected_timeout', 7200 )

  GameSetup:Init()

  Filters:Init()
  Characters:Init() 
  Director:Init()
  Items:Init()
  Trade:Init()
  Loot:Init()
  Damage:Init()
  Debug:Init()
  Controls:Init()

  Attributes:Init()

  -- Dynamic modifiers
  require("modifiers")
end

if LOADED then
  return
end
LOADED = true

ZIV.TRUE_TIME = 0
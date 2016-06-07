ZIV_DEBUG_SPEW = false 

if ZIV == nil then
    DebugPrint( '[ZIV] creating ziv game mode' )
    _G.ZIV = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- Some jerky math stuff
require('libraries/maths')
-- Popup particles
require('libraries/popups')
-- Containers
require('libraries/playertables')
-- Worldpanels
require('libraries/worldpanels')
-- Modmaker
require('libraries/modmaker')
-- Traps
require('libraries/traps')
-- Particles
require('libraries/particles')
-- Damage
require('libraries/damage')
-- Random
require('libraries/random')
require('libraries/PseudoRNG')
-- Abilities
require('libraries/abilities')
-- AI
require('libraries/ai')
-- Items
require('items/socketing')
require('items/crafting')
require('items/equipment')
require('items/vials')
require('items/runes')

-- Character management
require('characters')

-- These internal libraries set up ziv's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/ziv')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core ziv files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core ziv files.
require('events')

require('filters')

require('director')
require('loot')

require('minimap')

-- Containers
require('libraries/containers')

-- Balance variables
require('balance')

-- Debug commands
require('commands')

LinkLuaModifier("modifier_custom_attack", "libraries/modifiers/modifier_custom_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fade_out_in", "libraries/modifiers/modifier_fade_out_in.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fade_out", "libraries/modifiers/modifier_fade_out.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_transparent", "libraries/modifiers/modifier_transparent.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_disable_auto_attack", "libraries/modifiers/modifier_disable_auto_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smooth_floating", "libraries/modifiers/modifier_smooth_floating.lua", LUA_MODIFIER_MOTION_NONE)

function ZIV:OpenInventory(args)
  local pid = args.PlayerID
  ZIV.INVENTORY[pid]:Open(pid)
end

function ZIV:PostLoadPrecache()
  DebugPrint("[ZIV] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

function ZIV:OnFirstPlayerLoaded()
  DebugPrint("[ZIV] First Player has loaded")

  CustomGameEventManager:RegisterListener("OpenInventory", Dynamic_Wrap(ZIV, "OpenInventory"))
  CustomGameEventManager:RegisterListener("DefaultInventory", Dynamic_Wrap(ZIV, "DefaultInventory"))

  Containers:SetDisableItemLimit(true)
  Containers:UsePanoramaInventory(false)
end

function ZIV:OnAllPlayersLoaded()
  DebugPrint("[ZIV] All Players have loaded into the game")
  
  -- Timers:CreateTimer(1.0, function ()
    DoToAllPlayers(function ( player )
      CustomNetTables:SetTableValue( "settings", tostring(player:GetPlayerID()), {
        CustomSettingDamage = ZIV_CustomSettingDamage_DEFAULT, 
        CustomSettingAutoEquip = ZIV_CustomSettingAutoEquip_DEFAULT,
        CustomSettingShowTooltip = ZIV_CustomSettingShowTooltip_DEFAULT,
        CustomSettingControls = ZIV_CustomSettingControls_DEFAULT
        })
    end)

    PlayerTables:CreateTable("kvs", { 
      items = DeepCopy(ZIV.ItemKVs),
      heroes = DeepCopy(ZIV.HeroesKVs),
      abilities = DeepCopy(ZIV.AbilityKVs),
      units = DeepCopy(ZIV.UnitKVs),
      presets = DeepCopy(ZIV.PresetsKVs)
     }, true)

    CustomGameEventManager:Send_ServerToAllClients( "ziv_set_recipes_kvs", ZIV.RecipesKVs )

    SendToServerConsole("dota_combine_models 0")
  -- end)
end

function ZIV:OnHeroInGame(hero)
  DebugPrint("[ZIV] Hero spawned in game for first time -- " .. hero:GetUnitName())

  Timers:CreateTimer(function (  )
    if hero:IsIllusion() then return end

    local pid = hero:GetPlayerID()
    local player = PlayerResource:GetPlayer(pid)

    local hero_name = hero:GetUnitName()

    local camera_target = CreateUnitByName("npc_dummy_unit",hero:GetAbsOrigin() + Vector(0,325,0),false,hero,hero,hero:GetTeamNumber())
    InitAbilities(camera_target)

    Timers:CreateTimer(function ()
      if GetZIVSpecificSetting(pid, "Controls") == false then
        PlayerResource:SetCameraTarget(pid, camera_target)
      else
        PlayerResource:SetCameraTarget(pid, nil)
      end
      
      local heroZ = math.floor(hero:GetAbsOrigin().z / 128)
      local offset = ZIV_CameraZValueA - (camera_target:GetAbsOrigin().z/25)
      camera_target:SetAbsOrigin(hero:GetAbsOrigin() + Vector(-offset,offset,0))
      return 0.03
    end)
  end)
end

function ZIV:OnGameInProgress()
  DebugPrint("[ZIV] The game has officially begun")

  if Director.scenario then
    Director.scenario:NextStage()
  end

  Timers:CreateTimer( -- Start this timer 30 game-time seconds later
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
              status_table["damage"] = hero:GetAverageTrueAttackDamage()
              CustomNetTables:SetTableValue("hero_status", tostring(playerID), status_table)
            end
          end
        end
      end

      return 0.5
    end)

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
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

  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( ZIV, "FilterExecuteOrder" ), self )
  GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( ZIV, "DamageFilter" ), self )

  ZIV.ItemKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  ZIV.AbilityKVs = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  ZIV.UnitKVs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  ZIV.HeroesKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  ZIV.HerolistKVs = LoadKeyValues("scripts/npc/herolist.txt")
  ZIV.RecipesKVs = LoadKeyValues("scripts/kv/Recipes.kv")
  ZIV.PresetsKVs = LoadKeyValues("scripts/kv/CharacterPresets.kv")

  Director:Init()
  Loot:Init()
end

if LOADED then
  return
end
LOADED = true

ZIV.TRUE_TIME = 0

ZIV.INVENTORY = {}
lootSpawns = nil
itemDrops = nil
privateBankEnt = nil
sharedBankEnt = nil
contShopRadEnt = nil
contShopDireEnt = nil
itemShopEnt = nil

contShopRad = nil
contShopDire = nil
itemShop = nil
sharedBank = nil
privateBank = {}

defaultInventory = {}
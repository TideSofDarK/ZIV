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
-- Runes
require('libraries/runes')
-- Abilities
require('libraries/abilities')
-- AI
require('libraries/ai')
-- Items
require('items/crafting')
require('items/equipment')

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

LinkLuaModifier("modifier_custom_attack", "libraries/modifiers/modifier_custom_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fade_out", "libraries/modifiers/modifier_fade_out.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_transparent", "libraries/modifiers/modifier_transparent.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_disable_auto_attack", "libraries/modifiers/modifier_disable_auto_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smooth_floating", "libraries/modifiers/modifier_smooth_floating.lua", LUA_MODIFIER_MOTION_NONE)

function ZIV:OpenInventory(args)
  local pid = args.PlayerID
  ZIV.pidInventory[pid]:Open(pid)
end

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function ZIV:PostLoadPrecache()
  DebugPrint("[ZIV] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitZIV() but needs to be done before everyone loads in.
]]
function ZIV:OnFirstPlayerLoaded()
  DebugPrint("[ZIV] First Player has loaded")

  CustomGameEventManager:RegisterListener("OpenInventory", Dynamic_Wrap(ZIV, "OpenInventory"))
  CustomGameEventManager:RegisterListener("DefaultInventory", Dynamic_Wrap(ZIV, "DefaultInventory"))

  Containers:SetDisableItemLimit(true)
  Containers:UsePanoramaInventory(false)
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function ZIV:OnAllPlayersLoaded()
  DebugPrint("[ZIV] All Players have loaded into the game")
  Timers:CreateTimer(1.0, function ()
    
    for k,v in pairs(ZIV.HeroesKVs) do
      CustomNetTables:SetTableValue("hero_kvs", k, v)
      -- DeepPrintTable(CustomNetTables:GetTableValue("hero_kvs", k))
    end

    for k,v in pairs(ZIV.ItemKVs) do
      CustomNetTables:SetTableValue("item_kvs", k, v)
    end

    CustomGameEventManager:Send_ServerToAllClients( "ziv_set_heroes_kvs", ZIV.HeroesKVs )
    CustomGameEventManager:Send_ServerToAllClients( "ziv_set_herolist", ZIV.HerolistKVs )
    CustomGameEventManager:Send_ServerToAllClients( "ziv_set_recipes_kvs", ZIV.RecipesKVs )

    SendToServerConsole("dota_combine_models 0")
  end)
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function ZIV:OnHeroInGame(hero)
  DebugPrint("[ZIV] Hero spawned in game for first time -- " .. hero:GetUnitName())

  Timers:CreateTimer(function (  )
    if hero:IsIllusion() then return end

    local pid = hero:GetPlayerID()
    local player = PlayerResource:GetPlayer(pid)

    -- local c = Containers:CreateContainer({
    --   layout =      {3,3,3,3,3},
    --   skins =       {}, --
    --   headerText =  "Bag",
    --   pids =        {pid},
    --   entity =      hero,
    --   closeOnOrder = false,
    --   position =    "1200px 600px 0px",
    --   OnDragWorld = true,
    -- })

    local c = Containers:CreateContainer({
      layout =      {3,3,3,3,3},
      skins =       {"Hourglass"},
      headerText =  "Bag",
      pids =        {pid},
      entity =      hero,
      closeOnOrder =false,
      position =    "75% 25%",
      OnDragWorld = true
    })

    ZIV.pidInventory[pid] = c

    local item = CreateItem("item_gem_malachite", hero, hero)
    c:AddItem(item)

    item = CreateItem("item_gem_topaz", hero, hero)
    c:AddItem(item)

    item = CreateItem("item_basic_parts", hero, hero)
    c:AddItem(item)

    item = CreateItem("item_basic_leather", hero, hero)
    c:AddItem(item, 3)

    defaultInventory[pid] = true
    Containers:SetDefaultInventory(hero, c)

    local pack = CreateItem("item_containers_lua_pack", hero, hero)
    pack.container = c
    hero:AddItem(pack)

    local hero_name = hero:GetUnitName()

    local camera_target = CreateUnitByName("npc_dummy_unit",hero:GetAbsOrigin() + Vector(0,325,0),false,hero,hero,hero:GetTeamNumber())
    InitAbilities(camera_target)

    PlayerResource:SetCameraTarget(pid, camera_target)

    Timers:CreateTimer(function ()
      camera_target:SetAbsOrigin(hero:GetAbsOrigin() + Vector(0,-275,0))
      return 0.03
    end)
  end)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
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

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function ZIV:InitZIV()
  ZIV = self
  DebugPrint('[ZIV] Starting to load ZIV ziv...')

  ZIV:_InitZIV()

  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  Convars:RegisterCommand( "print_hero_stats", Dynamic_Wrap(ZIV, 'PrintHeroStats'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "ai", Dynamic_Wrap(ZIV, 'AddItemToContainer'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "sp", Dynamic_Wrap(ZIV, 'SpawnBasicPack'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "sbd", Dynamic_Wrap(ZIV, 'SpawnBasicDrop'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "mki", Dynamic_Wrap(ZIV, 'MakeHeroInvisible'), "", FCVAR_CHEAT )
  Convars:RegisterCommand( "amth", Dynamic_Wrap(ZIV, 'AddModifierToHero'), "", FCVAR_CHEAT )

  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( ZIV, "FilterExecuteOrder" ), self )
  GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( ZIV, "DamageFilter" ), self )

  ZIV.ItemKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  ZIV.AbilityKVs = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  ZIV.UnitKVs = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  ZIV.HeroesKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  ZIV.HerolistKVs = LoadKeyValues("scripts/npc/herolist.txt")
  ZIV.RecipesKVs = LoadKeyValues("scripts/kv/Recipes.kv")

  Director:Init()
  Loot:Init()
end

function ZIV:AddModifierToHero(modifier)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      hero:AddNewModifier(hero,nil,modifier,{})
    end
  end
end

function ZIV:MakeHeroInvisible()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      hero:AddNewModifier(hero,nil,"modifier_persistent_invisibility",{})
    end
  end
end

function ZIV:PrintHeroStats()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      print("MR: "..tostring(hero:GetMagicalArmorValue()))
      print("FR: "..tostring(hero:GetModifierStackCount("modifier_fire_resistance",nil)))
      print("CR: "..tostring(hero:GetModifierStackCount("modifier_cold_resistance",nil)))
      print("LR: "..tostring(hero:GetModifierStackCount("modifier_lightning_resistance",nil)))
      print("DR: "..tostring(hero:GetModifierStackCount("modifier_dark_resistance",nil)))

      print("STR: "..tostring(hero:GetStrength()))
      print("AGI: "..tostring(hero:GetAgility()))
      print("INT: "..tostring(hero:GetIntellect()))
      print("AS: "..tostring(hero:GetAttackSpeed()))
      for i=0,hero:GetModifierCount() do
        print(hero:GetModifierNameByIndex(i), hero:GetModifierStackCount(hero:GetModifierNameByIndex(i), hero))
      end
      for i=0,16 do
        local abil = hero:GetAbilityByIndex(i)
        if abil then
          print(abil:GetName())
        end
      end
    end
  end
end

function ZIV:AddItemToContainer(item, count)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      local item = CreateItem(item, hero, hero)
      ZIV.pidInventory[playerID]:AddItem(item, tonumber(count) or nil)
    end
  end
end

function ZIV:SpawnBasicPack(count)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      
      Director:SpawnPack(
        {
          Level = 1,
          SpawnBasic = true,
          Count = tonumber(count) or 10,
          Position = hero:GetAbsOrigin(),
          LordModifier = "ziv_creep_lord_modifier_regen_aura",
          SpawnLord = true
        }
      )
    end
  end
end

function ZIV:SpawnBasicDrop(rarity)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()

      Loot:CreateChest( hero:GetAbsOrigin(), tonumber(rarity) )
    end
  end
end

if LOADED then
  return
end
LOADED = true

ZIV.TRUE_TIME = 0

ZIV.pidInventory = {}
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
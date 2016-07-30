if Characters == nil then
    _G.Characters = class({})
end

--[[
  Character structure is:

  I - During creation 
  character_name  -- a character name given by player
  hero_name       -- e.g."npc_dota_hero_axe"
  abilities       -- array of abilities
  preset          -- array of abilities + equipped items

  II - After creation
  items           -- inventory
  equipment
]]

Characters.current_session_characters = Characters.current_session_characters or {}

function Characters:Init() 
  CustomGameEventManager:RegisterListener("ziv_spawn_character", Dynamic_Wrap(Characters, 'OnSpawnCharacter'))
  CustomGameEventManager:RegisterListener("ziv_open_inventory", Dynamic_Wrap(Characters, "OnOpenInventory"))

  Containers:SetDisableItemLimit(true)
  Containers:UsePanoramaInventory(false)
end

function Characters:CreateCharacter( args )
  local player = PlayerResource:GetPlayer(args.PlayerID)

  local new_character_table             = {}
  new_character_table.character_name    = args.character_name
  new_character_table.hero_name         = args.hero_name
  new_character_table.abilities         = args.abilities
  new_character_table.preset            = args.preset

  new_character_table.equipment         = {}

  local presets = ZIV.PresetsKVs[new_character_table.hero_name]
  if presets and presets[new_character_table.preset] then
    for item_name,sockets in pairs(presets[new_character_table.preset]) do
      local item = CreateItem(item_name, player, player)

      if GetTableLength(sockets) > 0 then
        for seed,tool_name in pairs(sockets) do
          local tool = CreateItem(tool_name, player, player)
          Socketing:OnFortify({
           pID=-1,
           item=item:entindex(),
           tool=tool:entindex(),
           seed=seed
           })
        end
      end

      table.insert(new_character_table.equipment, { item = item_name, fortify_modifiers = item.fortify_modifiers })
    end
  end

  return new_character_table
end

function Characters:SpawnCharacter( args )
  local pID = tonumber(args.pID)
  local hero_name = args.hero_name
  local equipment = args.equipment
  local inventory = args.inventory

  local abilities = args.abilities

  PrecacheUnitByNameAsync(hero_name, function (  )
    local hero = CreateHeroForPlayer(hero_name, PlayerResource:GetPlayer(pID))

    for i=0,16 do
      local abil = hero:GetAbilityByIndex(i)
      if abil and abil:GetName() then
        hero:RemoveAbility(abil:GetName())
      end
    end
    
    for i=0,GetTableLength(abilities) do
      hero:AddAbility(abilities[tostring(i)])
    end

    Characters:CreateCharacterInventory( pID, hero )

    if equipment then
      for k,v in pairs(equipment) do
        local item_name = v.item_name
        local item = CreateItem(item_name, hero, hero)
        item.fortify_modifiers = v.fortify_modifiers
        item.built_in_modifiers = v.built_in_modifiers
        
        Timers:CreateTimer(function ()
          Characters:GetInventory(pID):AddItem(item)
          Characters:GetInventory(pID):ActivateItem(hero, item, pID)
          end)
      end
    end

    if inventory then
      for k,v in pairs(inventory) do
        local item_name = v.item_name
        local item = CreateItem(item_name, hero, hero)
        item.fortify_modifiers = v.fortify_modifiers
        item.built_in_modifiers = v.built_in_modifiers

        Timers:CreateTimer(0.5, function () -- wait a bit longer so add inventory items only once all equipment is on
          Characters:GetInventory(pID):AddItem(item)
          end)
      end
    end

    Characters:InitCharacter( hero )
  end, pID)
end

function Characters:CreateCharacterInventory( pID, hero )
    local inventory = Containers:CreateContainer({
      layout =      {3,3,3,3,3},
      skins =       {"Hourglass"},
      headerText =  "Bag",
      pids =        {pID},
      entity =      hero,
      closeOnOrder =false,
      position =    "75% 25%",
      OnDragWorld = true
    })

    hero.inventory = inventory

    Containers:SetDefaultInventory(hero, inventory)
end

function Characters:InitCharacter( hero )
    hero:AddAbility("ziv_passive_hero")
    hero:AddAbility("ziv_stats_bonus_fix")
    hero:AddAbility("ziv_hero_normal_hpbar_behavior")

    InitAbilities(hero)

    hero:AddNewModifier(hero,nil,"modifier_disable_auto_attack",{})

    -- PseudoRNG stuff
    hero.loot_rng = PseudoRNG.create( 0.5 )
    hero.vial_rng = PseudoRNG.create( ZIV_VIAL_CHANCE )
    hero.vial_choice_rng = ChoicePseudoRNG.create( {ZIV_HP_VIAL_CHANCE, ZIV_SP_VIAL_CHANCE} )

    Characters.current_session_characters[hero:GetPlayerID()] = hero
end

function Characters:GetInventory(pID)
  if Characters.current_session_characters[pID] then
    return Characters.current_session_characters[pID].inventory
  elseif PlayerResource:GetPlayer(pID) then
    return PlayerResource:GetPlayer(pID):GetAssignedHero().inventory
  end
end

function Characters:OnOpenInventory(args)
  local pID = args.PlayerID
  Characters:GetInventory(pID):Open(pID)
end
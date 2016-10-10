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
  PlayerTables:CreateTable("characters", {characters=GeneratePlayerArray("player")}, true)

  CustomGameEventManager:RegisterListener("ziv_get_containers", Dynamic_Wrap(Characters, "SendPlayerContainers"))

  Containers:SetDisableItemLimit(true)
  Containers:UsePanoramaInventory(false)
end

function Characters:CreateCharacter( args )
  local player = PlayerResource:GetPlayer(args.PlayerID)

  local new_character_table             = args
  new_character_table.equipment         = {}

  local presets = ZIV.PresetsKVs[new_character_table.hero_name]
  if presets and presets[new_character_table.preset] then
    for item_name,sockets in pairs(presets[new_character_table.preset]) do
      local item = Items:Create(item_name, player)

      if GetTableLength(sockets) > 0 then
        for seed,tool_name in pairs(sockets) do
          local tool = Items:Create(tool_name, player)
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

  SU:RecordCharacter( new_character_table )

  return new_character_table
end

function Characters:SpawnCharacter( pID, args )
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
        local item = Items:Create(v.item, hero)
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
        local item = Items:Create(v.item, hero)
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
      layout =      {5,5,5,5,5},
      skins =       {"Inventory"},
      headerText =  "Bag",
      pids =        {pID},
      entity =      hero,
      closeOnOrder =false,
      position =    "0px 0px 0px",
      OnDragWorld = true
    })

    hero.inventory = inventory

    local equipment = Equipment:CreateContainer( hero )

    hero.equipment = equipment

    Containers:SetDefaultInventory(hero, inventory)
end

function Characters:InitCharacter( hero )
  Characters.current_session_characters[hero:GetPlayerID()] = hero

  hero:AddAbility("ziv_passive_hero")
  hero:AddAbility("ziv_hero_normal_hpbar_behavior")

  InitAbilities(hero)

  Attributes:ModifyBonuses(hero)

  -- PseudoRNG stuff

  hero.loot_rng         = PseudoRNG.create( Loot.LOOT_CHANCE )
  hero.loot_rarity_rng  = ChoicePseudoRNG.create( Loot.RARITY_CHANCES )
  hero.vial_rng         = PseudoRNG.create( ZIV_VIAL_CHANCE )
  hero.vial_choice_rng  = ChoicePseudoRNG.create( {ZIV_HP_VIAL_CHANCE, ZIV_SP_VIAL_CHANCE} )

  hero:AddNewModifier(hero,nil,"modifier_disable_auto_attack",{})

  -- Spawn effects

  hero:AddNewModifier(hero,nil,"modifier_hide",{duration = Director.HERO_SPAWN_TIME})
  hero:AddNewModifier(hero,nil,"modifier_command_restricted",{duration = Director.HERO_SPAWN_TIME})

  local particle = ParticleManager:CreateParticle( "particles/items2_fx/teleport_end.vpcf", PATTACH_CUSTOMORIGIN, nil )
  ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin() + Vector(0,0,30))
  ParticleManager:SetParticleControl(particle, 1, hero:GetAbsOrigin() + Vector(0,0,30))
  ParticleManager:SetParticleControl(particle, 2, Vector(40,40,200))
  ParticleManager:SetParticleControl(particle, 3, hero:GetAbsOrigin() + Vector(0,0,30))

  hero:EmitSound("Portal.Loop_Appear")

  Timers:CreateTimer(Director.HERO_SPAWN_TIME, function (  )
    hero:EmitSound("Portal.Hero_Disappear")
    hero:StopSound("Portal.Loop_Appear")

    ParticleManager:DestroyParticle(particle, false)
  end)
end

function Characters:GetInventory(pID)
  if Characters.current_session_characters[pID] then
    return Characters.current_session_characters[pID].inventory
  elseif PlayerResource:GetPlayer(pID) then
    return PlayerResource:GetPlayer(pID):GetAssignedHero().inventory
  end
end

function Characters:GetHero(pID)
  return Characters.current_session_characters[pID]
end

function Characters:SendPlayerContainers(args)
  local pID = args.PlayerID
  local hero = Characters:GetHero(pID)

  CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pID), "ziv_set_containers", { equipmentContainerID = hero.equipment.id, inventoryContainerID = hero.inventory.id } )
end
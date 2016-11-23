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
end

function Characters:CreateCharacter( args )
  local player = PlayerResource:GetPlayer(args.PlayerID)

  local new_character_table             = args
  new_character_table.equipment         = {}

  local presets = ZIV.PresetsKVs[new_character_table.hero_name]
  if presets and presets[new_character_table.preset] then
    for item_name,sockets in pairs(presets[new_character_table.preset]) do
      local item = Items:Create(item_name, player)

      Loot:AddModifiers( item )

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

      table.insert(new_character_table.equipment, { item = item_name, built_in_modifiers = item.built_in_modifiers, fortify_modifiers = item.fortify_modifiers })
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

    Characters:SetupCharacterContainers( pID, hero )

    if inventory then
      for k,v in pairs(inventory) do
        local item = Items:Create(v.item, hero)
        item.fortify_modifiers = v.fortify_modifiers
        item.built_in_modifiers = v.built_in_modifiers

        Items:UpdateItem(item)

        Timers:CreateTimer(0.5, function () -- wait a bit longer so add inventory items only once all equipment is on
          Characters:GetInventory(pID):AddItem(item)
        end)
      end
    end

    if equipment then
      for k,v in pairs(equipment) do
        local item = Items:Create(v.item, hero)
        item.fortify_modifiers = v.fortify_modifiers
        item.built_in_modifiers = v.built_in_modifiers

        Items:UpdateItem(item)
        
        Timers:CreateTimer(function ()
          local item_slot = ZIV.ItemKVs[v.item]["Slot"]
          for i,slot in ipairs(KeyValues:Split(ZIV.HeroesKVs[hero:GetUnitName()]["EquipmentSlots"], ';')) do
            if not hero.equipment:GetItemInSlot(i) and string.match(slot, item_slot) then
              hero.equipment:AddItem(item, i)
              Equipment:Equip( hero, item )
              break
            end
          end
        end)
      end
    end

    Characters:InitCharacter( hero )
  end, pID)
end

function Characters:SetupCharacterContainers( pID, hero )
  hero.inventory = Equipment:CreateInventory( hero )
  Containers:SetDefaultInventory(hero, hero.inventory)

  hero.equipment = Equipment:CreateContainer( hero )
end

function Characters:InitCharacter( hero )
  Characters.current_session_characters[hero:GetPlayerID()] = hero

  hero:AddAbility("ziv_passive_hero")
  hero:AddAbility("ziv_hero_normal_hpbar_behavior")

  InitAbilities(hero)

  Attributes:ModifyBonuses(hero)

  Damage:InitHero( hero )

  -- PseudoRNG stuff

  hero.evasion_rng      = PseudoRNG.create( 0.05 )

  hero.loot_rng         = PseudoRNG.create( Loot.LOOT_CHANCE )
  hero.loot_rarity_rng  = ChoicePseudoRNG.create( Loot.RARITY_CHANCES )
  hero.vial_rng         = PseudoRNG.create( ZIV_VIAL_CHANCE )
  hero.vial_choice_rng  = ChoicePseudoRNG.create( {ZIV_HP_VIAL_CHANCE, ZIV_SP_VIAL_CHANCE} )

  hero:AddNewModifier(hero,nil,"modifier_disable_auto_attack",{})

  Wearables:InitDefaultWearables(hero)

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
  
  PlayerTables:SetTableValue("characters", "status", {})
  Timers:CreateTimer(0.0, function()
    local status = {}
    status["str"] = hero:GetStrength()
    status["agi"] = hero:GetAgility()
    status["int"] = hero:GetIntellect()
    status["damage"] = hero:GetAverageTrueAttackDamage(hero)

    PlayerTables:SetSubTableValue("characters", "status", hero:GetPlayerOwnerID(), status)

    return 0.5
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
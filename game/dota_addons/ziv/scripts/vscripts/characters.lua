if Characters == nil then
    _G.Characters = class({})
end

Characters.current_session_characters = Characters.current_session_characters or {}

function Characters:Init() 
  CustomGameEventManager:RegisterListener("ziv_spawn_character", Dynamic_Wrap(Characters, 'OnSpawnCharacter'))
  CustomGameEventManager:RegisterListener("ziv_open_inventory", Dynamic_Wrap(Characters, "OnOpenInventory"))

  Containers:SetDisableItemLimit(true)
  Containers:UsePanoramaInventory(false)
end

function Characters:OnSpawnCharacter( args )
  local pID = tonumber(args.pID)
  local player = PlayerResource:GetPlayer(pID)
  local hero_name = args.hero_name
  local preset = ZIV.PresetsKVs[hero_name]

  local abilities = args.abilities

  PrecacheUnitByNameAsync(hero_name, function (  )
    local hero = CreateHeroForPlayer(hero_name, player)

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

    if preset and preset[args.preset] then
      preset = preset[args.preset]
      Timers:CreateTimer(function (  )
        for item_name,sockets in pairs(preset) do
          local item = CreateItem(item_name, hero, hero)

          if GetTableLength(sockets) > 0 then
            for seed,tool_name in pairs(sockets) do
              local tool = CreateItem(tool_name, hero, hero)
              Socketing:OnFortify( {
                pID=-1,
                item=item:entindex(),
                tool=tool:entindex(),
                seed=seed
                } )
            end
          end

          Characters:GetInventory(pID):AddItem(item)
          Characters:GetInventory(pID):ActivateItem(hero, item, pID)
        end
      end)
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
  end
end

function Characters:OnOpenInventory(args)
  local pID = args.PlayerID
  Characters:GetInventory(pID):Open(pID)
end
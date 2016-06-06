if Characters == nil then
    _G.Characters = class({})
end

function Characters:OnPlayerCreatedHero( args )
  local pID = tonumber(args.pID)
  local player = PlayerResource:GetPlayer(pID)
  local hero_name = args.hero_name
  local preset = ZIV.PresetsKVs[hero_name][args.preset]

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

    Characters:CreateHeroInventory( pID, hero )

    if preset then
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

          ZIV.INVENTORY[pID]:AddItem(item)
          ZIV.INVENTORY[pID]:ActivateItem(hero, item, pID)
        end
      end)
    end

    Characters:InitHero( hero )
  end, pID)
end

function Characters:CreateHeroInventory( pID, hero )
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

    ZIV.INVENTORY[pID] = inventory

    Containers:SetDefaultInventory(hero, inventory)
end

function Characters:InitHero( hero )
    hero:AddAbility("ziv_passive_hero")
    hero:AddAbility("ziv_stats_bonus_fix")
    hero:AddAbility("ziv_hero_normal_hpbar_behavior")

    InitAbilities(hero)

    hero:AddNewModifier(hero,nil,"modifier_disable_auto_attack",{})

    -- PseudoRNG stuff
    hero.loot_rng = PseudoRNG.create( 0.5 )
    hero.vial_rng = PseudoRNG.create( ZIV_VIAL_CHANCE )
    hero.vial_choice_rng = ChoicePseudoRNG.create( {ZIV_HP_VIAL_CHANCE, ZIV_SP_VIAL_CHANCE} )
end
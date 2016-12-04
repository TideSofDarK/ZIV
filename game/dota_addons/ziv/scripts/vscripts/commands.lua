function ZIV:Test()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()

      
    end
  end
end

function ZIV:PrintCreepCount()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      print("creeps:"..tostring(Director.current_session_creep_count))
      print("entities:"..tostring(#Entities:FindAllInSphere(Vector(0,0,0), 100000)))
      for k,v in pairs(Entities:FindAllInSphere(Vector(0,0,0), 100000)) do
        if v:GetClassname() == "npc_dota_creature" then
          print(v:GetUnitName())
        else
          print(k,v:GetClassname())
        end
      end
    end
  end
end

function ZIV:AddAbilityToHero(ability)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      hero:AddAbility(ability)
      InitAbilities(hero)
    end
  end
end

function ZIV:AddModifierToHero(modifier, stacks)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      hero:AddNewModifier(hero,nil,modifier,{})
      hero:SetModifierStackCount(modifier,hero,tonumber(stacks))
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
      print("-------------HERO STATS------------")
      print("HP: "..tostring(hero:GetHealth()).."/"..tostring(hero:GetMaxHealth()))
      print("EP: "..tostring(hero:GetMana()).."/"..tostring(hero:GetMaxMana()))
      print("-----------------------------------")
      print("MR: "..tostring(hero:GetMagicalArmorValue()))
      print("ARMOR: "..tostring(hero:GetPhysicalArmorValue()))
      print("FR: "..tostring(Damage:GetResist( hero, Damage.FIRE_RESISTANCE )))
      print("CR: "..tostring(Damage:GetResist( hero, Damage.COLD_RESISTANCE )))
      print("LR: "..tostring(Damage:GetResist( hero, Damage.LIGHTNING_RESISTANCE )))
      print("DR: "..tostring(Damage:GetResist( hero, Damage.DARK_RESISTANCE )))
      print("-----------------------------------")
      print("STR: "..tostring(hero:GetStrength()))
      print("AGI: "..tostring(hero:GetAgility()))
      print("INT: "..tostring(hero:GetIntellect()))
      print("-----------------------------------")
      print("AD: "..tostring(hero:GetAverageTrueAttackDamage(hero)))
      print("AS: "..tostring(hero:GetAttackSpeed()))
      print("ApS: "..tostring(hero:GetAttacksPerSecond()))
      print("-----------------------------------")
      print("MODIFIER COUNT: "..tostring(hero:GetModifierCount()))
      print("-----------------------------------")
      for i=0,hero:GetModifierCount() do
        print(hero:GetModifierNameByIndex(i), hero:GetModifierStackCount(hero:GetModifierNameByIndex(i), hero))
      end
      for i=0,16 do
        local abil = hero:GetAbilityByIndex(i)
        if abil then
          print(abil:GetName())
        end
      end
      print("-----------------------------------")
    end
  end
end

function ZIV:AddItemToContainer(item, count)
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      local item = Items:Create(item, hero)
      hero.inventory:AddItem(item, tonumber(count) or nil)
    end
  end
end

function ZIV:SpawnBasicPack(count, pack_type, modifier)
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
          Type = pack_type or "creep",
          Position = hero:GetAbsOrigin(),
          BasicModifier = "ziv_creep_modifier_fire_bomb",
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
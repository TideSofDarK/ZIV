function ZIV:PrintCreepCount()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local hero = cmdPlayer:GetAssignedHero()
      print(Director.current_session_creep_count)
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
      print("HP: "..tostring(hero:GetHealth()).."/"..tostring(hero:GetMaxHealth()))
      print("EP: "..tostring(hero:GetMana()).."/"..tostring(hero:GetMaxMana()))

      print("MR: "..tostring(hero:GetMagicalArmorValue()))
      print("FR: "..tostring(hero:GetModifierStackCount("modifier_fire_resistance",nil)))
      print("CR: "..tostring(hero:GetModifierStackCount("modifier_cold_resistance",nil)))
      print("LR: "..tostring(hero:GetModifierStackCount("modifier_lightning_resistance",nil)))
      print("DR: "..tostring(hero:GetModifierStackCount("modifier_dark_resistance",nil)))

      print("STR: "..tostring(hero:GetStrength()))
      print("AGI: "..tostring(hero:GetAgility()))
      print("INT: "..tostring(hero:GetIntellect()))
      print("AS: "..tostring(hero:GetAttackSpeed()))
      print("MODIFIER COUNT: "..tostring(hero:GetModifierCount()))
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
      local item = Items:Create(item, hero)
      hero.inventory:AddItem(item, tonumber(count) or nil)
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
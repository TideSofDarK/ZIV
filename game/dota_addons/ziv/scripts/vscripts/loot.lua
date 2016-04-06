if Loot == nil then
    _G.Loot = class({})
end

Loot.RARITY_COMMON = 0
Loot.RARITY_MAGIC = 1
Loot.RARITY_RARE = 2
Loot.RARITY_EPIC = 3
Loot.RARITY_LEGENDARY = 4

Loot.RARITY_PARTICLES = {}
Loot.RARITY_PARTICLES[Loot.RARITY_MAGIC] = "particles/ziv_chest_light_magic.vpcf"
Loot.RARITY_PARTICLES[Loot.RARITY_RARE] = "particles/ziv_chest_light_rare.vpcf"
Loot.RARITY_PARTICLES[Loot.RARITY_EPIC] = "particles/ziv_chest_light_epic.vpcf"
Loot.RARITY_PARTICLES[Loot.RARITY_LEGENDARY] = "particles/ziv_chest_light_legendary.vpcf"

Loot.Table = LoadKeyValues('scripts/kv/LootTable.kv')

function IsItemDropped( chance )
  return math.random(100) < chance
end

function Loot:Generate( creep, killer )
  if Loot.Table == nil then
    return
  end
  
  -- Get loot table
  local lootTable = Loot.Table[creep:GetName()]
  if lootTable == nil then
    return
  end

  -- Generate chest
  if IsItemDropped(lootTable.LootChance) then
    local chest = CreateItemOnPositionSync(creep:GetAbsOrigin(), CreateItem("item_basic_chest", nil, nil))
    chest.particles = chest.particles or {}
    chest.Max = lootTable.Max
    chest.Loot = lootTable.Loot

    Physics:Unit(chest)

    chest:SetAbsOrigin(creep:GetAbsOrigin())

    local seed = math.random(0, 360)
    local boost = math.random(0,425)

    local x = ((185 + boost) * math.cos(seed))
    local y = ((185 + boost) * math.sin(seed))

    chest:AddPhysicsVelocity(Vector(x, y, 1100))
    chest:SetPhysicsAcceleration(Vector(0,0,-1700)) 

    local particle = ParticleManager:CreateParticle(Loot.RARITY_PARTICLES[tonumber(rarity)], PATTACH_ABSORIGIN_FOLLOW, chest)
    ParticleManager:SetParticleControl(particle, 0, chest:GetAbsOrigin())

    table.insert(chest.particles, particle)
  end
end

function Loot:AddModifiers(item)
	local modifier_count = item.rarity + math.random(0, 2)
	item.built_in_modifiers = item.built_in_modifiers or {}

	for i=1,modifier_count do
		local seed = math.random(1, GetTableLength(ZIV.AbilityKVs["ziv_fortify_modifiers"]["Modifiers"]))
		local x = 1
		for k,v in pairs(ZIV.AbilityKVs["ziv_fortify_modifiers"]["Modifiers"]) do
			if x == seed then
				item.built_in_modifiers[k] = item.built_in_modifiers[k] or 0
				item.built_in_modifiers[k] = item.built_in_modifiers[k] + math.random(1,12)
				break
			end
			x = x + 1
		end
	end
end

function Loot:RandomItemFromLootTable( lootTable, chest_unit )
  local seed = math.random(100)
  local rarity = nil
  local items = nil
  
  -- Random rarity
  local num = 0
  for k,v in pairs(lootTable) do
    if seed > num and seed <= num + v.Chance then
      rarity = tonumber(k)
      items = v.Items
    end
    
    num = num + v.Chance
  end
  
  -- Random item in group
  local itemName = items[tostring(math.random( #items ))]
  local item = CreateItemOnPositionSync(chest_unit:GetAbsOrigin(), CreateItem(itemName, unit, unit))
  
  if rarity > Loot.RARITY_COMMON then     
    local new_item = item:GetContainedItem()
    new_item.rarity = 0

    if i == count then
      new_item.rarity = rarity
    else
      if math.random(0,1) == 0 then
        new_item.rarity = math.abs(math.random(0,rarity-1))
      end
    end

    if new_item.rarity > 0 then 
      Loot:AddModifiers(new_item)

      local particle = ParticleManager:CreateParticle(Loot.RARITY_PARTICLES[new_item.rarity], PATTACH_ABSORIGIN_FOLLOW, item)
      ParticleManager:SetParticleControl(particle, 0, item:GetAbsOrigin())
      item.particles = {}
      table.insert(item.particles, particle)
    end
  end
  
  return item
end

function Loot:OpenChest( chest, unit )
	local count = math.random(chest.Max) + 1

	local i = 1

	local chest_unit = CreateUnitByName("npc_basic_chest",chest:GetAbsOrigin(),false,nil,nil,unit:GetTeamNumber())
	InitAbilities(chest_unit)

	chest:RemoveSelf()

	Timers:CreateTimer(function ()
		if i < count then
			i = i + 1

			local new_item_c = Loot:RandomItemFromLootTable( chest.Loot, chest_unit )

			Physics:Unit(new_item_c)

			local seed = math.random(0, 360)
			local boost = math.random(0,325)

			local x = ((185 + boost) * math.cos(seed))
			local y = ((185 + boost) * math.sin(seed))

			new_item_c:AddPhysicsVelocity(Vector(x, y, 1100))
			new_item_c:SetPhysicsAcceleration(Vector(0,0,-1700))

			EmitSoundOn("Item.DropWorld",new_item_c)

			return math.random(0.31, 0.41)
		else
			Timers:CreateTimer(0.3, function (  )
				chest_unit:RemoveModifierByName("dummy_unit")
				chest_unit:RemoveAbility("dummy_unit")
				DestroyEntityBasedOnHealth(chest_unit, chest_unit)
			end)
		end
	end) 
end
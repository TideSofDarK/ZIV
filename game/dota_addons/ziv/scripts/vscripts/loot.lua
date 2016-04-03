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

function Loot:OpenChest( chest, unit )
	local chest_rarity = chest.rarity or Loot.RARITY_MAGIC
	local count = math.random(3, 8)

	local i = 1

	local chest_unit = CreateUnitByName("npc_basic_chest",chest:GetAbsOrigin(),false,nil,nil,unit:GetTeamNumber())
	InitAbilities(chest_unit)

	chest:RemoveSelf()

	Timers:CreateTimer(function ()
		if i < count then
			i = i + 1

			local new_item_c = CreateItemOnPositionSync(chest_unit:GetAbsOrigin(), CreateItem("item_basic_coat", nil, nil))

			Physics:Unit(new_item_c)

			local seed = math.random(0, 360)

			local boost = math.random(0,325)

			local x = ((185 + boost) * math.cos(seed))
			local y = ((185 + boost) * math.sin(seed))

			new_item_c:AddPhysicsVelocity(Vector(x, y, 1100))
			new_item_c:SetPhysicsAcceleration(Vector(0,0,-1700))

			if chest_rarity > Loot.RARITY_COMMON then     
				local new_item = new_item_c:GetContainedItem()

				new_item.rarity = 0

				if i == count then
					new_item.rarity = chest_rarity
				else
					if math.random(0,1) == 0 then
						new_item.rarity = math.abs(math.random(0,chest_rarity-1))
					end
				end

				if new_item.rarity > 0 then 
					Loot:AddModifiers(new_item)

					local particle = ParticleManager:CreateParticle(Loot.RARITY_PARTICLES[new_item.rarity], PATTACH_ABSORIGIN_FOLLOW, new_item_c)
					ParticleManager:SetParticleControl(particle, 0, new_item_c:GetAbsOrigin())
					new_item_c.particles = {}
					table.insert(new_item_c.particles, particle)
				end
			end

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
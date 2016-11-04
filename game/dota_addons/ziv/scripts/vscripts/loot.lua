if Loot == nil then
    _G.Loot = class({})
end

Loot.SOCKETS_CHANCES 					= {}
Loot.SOCKETS_CHANCES[1] 				= 0.8 		-- 0
Loot.SOCKETS_CHANCES[2] 				= 0.5		-- 1
Loot.SOCKETS_CHANCES[3] 				= 0.04		-- 2
Loot.SOCKETS_CHANCES[4] 				= 0.005		-- 3

Loot.TYPE_PARTS 						= 1
Loot.TYPE_WEAPONS 						= 2
Loot.TYPE_ARMOR 						= 3
Loot.TYPE_FORGING 						= 4
Loot.TYPE_SOCKETING 					= 5

Loot.TYPE_CHANCES 						= {}
Loot.TYPE_CHANCES[Loot.TYPE_PARTS] 		= 0.25
Loot.TYPE_CHANCES[Loot.TYPE_WEAPONS] 	= 0.20
Loot.TYPE_CHANCES[Loot.TYPE_ARMOR] 		= 0.25
Loot.TYPE_CHANCES[Loot.TYPE_FORGING] 	= 0.2
Loot.TYPE_CHANCES[Loot.TYPE_SOCKETING] 	= 0.1

Loot.RARITY_COMMON 						= 1
Loot.RARITY_MAGIC 						= 2
Loot.RARITY_RARE 						= 3
Loot.RARITY_EPIC 						= 4
Loot.RARITY_LEGENDARY 					= 5

Loot.LOOT_CHANCE 						= 0.1

Loot.RARITY_CHANCES = {}
Loot.RARITY_CHANCES[Loot.RARITY_COMMON] 	= 0.6
Loot.RARITY_CHANCES[Loot.RARITY_MAGIC] 		= 0.2
Loot.RARITY_CHANCES[Loot.RARITY_RARE] 		= 0.045
Loot.RARITY_CHANCES[Loot.RARITY_EPIC] 		= 0.02
Loot.RARITY_CHANCES[Loot.RARITY_LEGENDARY] 	= 0.001

Loot.RARITY_PARTICLES = {}
Loot.RARITY_PARTICLES[Loot.RARITY_MAGIC] 			= "particles/items/ziv_chest_light_magic.vpcf"
Loot.RARITY_PARTICLES[Loot.RARITY_RARE] 			= "particles/items/ziv_chest_light_rare.vpcf"
Loot.RARITY_PARTICLES[Loot.RARITY_EPIC] 			= "particles/items/ziv_chest_light_epic.vpcf"
Loot.RARITY_PARTICLES[Loot.RARITY_LEGENDARY] 		= "particles/items/ziv_chest_light_legendary.vpcf"

Loot.CHEST_MODELS 		= {}
Loot.CHEST_MODELS[1] 	= "item_basic_chest_lockjaw"
Loot.CHEST_MODELS[2] 	= "item_basic_chest_flopjaw"
Loot.CHEST_MODELS[3] 	= "item_basic_chest_mechjaw"
Loot.CHEST_MODELS[4] 	= "item_basic_chest_trapjaw"

Loot.CommonModifiers	= {}
Loot.RuneModifiers 		= {}

Loot.Table = {}

function Loot:Init()
	-- All droppable items
	for type,keywords in pairs(LoadKeyValues('scripts/kv/LootTable.kv')) do
		for keyword,_ in pairs(keywords) do
			for k,v in pairs(ZIV.ItemKVs) do
				if string.match(k, keyword) then
					Loot.Table[type] = Loot.Table[type] or {}
					Loot.Table[type][k] = v
				end
			end
		end
	end
	-- All custom modifiers
	for k,v in pairs(ZIV.ItemKVs) do
		if v["FortifyModifiers"] then
			for modifier,modifier_table in pairs(v["FortifyModifiers"]) do	
				if string.match(string.lower(modifier), "ziv_") then
					Loot.RuneModifiers[modifier] = modifier_table
				else
					Loot.CommonModifiers[modifier] = modifier_table
				end
			end
		end
	end
	-- RNGs
	Loot.SOCKETS_RNG = ChoicePseudoRNG.create( Loot.SOCKETS_CHANCES )
	Loot.TYPE_RNG = ChoicePseudoRNG.create( Loot.TYPE_CHANCES )
	Loot.RARITY_RNG = ChoicePseudoRNG.create( Loot.RARITY_CHANCES )
end

-- Main item generating function

function Loot:CreateItem( position, owner )
  	local item_type = Loot.TYPE_RNG:Choose()
  	local item_name = GetRandomElement(Loot.Table[tostring(item_type)], false, true)

	local item = Items:Create(item_name, owner)

	item.rarity = ZIV.ItemKVs[item_name].Rarity or Loot.RARITY_COMMON
	if string.match(item_name, "item_rune_") and item.rarity == Loot.RARITY_COMMON then
		item.rarity = Loot.RARITY_MAGIC
	end

	if item_type == Loot.TYPE_WEAPONS or item_type == Loot.TYPE_ARMOR then
		item.rarity = owner.loot_rarity_rng:Choose()
		item.sockets = Loot.SOCKETS_RNG:Choose() - 1

		Loot:AddModifiers(item)
	end

	if item then
		Loot:SpawnPhysicalItem(position, item)
	end
end

function Loot:GenerateCaption( item )
	if item.rarity >= Loot.RARITY_MAGIC then
		local adjective = GetRandomElement(ZIV.CaptionsKVs.Adjectives)

		local noun = ""
		for k,v in pairs(ZIV.CaptionsKVs.Nouns) do
			if string.match(k, ZIV.ItemKVs[item:GetName()].Slot) then
				noun = GetRandomElement(ZIV.CaptionsKVs.Nouns[k])
				break
			end
		end
		local noun2 = ""
		if item.rarity >= Loot.RARITY_EPIC then
			noun2 = GetRandomElement(ZIV.CaptionsKVs.Nouns2)
		end

		item.caption = adjective.." "..noun.." "..noun2
	end
end

function Loot:AddModifiers( item )
	item.built_in_modifiers = item.built_in_modifiers or {}

	local base_modifiers = ZIV.ItemKVs[item:GetName()].BaseModifiers
	if base_modifiers then
		for k,v in pairs(base_modifiers) do
			local value = RandomModifierValue( tonumber(v["min"]), tonumber(v["max"]) )
			if value ~= 0 then
				local new_modifier = {}
				new_modifier[k] = value
				table.insert(item.built_in_modifiers, new_modifier)
			end
		end
	end

	if item.rarity then
		local modifier_count = item.rarity -- + math.random(0, 1)
		local existing = {}

		for i=1,modifier_count do
			local seed = math.random(1, GetTableLength(Loot.CommonModifiers))
			if existing[seed] then
	  			repeat
	  				seed = math.random(1, GetTableLength(Loot.CommonModifiers))
	  			until not existing[seed]
			end

			existing[seed] = true

			local x = 1
			for k,v in pairs(Loot.CommonModifiers) do
				if x == seed then
					local new_modifier = {}
					new_modifier[k] = math.random(tonumber(v["min"]), tonumber(v["max"]))

					table.insert(item.built_in_modifiers, new_modifier)
					break
				end
				x = x + 1
			end
		end

		if item.rarity >= Loot.RARITY_EPIC then
			local seed = math.random(1, GetTableLength(Loot.RuneModifiers))
			local x = 1
			for k,v in pairs(Loot.RuneModifiers) do
				if x == seed then
					local new_modifier = {}
					if not v["min"] or not v["max"] then
						new_modifier[k] = 1
					else
						new_modifier[k] = math.random(tonumber(v["min"]), tonumber(v["max"]))
					end

					table.insert(item.built_in_modifiers, new_modifier)
					break
				end
				x = x + 1
			end
		end

		Loot:GenerateCaption( item )
	end

	Items:UpdateItem(item)
end

-- Creep loot

function Loot:Generate( creep, killer )
	-- If some summon is killer, not the hero
	if killer:IsHero() == false then
		if not PlayerResource:GetPlayer(killer:GetPlayerOwnerID()) then return end
		killer = PlayerResource:GetPlayer(killer:GetPlayerOwnerID()):GetAssignedHero()
	end

	if killer.loot_rng:Next() then
    	Loot:CreateItem( creep:GetAbsOrigin(), killer )
	else
		local vial = CreateVial( killer, creep:GetAbsOrigin() + Vector(math.random(-20,20),math.random(-20,20), 0) )

		if vial then
			PrepareVial( vial )
		end
	end
end

-- Chests

function Loot:CreateChest( pos, rarity )
	local chest = CreateItemOnPositionSync(pos, Items:Create(Loot.CHEST_MODELS[math.random(1, GetTableLength(Loot.CHEST_MODELS))], nil))
	Items:CreateItemPanel( chest )
	chest.rarity = rarity or Loot.RARITY_RNG:Choose()

	chest:SetAngles(0, math.random(0, 360), 0)
	Timers:CreateTimer(function (  )
		Loot:AttachRarityParticle(chest, chest.rarity)
	end)
end

function Loot:OpenChest( chest, unit )
	local chest_unit = CreateUnitByName("npc_basic_chest",chest:GetAbsOrigin(),false,nil,nil,unit:GetTeamNumber())

	chest_unit:SetModel(ZIV.ItemKVs[chest:GetContainedItem():GetName()]["Model"])
	chest_unit:SetOriginalModel(ZIV.ItemKVs[chest:GetContainedItem():GetName()]["Model"])

	InitAbilities(chest_unit)
	chest:RemoveSelf()
  
	local count = chest.rarity

	local i = 1
	Timers:CreateTimer(function ()
		if i <= count then
			i = i + 1

			Loot:CreateItem( chest_unit:GetAbsOrigin(), unit )

			return math.random(0.2, 0.2)
		else
			Timers:CreateTimer(0.3, function (  )
				chest_unit:ForceKill(false)
			end)
		end
	end) 
end

-- Util

function Loot:AttachRarityParticle(entity, rarity)
	local particle = ParticleManager:CreateParticle(Loot.RARITY_PARTICLES[rarity], PATTACH_ABSORIGIN_FOLLOW, entity)
    ParticleManager:SetParticleControl(particle, 0, entity:GetAbsOrigin())

    AddChildParticle( entity, particle )
end

function Loot:SpawnPhysicalItem(position, item, no_panel)
	local container = CreateItemOnPositionSync(position,item)

	if not no_panel then Items:CreateItemPanel( container, true ) end

	Physics:Unit(container)

	local seed = math.random(0, 360)
	local boost = math.random(0, 325)

	local x = ((185 + boost) * math.cos(seed))
	local y = ((185 + boost) * math.sin(seed))

	container:AddPhysicsVelocity(Vector(x, y, 1100))
	container:SetPhysicsAcceleration(Vector(0,0,-1700))

    Loot:AttachRarityParticle(container, item.rarity)

	EmitSoundOn("Item.DropWorld",container)
end

function Loot:CombineLootTables(table1, table2)
	if not table1 then return table2 end
	if not table2 then return table1 end

	local new_table = table1.Loot
	local length = GetTableLength(table1.Loot)
	for k,v in pairs(table2.Loot) do
		new_table[tostring(length+tonumber(k))] = v
	end
	
	return new_table
end
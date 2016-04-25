if Director == nil then
    _G.Director = class({})
end

Director.BASIC_PACK_COUNT = 12
Director.BASIC_PACK_SPREAD = 820
Director.BASIC_LORD_SPREAD = 135

Director.color_modifier_list = Director.color_modifier_list or {}
Director.creep_modifier_list = Director.creep_modifier_list or {}
Director.lord_modifier_list = Director.lord_modifier_list or {}
Director.creep_list = Director.creep_list or {}

function Director:Init()
	for k,v in pairs(ZIV.AbilityKVs) do
		if string.match(k, "creep_modifier_") then
			Director.creep_modifier_list[k] = v
		end
		if string.match(k, "creep_lord_modifier_") then
			Director.lord_modifier_list[k] = v
		end
		if string.match(k, "color_modifier_") then
			Director.color_modifier_list[k] = v
		end
	end

	for k,v in pairs(ZIV.UnitKVs) do
		if string.match(k, "creep_") then
			Director.creep_list[k] = v
		end
	end
end

function Director:GetRandomModifier(list)

	local seed = math.random(1, GetTableLength(list))

	local i = 1
	for k,v in pairs(list) do
		if i == seed then
			return k
		end
		i = i + 1
	end
end

function Director:GetCreeps(prefix)
	local new_table = {}

	for k,v in pairs(Director.creep_list) do
		if string.match(k, prefix) then
			new_table[k] = v
		end
	end

	return new_table
end

function Director:GetRandomCreep(prefix, min_level, max_level)
	local creeps = Director:GetCreeps(prefix)

	local seed = math.random(1, GetTableLength(creeps))

	local i = 1
	for k,v in pairs(creeps) do
		if i == seed then
			return k
		end
		i = i + 1
	end
end

-- Level
-- SpawnBasic
-- SpawnLord
-- BasicModifier
-- LordModifier
-- Count
-- Position
-- Type
-- Spread
-- LordSpread
function Director:SpawnPack( pack_table )
	local level = pack_table["Level"] or 1
	local position = pack_table["Position"] or Vector(0,0,0)

	if type(pack_table) == 'table' then
		local spawn_basic = pack_table["SpawnBasic"] == true
		local spawn_lord = pack_table["SpawnLord"] == true

		if spawn_basic then
			local basic_modifier = pack_table["BasicModifier"]

			if basic_modifier then
				if basic_modifier == "random" then
					basic_modifier = Director:GetRandomModifier(Director.creep_modifier_list)
				end
			end

			Director:SpawnCreeps({Count    			= pack_table["Count"] or Director.BASIC_PACK_COUNT, 
								  RandomizeCount    	= pack_table["RandomizeCount"] or true, 
								  Position 			= position,
								  Level 				= level,
								  BasicModifier 			= basic_modifier,
								  Spread 				= pack_table["BasicSpread"],
								  Type		= pack_table["Type"] or "creep" })
		end

		if spawn_lord then
			local lord_modifier = pack_table["LordModifier"]

			if lord_modifier then
				if lord_modifier == "random" then
					lord_modifier = Director:GetRandomModifier(Director.lord_modifier_list)
				end
			end

			Director:SpawnCreeps({Count    	= pack_table["LordCount"] or 1, 
								  Position	= position,
								  Level	 	= level,
								  LordModifier 	= lord_modifier,
								  Spread 	= pack_table["LordSpread"] or Director.BASIC_LORD_SPREAD,
								  Type		= pack_table["Type"] or "creep",
								  Lord		= true })
		end
	end
end

function Director:SpawnCreeps( spawn_table )
	if spawn_table then
		local count = spawn_table["Count"]
		if spawn_table["RandomizeCount"] == true then
			count = math.random(math.floor(count - (count/4)), math.floor(count + (count/4)))
		end

		local creep_modifier = spawn_table["BasicModifier"]
		local lord_modifier = spawn_table["LordModifier"]
		local level = spawn_table["Level"]

		for i=1,count do 
			local creep_name = Director:GetRandomCreep(spawn_table["Type"], spawn_table["Level"], spawn_table["Level"])
			local position = RandomPointInsideCircle(spawn_table["Position"][1], spawn_table["Position"][2], spawn_table["BasicSpread"] or Director.BASIC_PACK_SPREAD)

			local creep = CreateUnitByName(creep_name, position, true, nil, nil, DOTA_TEAM_NEUTRALS)
			
			creep:AddAbility("ziv_creep_normal_hpbar_behavior")

			if spawn_table["Lord"] then
				creep:SetModelScale(creep:GetModelScale() * 1.45)

				creep:AddAbility(Director:GetRandomModifier(Director.color_modifier_list))

				if lord_modifier then
					creep:AddAbility(lord_modifier)
				else
					creep:AddAbility(Director:GetRandomModifier(Director.lord_modifier_list))
				end

				for i=1,level do
					local new_modifier = Director:GetRandomModifier(Director.creep_modifier_list)
					if not creep:FindAbilityByName(new_modifier) then
						creep:AddAbility(new_modifier)
					end
				end
			elseif creep_modifier then
				creep:AddAbility(creep_modifier)
			end

			InitAbilities(creep)
		end
	end
end
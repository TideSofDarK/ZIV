require('scenarios/temple')

if Director == nil then
    _G.Director = class({})
end

Director.scenario = nil

Director.BASIC_PACK_COUNT = 12
Director.BASIC_PACK_SPREAD = 820
Director.BASIC_LORD_SPREAD = 485

Director.color_modifier_list = Director.color_modifier_list or {}
Director.creep_modifier_list = Director.creep_modifier_list or {}
Director.lord_modifier_list = Director.lord_modifier_list or {}
Director.creep_list = Director.creep_list or {}

function Director:FindMapScenario( string )
	local scenario = string.gsub(" "..string.gsub(string, "ziv_", ""), "%W%l", string.upper):sub(2)
	assert( type(scenario) == "string" )

	local f = _G

	for v in scenario:gmatch("[^%.]+") do
		if type(f) ~= "table" then
			return nil, "looking for '"..v.."' expected table, not "..type(f)
		end
		f = f[v]
	end

	return f
end

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
	
	Director.scenario = Director:FindMapScenario(GetMapName())
	
	if Director.scenario then
		Director.scenario:Init()
	end
end

function Director:SetupCustomUI( name, pID )
	local args = { map = string.gsub(GetMapName(), "ziv_", ""), name = name }

	if pID then
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pID or 0), "ziv_custom_ui_open", args )
	else
		CustomGameEventManager:Send_ServerToAllClients( "ziv_custom_ui_open", args )
	end
end

function Director:SetupMap()
	local random_chests = Shuffle(Entities:FindAllByName("ziv_random_chest"))
	local chest_count = math.floor(GetTableLength(random_chests) * 0.3)

	local i = 1
	for k,v in pairs(random_chests) do
		if i >= chest_count then return end
		Loot:CreateChest( v:GetAbsOrigin(), math.random(0, 4) )
		i = i + 1
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
-- NoLoot
-- Duration
-- CheckHeight
function Director:SpawnPack( pack_table )
	if type(pack_table) == 'table' then
		local spawn_basic = pack_table["SpawnBasic"] == true
		local spawn_lord = pack_table["SpawnLord"] == true

		local pack_table = pack_table

		pack_table["Level"] = pack_table["Level"] or 1
		pack_table["Position"] = pack_table["Position"] or Vector(0,0,0)
		pack_table["NoLoot"] = pack_table["NoLoot"] or false
		pack_table["Duration"] = pack_table["Duration"]

		if spawn_basic then
			local basic_modifier = pack_table["BasicModifier"]

			if basic_modifier then
				if basic_modifier == "random" then
					basic_modifier = Director:GetRandomModifier(Director.creep_modifier_list)
				end
			end

			pack_table["Count"] = pack_table["Count"] or Director.BASIC_PACK_COUNT
			pack_table["RandomizeCount"] = pack_table["RandomizeCount"] or true
			pack_table["BasicModifier"] = basic_modifier
			pack_table["Spread"] = pack_table["BasicSpread"]
			pack_table["Type"] = pack_table["Type"] or "creep"
			pack_table["Lord"] = false

			Director:SpawnCreeps(pack_table)
		end

		if spawn_lord then
			local lord_modifier = pack_table["LordModifier"]

			if lord_modifier then
				if lord_modifier == "random" then
					lord_modifier = Director:GetRandomModifier(Director.lord_modifier_list)
				end
			end

			pack_table["Count"] = pack_table["LordCount"] or 1
			pack_table["LordModifier"] = lord_modifier
			pack_table["Spread"] = pack_table["LordSpread"] or Director.BASIC_LORD_SPREAD
			pack_table["Type"] = pack_table["Type"] or "creep"
			pack_table["Lord"] = true

			Director:SpawnCreeps(pack_table)
		end
	end
end

function Director:SpawnCreeps( spawn_table )
	local spawn_table = DeepCopy(spawn_table)
	print(spawn_table["Lord"])
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

			local spawn = true

			if spawn_table["CheckHeight"] then
				local groundZ = GetGroundHeight(position, nil)
				if math.abs(groundZ - spawn_table["Position"][3]) > 192 then
					spawn = false
				end
			end

			if GridNav:IsBlocked(position) == true or GridNav:CanFindPath(position, GetGroundPosition(Vector(0,0,0), nil)) == false then
				spawn = false
			end

			if spawn == true then
				local creep = CreateUnitByNameAsync(creep_name, position, true, nil, nil, DOTA_TEAM_NEUTRALS, function ( creep )
					if spawn_table["NoLoot"] == true then
						creep.no_loot = true
					end

					if spawn_table["Duration"] then
						creep:AddNewModifier(creep,nil,"modifier_kill",{duration=tonumber(spawn_table["Duration"])})
					end

					creep:SetAngles(0, math.random(0, 360), 0)

					if spawn_table["Lord"] == true then
						print("dick")
						creep:AddAbility("ziv_unique_hpbar")

						creep:SetModelScale(creep:GetModelScale() * 1.65)

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
					else
						print("dick1")
						creep:AddAbility("ziv_creep_normal_behavior")
					end

					if creep_modifier then
						creep:AddAbility(creep_modifier)
					end

					InitAbilities(creep)
				end)
			end
		end
	end
end

-- Misc functions
function CreateUniqueHPBar( keys )
	local caster = keys.caster

	if not caster.worldPanel then
		caster.worldPanel = WorldPanels:CreateWorldPanelForAll(
			{layout = "file://{resources}/layout/custom_game/worldpanels/healthbar.xml",
			entity = caster:GetEntityIndex(),
			entityHeight = 325,
			})
	end
end
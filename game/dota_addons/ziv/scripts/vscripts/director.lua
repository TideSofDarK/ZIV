if Director == nil then
    _G.Director = class({})
end

Director.HERO_SPAWN_TIME = 5.0

Director.TEAM_ASSIGNMENT_AUTO = 0
Director.TEAM_ASSIGNMENT_MANUAL = 1

Director.scenario = Director.scenario or nil

Director.BASIC_PACK_COUNT = 12
Director.BASIC_PACK_SPREAD = 820
Director.BASIC_LORD_SPREAD = 485

Director.color_modifier_list = Director.color_modifier_list or {}
Director.creep_modifier_list = Director.creep_modifier_list or {}
Director.lord_modifier_list = Director.lord_modifier_list or {}
Director.creep_list = Director.creep_list or {}
Director.boss_list = Director.boss_list or {}

Director.current_session_creep_count = Director.current_session_creep_count or 0

function Director:FindMapScenario( string )
	local scenario = string.lower(string.gsub(" "..string, "%W%l", string.upper):sub(2))
	return "scenarios/"..scenario
end

function Director:GetMapName()
	return string.gsub(GetMapName(), "ziv_", ""):sub(1, -4)
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

	for k,v in pairs(ZIV.UnitKVs) do
		if string.match(k, "npc_boss_") then
			Director.boss_list[k] = v
		end
	end
	
	Director.WEARABLES_RNG = PseudoRNG.create( 0.3 )
	print("asdasdasdasdas")
	Director.scenario = require(Director:FindMapScenario(Director:GetMapName()))
	if Director.scenario then
		Director.scenario:Init()

		CustomGameEventManager:RegisterListener("ziv_pregame_ready", Dynamic_Wrap(Director, 'PregameReady'))
	end
end

function Director:PregameReady(args)
	local pID = args.PlayerID

	if Director.pregame_status then
		Director.pregame_status[pID] = true

		for k,v in pairs(Director.pregame_status) do
			if PlayerResource:IsValidPlayerID(k) and PlayerResource:GetConnectionState(k) == DOTA_CONNECTION_STATE_CONNECTED then
				if v == false then
					return
				end
			end
		end

		Timers:RemoveTimer(Director.pregame_timer)
		Director.pregame_on_end()
	end
end

function Director:StartPregame()
	Director.pregame_status = GeneratePlayerArray(false)

	Director.pregame_on_end = (function (  )
		Director.scenario:NextStage()

		CustomGameEventManager:Send_ServerToAllClients("ziv_pregame_done",{}) 
	end)

	Director.pregame_timer = Director:StartTimer("pregame", Director.scenario.PREGAME_TIME, function ( t )
		
	end, Director.pregame_on_end)
end

function Director:StartTimer(name, duration, tick, on_end)
	CustomNetTables:SetTableValue("scenario", name, {time = duration})
	return Timers:CreateTimer(1.0, function ()
		local time = CustomNetTables:GetTableValue( "scenario", name).time - 1
		if time + 1 ~= 0 then
			CustomNetTables:SetTableValue("scenario", name, {time = time})
			tick(time)
			if time == 0 then
				on_end()
			else
				return 1.0
			end
		end
	end)
end

function Director:SetupCustomUI( name, args, pID )
	local args = args or {}
	args.map = Director:GetMapName()
	args.name = name

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
		if prefix ~= "creep" or (ZIV.UnitKVs[k]["Unique"] ~= 1) then
			if string.match(k, prefix) then
				new_table[k] = v
			end
		end
	end

	return new_table
end

function Director:GetRandomCreep(prefix)
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

function Director:GetRandomGroupCreep(creep)
	local creeps = Director:GetCreeps("creep")

	local new_table = {}

	for k,v in pairs(Director.creep_list) do
		if ZIV.UnitKVs[k] and ZIV.UnitKVs[creep] then
			if ZIV.UnitKVs[k]["Group"] == ZIV.UnitKVs[creep]["Group"] then
				new_table[k] = v
			end
		end
	end

	local seed = math.random(1, GetTableLength(new_table))

	local i = 1
	for k,v in pairs(new_table) do
		if i == seed then
			return k
		end
		i = i + 1
	end
end

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
-- Table
function Director:SpawnPack( pack_table )
	if type(pack_table) == 'table' then
		local basic_table = {}
		basic_table.Position = pack_table.Position or Vector(0,0,0)
		basic_table.NoLoot = pack_table.NoLoot or false
		basic_table.Duration = pack_table.Duration

		if pack_table.SpawnBasic then
			basic_table.BasicModifier = pack_table.BasicModifier

			if basic_table.BasicModifier then
				if basic_table.BasicModifier == "random" then
					basic_table.BasicModifier = Director:GetRandomModifier(Director.creep_modifier_list)
				end
			end

			basic_table.Count = pack_table.Count or Director.BASIC_PACK_COUNT
			basic_table.RandomizeCount = pack_table.RandomizeCount or true
			basic_table.Spread = pack_table.BasicSpread
			basic_table.Type = pack_table.Type or "creep"

			basic_table.Lord = false
			basic_table.SpawnLord = false

			basic_table.CheckTable = pack_table.CheckTable

			basic_table.Table = pack_table.Table

			Director:SpawnCreeps(basic_table)
		end

		local lord_table = {}
		lord_table.Position = pack_table.Position or Vector(0,0,0)
		lord_table.NoLoot = pack_table.NoLoot or false
		lord_table.Duration = pack_table.Duration

		if pack_table.SpawnLord then
			lord_table.LordModifier = pack_table.LordModifier

			if lord_table.LordModifier then
				if lord_table.LordModifier == "random" then
					lord_table.LordModifier = Director:GetRandomModifier(Director.lord_modifier_list)
				end
			end

			lord_table.Count = pack_table.LordCount or 1
			lord_table.LordModifier = lord_modifier
			lord_table.Spread = pack_table.Spread or Director.BASIC_LORD_SPREAD
			lord_table.Type = pack_table.Type or "creep"

			lord_table.Lord = true
			lord_table.SpawnLord = true

			lord_table.CheckTable = pack_table.CheckTable

			lord_table.Table = pack_table.Table

			Director:SpawnCreeps(lord_table)
		end
	end
end

function Director:GenerateVisuals( creep_name )
	local visuals = {}

	-- Color presets
	if ZIV.UnitKVs[creep_name].Colors then
		local color_string = KeyValues:Split(ZIV.UnitKVs[creep_name]["Colors"]["Color"..tostring(math.random(1,GetTableLength(ZIV.UnitKVs[creep_name]["Colors"])))], ";") 
		visuals.material_color = Vector(tonumber(color_string[1]), tonumber(color_string[2]), tonumber(color_string[3]))
	end

	-- Wearables presets
	local wearables = ZIV.UnitKVs[creep_name].Wearables
	if wearables then
		if wearables.Lord then
			visuals.wearables_table_lord = GetRandomElement(wearables.Lord)
		end
		if wearables.Creep then
			visuals.wearables_table = GetRandomElement(wearables.Creep)
		end
	end

	return visuals
end

function Director:SpawnCreeps( spawn_table )
	if spawn_table then
		local count = spawn_table.Count
		if spawn_table.RandomizeCount == true then
			count = math.random(math.floor(count - (count/4)), math.floor(count + (count/4)))
		end

		local creep_modifier = spawn_table.BasicModifier
		local lord_modifier = spawn_table.LordModifier

		local creep_name = Director:GetRandomCreep(spawn_table.Type)

		local group = ZIV.UnitKVs[creep_name].Group
		if group then
			group = math.random(1,2) == 1
		end

		local visuals = {}
		visuals[creep_name] = Director:GenerateVisuals( creep_name )

		for i=1,count do 
			if group then
				creep_name = Director:GetRandomGroupCreep(creep_name)
				visuals[creep_name] = visuals[creep_name] or Director:GenerateVisuals( creep_name )
			end

			local position = RandomPointInsideCircle(spawn_table.Position[1], spawn_table.Position[2], spawn_table.BasicSpread or Director.BASIC_PACK_SPREAD)

			local spawn = true

			if spawn_table.CheckHeight then
				local groundZ = GetGroundHeight(position, nil)
				if math.abs(groundZ - spawn_table.Position[3]) > 192 then
					spawn = false
				end
			end

			if GridNav:IsBlocked(position) == true or GridNav:CanFindPath(position, GetGroundPosition(Vector(0,0,0), nil)) == false then
				spawn = false
			end

			if spawn_table.CheckTable then
				for k,v in pairs(spawn_table.CheckTable) do
					if Distance(v, position) < v:GetCurrentVisionRange() then
						spawn = false
						break
					end
				end
			end

			if spawn == true then
				local creep = CreateUnitByNameAsync(creep_name, position, true, nil, nil, DOTA_TEAM_NEUTRALS, function ( creep )
					Director.current_session_creep_count = Director.current_session_creep_count + 1

					creep:SetHasLoot( not spawn_table.NoLoot )

					if spawn_table.Duration then
						creep:AddNewModifier(creep,nil,"modifier_kill",{duration=tonumber(spawn_table.Duration)})
					end

					SetRandomAngle( creep )

					if spawn_table.Lord == true then
						creep:AddAbility("ziv_unique_hpbar")

						creep:SetModelScale(creep:GetModelScale() * 1.15)

						creep:AddAbility(Director:GetRandomModifier(Director.color_modifier_list))

						if lord_modifier then
							creep:AddAbility(lord_modifier)
						end

						creep:AddAbility("ziv_creep_lord_tanky")

						local new_modifier = Director:GetRandomModifier(Director.creep_modifier_list)
						if not creep:FindAbilityByName(new_modifier) then
							creep:AddAbility(new_modifier)
						end

						creep.worldPanel = WorldPanels:CreateWorldPanelForAll({
							layout = "healthbar",
							entity = creep:GetEntityIndex(),
							entityHeight = 345,
						})
					end

					creep:AddAbility("ziv_creep_normal_behavior")

					if creep_modifier then
						creep:AddAbility(creep_modifier)
					end

					InitAbilities(creep)

					local visuals = visuals[creep:GetUnitName()]

					if visuals.material_color then
						local color = visuals.material_color
						creep:SetRenderColor(color[1], color[2], color[3])
					end

					if spawn_table.Lord and visuals.wearables_table_lord then
						for k,v in pairs(visuals.wearables_table_lord) do
							Wearables:AttachWearable(creep, v)
						end
					elseif visuals.wearables_table and Director.WEARABLES_RNG:Next() then
						for k,v in pairs(visuals.wearables_table) do
							Wearables:AttachWearable(creep, v)
						end
					end

					if spawn_table.Table then --and type(spawn_table["Table"]) == "table"
						table.insert(spawn_table.Table, creep)
						creep.pack = spawn_table.Table
					end
				end)
			end
		end

		UTIL_Remove(spawn_table)
	end
end

function Director:SpawnBoss( boss_name, position )
	local boss_name = boss_name
	if not boss_name then
		boss_name = GetRandomElement(Director.boss_list)
	end

	PrecacheUnitByNameAsync(boss_name,function ()
		CreateUnitByNameAsync(boss_name,position,true,nil,nil,DOTA_TEAM_NEUTRALS,function ( boss )
      AI:BossStart( boss )
			Director:SetupCustomUI( "boss_hpbar", { boss = boss:entindex() } )
			print("spawned")
			CustomNetTables:SetTableValue( "scenario", "boss", {entindex = boss:entindex()} )

			boss:AddOnDiedCallback( function (  )

			end )
		end)
	end,0)
end
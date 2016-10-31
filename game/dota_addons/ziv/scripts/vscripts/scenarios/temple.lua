Temple = {}

-- Stages
Temple.STAGE_NO = -1
Temple.STAGE_PREGAME = 0
Temple.STAGE_FIRST = 1
Temple.STAGE_SECOND = 2
Temple.STAGE_BOSS = 3
Temple.STAGE_END = 4

-- Teams
Temple.TEAMS = { DOTA_TEAM_GOODGUYS }
Temple.TEAM_ASSIGNMENT = Director.TEAM_ASSIGNMENT_AUTO

-- Balance
Temple.ROCKS_DELAY = 1.5
Temple.ROCKS_TICK = 0.1
Temple.ROCKS_DAMAGE = 0.02
Temple.ROCKS_DURATION = 2.0
Temple.ROCKS_INTERVAL_MIN = 8.0
Temple.ROCKS_INTERVAL_MAX = 15.0

Temple.SPAWN_THRESHOLD = 1200
Temple.SPAWN_SPREAD = 1800
Temple.SPAWN_MIN = 20
Temple.SPAWN_MAX = 40
Temple.SPAWN_GC_TIME = 10.0

Temple.OBELISK_COUNT = 20

-- Store
Temple.stage = Temple.STAGE_NO

Temple.obelisks_positions = {}
Temple.creeps_positions = {}
Temple.obelisks = {}

function Temple:Init()
	Temple.obelisks_positions = Entities:FindAllByName("ziv_temple_obelisk")
	Temple.creeps_positions = Entities:FindAllByName("ziv_temple_obelisk") --ziv_basic_creep_spawner

	local worldMin = {x = -6100, y = -6100 }
  	local worldMax = {x = 6100, y = 6100 }

	CustomNetTables:SetTableValue( "scenario", "map", {min = worldMin, max = worldMax, map = GetMapName()} )
end

function Temple:SetObelisksCount()
	CustomNetTables:SetTableValue( "scenario", "obelisks", {count = GetTableLength(Temple.obelisks), max = Temple.OBELISK_COUNT} )
end

function Temple:NextStage()
	Temple.stage = Temple.stage + 1

	if Temple.stage == Temple.STAGE_END then

	else
		if Temple.stage == Temple.STAGE_FIRST then
			Director:SetupCustomUI( "temple_objectives" )

			-- Temple:FallingRocks()
		elseif Temple.stage == Temple.STAGE_BOSS then
			
		else
			Temple:SetupMap()

			if Temple.stage == Temple.STAGE_PREGAME then
				Timers:CreateTimer(Director.HERO_SPAWN_TIME, function (  )
					-- for k,v in pairs(Entities:FindAllByName("ziv_temple_portal")) do
						
					-- end
					-- local shit= Entities:FindAllInSphere(Vector(0,0,0), 40000)
					-- for k,v in pairs(shit) do
					-- 	if v.GetClassname then
					-- 		print(k,v:GetClassname())
					-- 	else
					-- 		print(k, type(v))
					-- 	end
					-- end
					DoToAllHeroes(function ( hero )
						ParticleManager:CreateParticle("particles/rain_fx/econ_weather_sirocco.vpcf", PATTACH_EYES_FOLLOW, hero)
					end)
					Temple:NextStage()
				end)
			elseif Temple.stage == Temple.STAGE_SECOND then

			end
		end	
	end
end

function Temple:FallingRocks()
	local start_stage = Temple.stage

	DoToAllHeroes(function ( hero )
		Timers:CreateTimer(function (  )
			position = hero:GetAbsOrigin() + Vector(math.random(-800, 800), math.random(-800, 800), 0)

			if GridNav:IsBlocked(position) == false then
				local unit = CreateUnitByNameAsync("npc_dummy_unit",position,true,nil,nil,DOTA_TEAM_NEUTRALS, function (unit)
					unit:SetMoveCapability(1)

					local particle = ParticleManager:CreateParticle("particles/unique/temple/temple_falling_rocks.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
				  	ParticleManager:SetParticleControl(particle, 1, Vector(255,0,0))
				  	ParticleManager:ReleaseParticleIndex(particle)

					EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "General.Ping", unit)
					EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "tutorial_rockslide", unit)

					local timer = 0.0

					Timers:CreateTimer(Temple.ROCKS_DELAY, function ()
						local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
						for k,v in pairs(units) do
							if v ~= unit then
								Damage:Deal( unit, v, v:GetMaxHealth() * Temple.ROCKS_DAMAGE, DAMAGE_TYPE_PHYSICAL ) 
								-- v:AddNewModifier(unit,nil,"modifier_stunned",{duration=0.03})
							end
						end

						timer = timer + Temple.ROCKS_TICK
						if timer < Temple.ROCKS_DURATION then return Temple.ROCKS_TICK 
						else 
							ParticleManager:DestroyParticle(particle,false)
							unit:ForceKill(false)
						end
					end)
				end)
				return math.random(Temple.ROCKS_INTERVAL_MIN, Temple.ROCKS_INTERVAL_MAX)
			end
			return 0.0
		end)
	end)
end

function Temple:SetupMap()
	Temple.obelisks = DistributeUnits( Temple.obelisks_positions, "npc_temple_obelisk", Temple.OBELISK_COUNT, DOTA_TEAM_NEUTRALS, function (obelisk)
		for i=#Temple.obelisks,1,-1 do
		    if Temple.obelisks[i] == obelisk then
		        table.remove(Temple.obelisks, i)
		        Temple:SetObelisksCount()
		    end
		end
	end )
	Temple:SetObelisksCount()

	Temple:SpawnCreeps()
end

function Temple:SpawnCreeps()
	for k,v in pairs(Temple.creeps_positions) do
		Temple:DestroyCreeps( v )
	end

	Timers:CreateTimer(function (  )
		DoToAllHeroes(function ( hero )
			for k,v in pairs(Temple.creeps_positions) do
				local distance = (v:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
				if distance < Temple.SPAWN_THRESHOLD and not v.creeps then --GetTableLength(v.creeps) == 0
					v.creeps = v.creeps or {}

					local basic_modifier
					if math.random(1,3) == 1 then
						basic_modifier = "random"
					end

					Director:SpawnPack({
				        SpawnBasic = true,
				        Count = math.random(Temple.SPAWN_MIN, Temple.SPAWN_MAX),
				        Position = v:GetAbsOrigin(),
				        CheckHeight = true,
				        Spread = Temple.SPAWN_SPREAD,
				        SpawnLord = math.random(1,2) == 1,
				        BasicModifier = basic_modifier,
				        Table = v.creeps,
				        CheckTable = Characters.current_session_characters
				    })
				elseif v.creeps then
					if v.idle_count and v.idle_count > Temple.SPAWN_GC_TIME then
						Temple:DestroyCreeps( v )
					else
						local idle = true
						for k2,v2 in pairs(v.creeps) do
							if v2:IsNull() == false then
								if Distance(hero, v2) <= Temple.SPAWN_THRESHOLD or hero:CanEntityBeSeenByMyTeam(v2) == true or v2:IsIdle() == false then --v2:IsAlive() == true and v2:IsIdle() == false and 
									idle = false
									v.idle_count = 0.0
									break
								end
							end
						end
						if idle == true then
							v.idle_count = (v.idle_count or 0.0) + 1.0
						end
					end
				end
			end
		end)

		return 2.0
	end)
end

function Temple:DestroyCreeps( v )
	if v.creeps then
		for i,v2 in ipairs(v.creeps) do
			if v2:IsNull() == false then
				UTIL_Remove(v2)
			end
		end
	end
	v.creeps = nil
	v.idle_count = 0.0
end
Mines = {}

-- Stages
Mines.STAGE_NO = -1
Mines.STAGE_PREGAME = 0
Mines.STAGE_FIRST = 1
Mines.STAGE_BOSS = 2
Mines.STAGE_SECOND = 3
Mines.STAGE_END = 4

-- Teams
Mines.TEAMS = { DOTA_TEAM_GOODGUYS }
Mines.TEAM_ASSIGNMENT = Director.TEAM_ASSIGNMENT_AUTO

-- Balance
Mines.PREGAME_TIME = 90.0

Mines.ROCKS_DELAY = 1.5
Mines.ROCKS_TICK = 0.1
Mines.ROCKS_DAMAGE = 0.02
Mines.ROCKS_DURATION = 2.0
Mines.ROCKS_INTERVAL_MIN = 8.0
Mines.ROCKS_INTERVAL_MAX = 15.0

Mines.SPAWN_THRESHOLD = 1200
Mines.SPAWN_SPREAD = 1800
Mines.SPAWN_MIN = 20
Mines.SPAWN_MAX = 40
Mines.SPAWN_GC_TIME = 10.0

-- Store
Mines.stage = Mines.STAGE_NO

function Mines:Init()
	self.wagon_path = Entities:FindAllByName("ziv_path_*")

	local worldMin = {x = -8732, y = -4360 }
  	local worldMax = {x = 8108, y = 5296 }

	CustomNetTables:SetTableValue( "scenario", "map", {min = worldMin, max = worldMax, map = GetMapName()} )
end

function Mines:NextStage()
	if self.stage == self.STAGE_NO then
		Director:StartPregame( )
	else
		Director:SetupCustomUI( "mines_objectives" )
	end

	Mines.stage = Mines.stage + 1
end

function Mines:FallingRocks()
	local start_stage = Mines.stage

	DoToAllHeroes(function ( hero )
		Timers:CreateTimer(function (  )
			position = hero:GetAbsOrigin() + Vector(math.random(-800, 800), math.random(-800, 800), 0)

			if GridNav:IsBlocked(position) == false then
				local unit = CreateUnitByNameAsync("npc_dummy_unit",position,true,nil,nil,DOTA_TEAM_NEUTRALS, function (unit)
					unit:SetMoveCapability(1)

					local particle = ParticleManager:CreateParticle("particles/unique/Mines/Mines_falling_rocks.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
				  	ParticleManager:SetParticleControl(particle, 1, Vector(255,0,0))
				  	ParticleManager:ReleaseParticleIndex(particle)

					EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "General.Ping", unit)
					EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "tutorial_rockslide", unit)

					local timer = 0.0

					Timers:CreateTimer(Mines.ROCKS_DELAY, function ()
						local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
						for k,v in pairs(units) do
							if v ~= unit then
								Damage:Deal( unit, v, v:GetMaxHealth() * Mines.ROCKS_DAMAGE, DAMAGE_TYPE_PHYSICAL ) 
								-- v:AddNewModifier(unit,nil,"modifier_stunned",{duration=0.03})
							end
						end

						timer = timer + Mines.ROCKS_TICK
						if timer < Mines.ROCKS_DURATION then return Mines.ROCKS_TICK 
						else 
							ParticleManager:DestroyParticle(particle,false)
							unit:ForceKill(false)
						end
					end)
				end)
				return math.random(Mines.ROCKS_INTERVAL_MIN, Mines.ROCKS_INTERVAL_MAX)
			end
			return 0.0
		end)
	end)
end

function Mines:SetupMap()
end

function Mines:SpawnCreeps()
	for k,v in pairs(Mines.creeps_positions) do
		Mines:DestroyCreeps( v )
	end

	Timers:CreateTimer(function (  )
		DoToAllHeroes(function ( hero )
			for k,v in pairs(Mines.creeps_positions) do
				local distance = (v:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
				if distance < Mines.SPAWN_THRESHOLD and not v.creeps then --GetTableLength(v.creeps) == 0
					v.creeps = v.creeps or {}

					local basic_modifier
					if math.random(1,3) == 1 then
						basic_modifier = "random"
					end

					Director:SpawnPack({
				        SpawnBasic = true,
				        Count = math.random(Mines.SPAWN_MIN, Mines.SPAWN_MAX),
				        Position = v:GetAbsOrigin(),
				        CheckHeight = true,
				        Spread = Mines.SPAWN_SPREAD,
				        SpawnLord = math.random(1,2) == 1,
				        BasicModifier = basic_modifier,
				        Table = v.creeps,
				        CheckTable = Characters.current_session_characters
				    })
				elseif v.creeps then
					if v.idle_count and v.idle_count > Mines.SPAWN_GC_TIME then
						Mines:DestroyCreeps( v )
					else
						local idle = true
						for k2,v2 in pairs(v.creeps) do
							if v2:IsNull() == false then
								if Distance(hero, v2) <= Mines.SPAWN_THRESHOLD or hero:CanEntityBeSeenByMyTeam(v2) == true or v2:IsIdle() == false then --v2:IsAlive() == true and v2:IsIdle() == false and 
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

function Mines:DestroyCreeps( v )
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

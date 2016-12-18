if Mines == nil then
    _G.Mines = class({})
end

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

Mines.PATH_THRESHOLD = 0.05
Mines.SPAWN_THRESHOLD = 1200
Mines.SPAWN_MINIMUM_SPREAD = 2000
Mines.SPAWN_SPREAD = 4000
Mines.SPAWN_MIN = 12
Mines.SPAWN_MAX = 25
Mines.SPAWN_GC_TIME = 10.0
Mines.SPAWN_INTERVAL = 8.5
Mines.MAX_CREEPS = 75

Mines.WAGON_SPEED = 5.5

Mines.WORLD_MIN = {x = -8732, y = -4360 }
Mines.WORLD_MAX = {x = 8108, y = 5296 }

function Mines:Init()
    CustomNetTables:SetTableValue( "scenario", "map", {min = self.WORLD_MIN, max = self.WORLD_MAX, map = GetMapName()} )

    Mines.stage = Mines.STAGE_NO

    self:BuildPath()
end

function Mines:CanMoveWagon()
	return self.stage == self.STAGE_FIRST or self.stage == self.STAGE_SECOND
end

function Mines:NextStage()
	self.stage = self.stage + 1

	if self.stage == self.STAGE_PREGAME then
		Director:StartPregame( )

		self:InitPregameArea()
		self:SpawnCart()
	elseif self.stage == self.STAGE_FIRST then
		Director:SetupCustomUI( "mines_objectives" )

		self:CleanupPregameArea()
		self:SpawnCreeps()
		-- self:FallingRocks()
	end
end

function Mines:BuildPath()
	local path = Entities:FindAllByName("ziv_path_*")
	local swap = 0

	self.wagon_path = {}
	local skip = false

	for i=1,#path do
		local p1 = path[i]:GetAbsOrigin()
		local p2 = path[i+1]

		if p2 then
			p2 = path[i+1]:GetAbsOrigin()
		else
			p2 = p1
		end

		local direction = path[i-1]
		if direction then
			direction = direction:GetAbsOrigin()
		end

		if Distance(p1, p2) > 200 then
			-- DebugDrawLine(p1 + Vector(0,0,50), p2 + Vector(0,0,50), 255, 0, 255, false, 5.0)
			table.insert(self.wagon_path, p1)	
		else
			-- table.insert(self.wagon_path, p1)	

			local p3 = Vector(p1.x, ((p1.y + p2.y) / 2))
			local p4 = Vector(((p1.x + p2.x) / 2), p2.y)

			local curve = BezierCurve:ComputeBezier({p1,p3,p4,p2},30) 

			if swap % 2 == 0 then
				p3.x = p2.x
				p4.y = p1.y
				curve = BezierCurve:ComputeBezier({p2,p3,p4,p1},30) 

				for x=#curve,1,-1 do
					table.insert(self.wagon_path, curve[x])
				end
			else
				for x=1,#curve-1 do
					table.insert(self.wagon_path, curve[x])
				end
			end

			swap = swap + 1
		end
	end

	return self.wagon_path
end

function Mines:GetPathPercentage()
	if not self.wagon then return 0 end
	return (self.wagon.path_traveled / self.wagon.path_length)
end

function Mines:SpawnCart()
	local position = self.wagon_path[1]

	if self.wagon then
		ParticleManager:DestroyParticle(self.wagon.area, true)
		UTIL_Remove(self.wagon)
	end

	local wagon = CreateUnitByName("npc_mines_wagon",position,false,nil,nil,DOTA_TEAM_GOODGUYS)
	wagon:SetForwardVector(UnitLookAtPoint(wagon, self.wagon_path[2] ))

	wagon.path = self.wagon_path
	wagon.path_point = 1

	wagon.path_length = GetPathLength( self.wagon_path )
	wagon.path_traveled = 0

	self.wagon = wagon
end

function CheckEscorts( keys )
	local caster = keys.caster
	local ability = keys.ability

	if not Director.scenario:CanMoveWagon() then
		return
	end

	if not caster.area then
		caster.area = ParticleManager:CreateParticle("particles/unique/mines/ziv_wagon_area.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
		ParticleManager:SetParticleControlEnt(caster.area,0,caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster:GetAbsOrigin(),false)
		ParticleManager:SetParticleControl(caster.area, 2, Vector(128,0,0))
	end
	
	local units = DoToUnitsInRadius( caster, caster:GetAbsOrigin(), GetSpecial(ability, "radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, function ( v )
		ParticleManager:SetParticleControl(caster.area, 2, Vector(0,128,0))

		CustomNetTables:SetTableValue( "scenario", "wagon", {percentage = (caster.path_traveled / caster.path_length)} )

		local movement = Timers:CreateTimer(0.0, function ()
			local position = caster:GetAbsOrigin()
			 
			local distance_traveled = 0
			local distance_to_travel = Mines.WAGON_SPEED
			 
			local new_position = position
			 
			while distance_traveled < distance_to_travel do
			    if #caster.path < caster.path_point + 1 then
			        break
			    end
			 
			    local next_point = GetGroundPosition(caster.path[caster.path_point + 1],caster)
			   
			    caster:SetForwardVector(UnitLookAtPoint( caster, next_point ))

			    local direction_to_next_point = (next_point - new_position):Normalized()
			    local distance_to_next_point  = (new_position - next_point):Length2D()
			    local distance_left_to_travel = distance_to_travel - distance_traveled
			   
			    local step_distance = math.min(distance_left_to_travel, distance_to_next_point)
			   
			    if step_distance == 0 then
			        break
			    end
			   
			    new_position = (step_distance * direction_to_next_point) + new_position

			    if step_distance == distance_to_next_point then
			        caster.path_point = caster.path_point + 1
			    end
			   
			    distance_traveled = distance_traveled + step_distance
			    caster.path_traveled = caster.path_traveled + step_distance
			end
			 
			new_position.z = GetGroundHeight(new_position,caster)
			 
			caster:SetAbsOrigin(new_position)
			 
			return 0.03
		end)

		Timers:CreateTimer(0.47, function (  )
			Timers:RemoveTimer(movement)
		end)
	end )

	if #units == 0 then
		ParticleManager:SetParticleControl(caster.area, 2, Vector(128,0,0))
	end
end

function Mines:FallingRocks()
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

					Timers:CreateTimer(self.ROCKS_DELAY, function ()
						local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
						for k,v in pairs(units) do
							if v ~= unit then
								Damage:Deal( unit, v, v:GetMaxHealth() * self.ROCKS_DAMAGE, DAMAGE_TYPE_PHYSICAL ) 
								-- v:AddNewModifier(unit,nil,"modifier_stunned",{duration=0.03})
							end
						end

						timer = timer + self.ROCKS_TICK
						if timer < self.ROCKS_DURATION then return self.ROCKS_TICK 
						else 
							ParticleManager:DestroyParticle(particle,false)
							unit:ForceKill(false)
						end
					end)
				end)
				return math.random(self.ROCKS_INTERVAL_MIN, self.ROCKS_INTERVAL_MAX)
			end
			return 0.0
		end)
	end)
end

function Mines:SetupMap()
end

function Mines:SpawnCreeps()
	local wagon = self.wagon
	
	Timers:CreateTimer(2.0, function ()
		if wagon and self:GetPathPercentage() > self.PATH_THRESHOLD then
			local basic_modifier
			if math.random(1,3) == 1 then
				basic_modifier = "random"
			end

			Director:SpawnPack({
			    SpawnBasic = true,
			    Count = math.random(self.SPAWN_MIN, self.SPAWN_MAX),
			    Position = wagon:GetAbsOrigin(),
			    CheckHeight = true,
			    Spread = self.SPAWN_SPREAD,
			    SpawnLord = math.random(1,2) == 1,
			    BasicModifier = basic_modifier,
			    Table = wagon.creeps,
			    -- CheckTable = Characters.current_session_characters,
			    MinimumSpread = self.SPAWN_MINIMUM_SPREAD,
			    AttackTarget = wagon,
			    CheckZ = true
			})
		end

		return self.SPAWN_INTERVAL
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

function Mines:InitPregameArea()
	local function PrepareArea(area)
		local last = area[#area]

		for k, v in orderedPairs(area) do
			local wall = ParticleManager:CreateParticle("particles/bosses/ziv_boss_area.vpcf",PATTACH_CUSTOMORIGIN,nil)
			ParticleManager:SetParticleControl(wall,0,last)
			ParticleManager:SetParticleControl(wall,1,v)
			last = v

			table.insert(self.pregame_area_container, wall)
		end

		DistributeUnitsAlongPolygonPath(area, function ( pos, is_tower )
			local blocker = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = pos, block_fow = true})

			local pos = GetGroundPosition(pos, blocker)
	        blocker:SetAbsOrigin(pos)

			table.insert(self.pregame_area_container, blocker)
		end, 32)
	end

	self.pregame_area_container = {}

	self.pregame_area_a = GetArea("ziv_wall_a*")
	self.pregame_area_b = GetArea("ziv_wall_b*")

	PrepareArea(self.pregame_area_a)
	PrepareArea(self.pregame_area_b)
end

function Mines:CleanupPregameArea()
	if self.pregame_area_container then
		for k,v in pairs(self.pregame_area_container) do
			if type(v) == "number" then
				ParticleManager:DestroyParticle(v, false)
			else
				UTIL_Remove(v)
			end
		end
	end
end

return Mines
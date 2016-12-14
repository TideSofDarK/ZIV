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
	local worldMin = {x = -8732, y = -4360 }
  	local worldMax = {x = 8108, y = 5296 }

	CustomNetTables:SetTableValue( "scenario", "map", {min = worldMin, max = worldMax, map = GetMapName()} )

	self:BuildPath()
end

function Mines:NextStage()
	if self.stage == self.STAGE_NO then
		Director:StartPregame( )
	else
		Director:SetupCustomUI( "mines_objectives" )
	end

	self.stage = Mines.stage + 1
end

function Mines:BuildPath()
	local path = Entities:FindAllByName("ziv_path_*")
	local swap = 0

	self.wagon_path = {}

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
			local p3 = Vector(p1.x, ((p1.y + p2.y) / 2))
			local p4 = Vector(((p1.x + p2.x) / 2), p2.y)

			local curve = BezierCurve:ComputeBezier({p1,p3,p4,p2},100) 

			if swap % 2 == 0 then
				p3.x = p2.x
				p4.y = p1.y
				curve = BezierCurve:ComputeBezier({p2,p3,p4,p1},100) 
			end

			swap = swap + 1

			for x=1,#curve do
				table.insert(self.wagon_path, curve[x])
			end

			-- BezierCurve:Draw(curve, Vector(0,0,180))
		end
	end
end

function Mines:SpawnCart()
	local position = self.wagon_path[1]

	if self.wagon then
		ParticleManager:DestroyParticle(self.wagon.area, true)
		UTIL_Remove(self.wagon)
	end

	self.wagon = CreateUnitByName("npc_mines_wagon",position,false,nil,nil,DOTA_TEAM_GOODGUYS)
	self.wagon:SetForwardVector(UnitLookAtPoint( self.wagon, self.wagon_path[2] ))

	self.wagon.area = ParticleManager:CreateParticle("particles/unique/mines/ziv_wagon_area.vpcf",PATTACH_ABSORIGIN_FOLLOW,self.wagon)
	ParticleManager:SetParticleControlEnt(self.wagon.area,0,self.wagon,PATTACH_POINT_FOLLOW,"attach_hitloc",self.wagon:GetAbsOrigin(),false)
	ParticleManager:SetParticleControl(self.wagon.area, 2, Vector(128,0,0))

	self.wagon.path = self.wagon_path
	self.wagon.path_point = 1
end

function CheckEscorts( keys )
	local caster = keys.caster
	local ability = keys.ability

	local units = DoToUnitsInRadius( caster, caster:GetAbsOrigin(), GetSpecial(ability, "radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, function ( v )
		ParticleManager:SetParticleControl(caster.area, 2, Vector(0,128,0))

		local movement = Timers:CreateTimer(0.0, function (  )
			local position = caster:GetAbsOrigin()

			local p1 = caster.path[caster.path_point]
			local p2 = caster.path[caster.path_point+1]

			caster:SetForwardVector(UnitLookAtPoint( caster, p2 ))

			local direction = (p2 - p1):Normalized()
			local distance = Distance(p1, p2)

			local new_position = position + (direction * 1.2)
			if Distance(p1, p2) < Distance(p1, new_position) then
				new_position = p2
				caster.path_point = caster.path_point + 1
			end

			new_position.z = GetGroundHeight(new_position,caster)

			caster:SetAbsOrigin(new_position)

			return 0.03
		end)

		Timers:CreateTimer(0.47, function (  )
			Timers:RemoveTimer(movement)
			CustomNetTables:SetTableValue( "scenario", "wagon", {percentage = (caster.path_point / #caster.path)} )
		end)
	end )

	if #units == 0 then
		ParticleManager:SetParticleControl(caster.area, 2, Vector(128,0,0))
	end
end

function Mines:FallingRocks()
	local start_stage = self.stage

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
	for k,v in pairs(self.creeps_positions) do
		self:DestroyCreeps( v )
	end

	Timers:CreateTimer(function (  )
		DoToAllHeroes(function ( hero )
			for k,v in pairs(self.creeps_positions) do
				local distance = (v:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
				if distance < self.SPAWN_THRESHOLD and not v.creeps then --GetTableLength(v.creeps) == 0
					v.creeps = v.creeps or {}

					local basic_modifier
					if math.random(1,3) == 1 then
						basic_modifier = "random"
					end

					Director:SpawnPack({
				        SpawnBasic = true,
				        Count = math.random(self.SPAWN_MIN, self.SPAWN_MAX),
				        Position = v:GetAbsOrigin(),
				        CheckHeight = true,
				        Spread = self.SPAWN_SPREAD,
				        SpawnLord = math.random(1,2) == 1,
				        BasicModifier = basic_modifier,
				        Table = v.creeps,
				        CheckTable = Characters.current_session_characters
				    })
				elseif v.creeps then
					if v.idle_count and v.idle_count > self.SPAWN_GC_TIME then
						self:DestroyCreeps( v )
					else
						local idle = true
						for k2,v2 in pairs(v.creeps) do
							if v2:IsNull() == false then
								if Distance(hero, v2) <= self.SPAWN_THRESHOLD or hero:CanEntityBeSeenByMyTeam(v2) == true or v2:IsIdle() == false then --v2:IsAlive() == true and v2:IsIdle() == false and 
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

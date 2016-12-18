if Temple == nil then
    _G.Temple = class({})
end

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
Temple.PREGAME_TIME = 90.0

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

Temple.WORLD_MIN = {x = -6100, y = -6100 }
Temple.WORLD_MAX = {x = 6100, y = 6100 }

-- Store
Temple.stage = Temple.STAGE_NO

Temple.obelisks_positions = {}
Temple.creeps_positions = {}
Temple.obelisks = {}

function Temple:Init()
	self.obelisks_positions = Entities:FindAllByName("ziv_temple_obelisk")
	self.creeps_positions = Entities:FindAllByName("ziv_temple_obelisk") --ziv_basic_creep_spawner
	self.boss_area = GetArea("ziv_temple_boss_area*")

	CustomNetTables:SetTableValue( "scenario", "map", {min = self.WORLD_MIN, max = self.WORLD_MAX, map = GetMapName()} )
end

function Temple:SetObelisksCount()
	CustomNetTables:SetTableValue( "scenario", "obelisks", {count = GetTableLength(self.obelisks), max = self.OBELISK_COUNT} )
end

function Temple:NextStage()
	self.stage = self.stage + 1

	if self.stage == self.STAGE_END then

	else
		if self.stage == self.STAGE_FIRST then
			self:CleanupBossFight()

			Director:SetupCustomUI( "temple_objectives" )

			-- Temple:FallingRocks()
		elseif self.stage == self.STAGE_BOSS then
			
		else
			self:SetupMap()

			if self.stage == self.STAGE_PREGAME then
				self:InitBossArea()

				Director:StartPregame(  )

				-- Timers:CreateTimer(Temple.PREGAME_TIME, function (  )
					-- for k,v in pairs(Entities:FindAllByName("ziv_temple_portal")) do
						
					-- end

					-- DoToAllHeroes(function ( hero )
						-- ParticleManager:CreateParticleForPlayer("particles/rain_fx/econ_weather_sirocco.vpcf", PATTACH_EYES_FOLLOW, hero, hero:GetPlayerOwner())
					-- end)
				-- end)
			elseif self.stage == self.STAGE_SECOND then

			end
		end	
	end
end

function Temple:FallingRocks()
	local start_stage = self.stage

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

function Temple:SetupMap()
	self.obelisks = DistributeUnits( self.obelisks_positions, "npc_temple_obelisk", self.OBELISK_COUNT, DOTA_TEAM_NEUTRALS, function (obelisk)
		for i=#self.obelisks,1,-1 do
		    if self.obelisks[i] == obelisk then
		        table.remove(self.obelisks, i)
		        self:SetObelisksCount()
		    end
		end
	end )
	self:SetObelisksCount()

	self:SpawnCreeps()
end

function Temple:SpawnCreeps()
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

function Temple:InitBossArea()
	self.boss_area_container = {}

	local last = self.boss_area[#self.boss_area]

	for k, v in orderedPairs(self.boss_area) do
		local wall = ParticleManager:CreateParticle("particles/bosses/ziv_boss_area.vpcf",PATTACH_CUSTOMORIGIN,nil)
		ParticleManager:SetParticleControl(wall,0,last)
		ParticleManager:SetParticleControl(wall,1,v)
		last = v

		table.insert(self.boss_area_container, wall)
	end

	DistributeUnitsAlongPolygonPath(self.boss_area, function ( pos, is_tower )
		local blocker = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = pos, block_fow = true})

		local pos = GetGroundPosition(pos, blocker)
        blocker:SetAbsOrigin(pos)

		table.insert(self.boss_area_container, blocker)
	end, 32)

	DoToAllHeroes(function ( hero )
		hero:AddNewModifier(hero,hero,"modifier_area_lock",{}).area = self.boss_area
	end)
end

function Temple:CleanupBossFight()
	if self.boss_area_container then
		for k,v in pairs(self.boss_area_container) do
			if type(v) == "number" then
				ParticleManager:DestroyParticle(v, false)
			else
				UTIL_Remove(v)
			end
		end

		DoToAllHeroes(function ( hero )
			hero:RemoveModifierByName("modifier_area_lock")
		end)
	end
end

function Temple:InitBossFight()
	self:CleanupBossFight()
	self:InitBossArea()


end

return Temple
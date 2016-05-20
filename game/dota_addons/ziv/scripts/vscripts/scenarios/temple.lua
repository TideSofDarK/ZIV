Temple = {}

Temple.STAGE_NO = -1
Temple.STAGE_PREGAME = 0
Temple.STAGE_FIRST = 1
Temple.STAGE_SECOND = 2
Temple.STAGE_THIRD = 3
Temple.STAGE_BOSS = 4
Temple.STAGE_END = 5

Temple.stage = Temple.STAGE_NO

Temple.OBELISK_COUNT = 20

Temple.obelisks_positions = {}
Temple.creeps_positions = {}
Temple.obelisks = {}

function Temple:Init()
	Temple.obelisks_positions = Entities:FindAllByName("ziv_temple_obelisk")
	Temple.creeps_positions = Entities:FindAllByName("ziv_basic_creep_spawner")
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

			Temple:FallingRocks()
		elseif Temple.stage == Temple.STAGE_BOSS then

		else
			Temple:SetupMap()

			if Temple.stage == Temple.STAGE_PREGAME then
				local duration = 5.0

				DoToAllHeroes(function ( hero )
					hero:AddNewModifier(hero,nil,"modifier_smooth_floating",{duration = duration})
					TimedEffect( "particles/unique/temple/temple_floating_particle.vpcf", hero, duration, 0 )

					Physics:Unit(hero)
					hero:FollowNavMesh(false)

					local collider = hero:AddColliderFromProfile("gravity")
					collider.filter = heroes
					collider.radius = 200
					collider.fullRadius = 0
					collider.minRadius = 0
					collider.force = 8000
					collider.linear = false
					collider.test = function(self, collider, collided)
						return IsPhysicsUnit(collided)
					end

					Timers:CreateTimer(duration, function (  )
				        local seed = (math.random(1, 4) * 90) + 35

				        local point = PointOnCircle(7085, seed)

				        hero:AddPhysicsVelocity(Vector(point.x, point.y, 1750))
				        hero:SetPhysicsAcceleration(Vector(0,0,-1400))

				        StartAnimation(hero, {duration=3.5, activity=ACT_DOTA_FLAIL, rate=1.0})
				        Timers:CreateTimer(3.5, function (  )
				        	hero:RemoveCollider()
				        	hero:StopPhysicsSimulation ()

				        	hero.GetPhysicsVelocity = nil
				        end)
					end)
				end)

				Timers:CreateTimer(duration, function (  )
					Temple:NextStage()
				end)
			elseif Temple.stage == Temple.STAGE_SECOND then

			elseif Temple.stage == Temple.STAGE_THIRD then

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

					Timers:CreateTimer(2.0, function ()
						local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
						for k,v in pairs(units) do
							if v ~= unit then
								DealDamage( unit, v, v:GetMaxHealth()/50, DAMAGE_TYPE_PHYSICAL ) 
								v:EmitSound("Creep_Good_Melee_Mega.Attack")
							end
						end

						timer = timer + 0.1
						if timer < 1.0 then return 0.1 
						else 
							ParticleManager:DestroyParticle(particle,false)
							unit:ForceKill(false)
						end
					end)
				end)
				return math.random(3.0, 7.0)
			end
			return math.random(0.0, 2.0)
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
	local i = 1
	for k,v in pairs(Temple.creeps_positions) do
		Director:SpawnPack(
	    {
	        Level = 1,
	        SpawnBasic = true,
	        Count = math.random(10, 25),
	        Position = v:GetAbsOrigin(),
	        CheckHeight = true,
	        SpawnLord = i % 3 == 0
	    })
	    i = i + 1
	end
end
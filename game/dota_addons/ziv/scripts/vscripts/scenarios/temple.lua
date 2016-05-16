Temple = {}

Temple.STAGE_NO = -1
Temple.STAGE_FIRST = 0
Temple.STAGE_SECOND = 1
Temple.STAGE_THIRD = 2
Temple.STAGE_BOSS = 3
Temple.STAGE_END = 4

Temple.stage = Temple.STAGE_NO

Temple.OBELISK_COUNT = 20

Temple.obelisks_positions = {}
Temple.creeps_positions = {}
Temple.obelisks = {}

function Temple:Init()
	Temple.obelisks_positions = Entities:FindAllByName("ziv_temple_obelisk")
	Temple.creeps_positions = Entities:FindAllByName("ziv_basic_creep_spawner")
end

function Temple:NextStage()
	Temple.stage = Temple.stage + 1

	if Temple.stage == Temple.STAGE_END then

	else
		DistributeUnits( Temple.obelisks_positions, "npc_temple_obelisk", Temple.OBELISK_COUNT, DOTA_TEAM_NEUTRALS )
		Temple:SpawnCreeps()

		if Temple.stage == Temple.STAGE_FIRST then
			DoToAllHeroes(function ( hero )
				local duration = 10.0

				hero:AddNewModifier(hero,nil,"modifier_smooth_floating",{duration = duration})
				TimedEffect( "particles/unique/temple/temple_floating_particle.vpcf", hero, duration, 0 )

			end)
		elseif Temple.stage == Temple.STAGE_SECOND then

		elseif Temple.stage == Temple.STAGE_THIRD then

		elseif Temple.stage == Temple.STAGE_BOSS then

		end
	end
end

function Temple:SpawnCreeps()
	for k,v in pairs(Temple.creeps_positions) do
		Director:SpawnPack(
	    {
	        Level = 1,
	        SpawnBasic = true,
	        Count = math.random(8, 16),
	        Position = v:GetAbsOrigin(),
	        CheckHeight = true,
	        SpawnLord = math.random(0, 3) == 1
	    })
	end
end
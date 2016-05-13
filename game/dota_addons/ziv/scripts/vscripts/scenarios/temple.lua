if Temple == nil then
    _G.Temple = class({})
end

Temple.STAGE_NO = -1
Temple.STAGE_FIRST = 0
Temple.STAGE_SECOND = 1
Temple.STAGE_THIRD = 2
Temple.STAGE_BOSS = 3
Temple.STAGE_END = 4

Temple.stage = Temple.STAGE_NO

Temple.OBELISK_COUNT = 20

Temple.obelisks_positions = {}
Temple.obelisks = {}

function Temple:Init()
	Temple.obelisks_positions = Entities:FindAllByName("ziv_temple_obelisk")

	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
end

function Temple:SpawnObelisks()
	if #Temple.obelisks_positions == 0 then return end
	local obelisks = Shuffle(Temple.obelisks_positions)
	local obelisks_count = Temple.OBELISK_COUNT

	Temple.obelisks = {}

	local i = 1
	for k,v in pairs(obelisks) do
		if i >= obelisks_count then return end 
		table.insert(Temple.obelisks, CreateUnitByName("npc_temple_obelisk", v:GetAbsOrigin(), false, nil, nil,DOTA_TEAM_NEUTRALS))
		i = i + 1
	end
end

function Temple:NextStage()
	Temple.stage = Temple.stage + 1

	if Temple.stage == Temple.STAGE_END then

	else
		Temple:SpawnObelisks()

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
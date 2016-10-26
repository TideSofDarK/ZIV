if Debug == nil then
    _G.Debug = class({})
end

function Debug:Init()
	CustomGameEventManager:RegisterListener( "ziv_debug_create_boss", Dynamic_Wrap(Debug, 'CreateBoss'))
	CustomGameEventManager:RegisterListener( "ziv_debug_remove_boss", Dynamic_Wrap(Debug, 'RemoveBoss'))
	CustomGameEventManager:RegisterListener( "ziv_debug_heal_boss", Dynamic_Wrap(Debug, 'HealBoss'))
	CustomGameEventManager:RegisterListener( "ziv_debug_change_boss_state", Dynamic_Wrap(Debug, 'ChangeBossState'))
end

function Debug:CreateBoss( args )
  local player = PlayerResource:GetPlayer(args.PlayerID)
  local position = player:GetAssignedHero():GetAbsOrigin()
	Director:SpawnBoss( args.boss_name, position )
end

function Debug:RemoveBoss( args )
	local boss = EntIndexToHScript(CustomNetTables:GetTableValue( "scenario", "boss" ).entindex)

	if boss then
		boss:RemoveSelf()
	end
end

function Debug:ChangeBossState( args )
	local boss = EntIndexToHScript(CustomNetTables:GetTableValue( "scenario", "boss" ).entindex)
	-- TO DO
end

function Debug:HealBoss( args )
	local boss = EntIndexToHScript(CustomNetTables:GetTableValue( "scenario", "boss" ).entindex)

	if boss then
		boss:Heal(boss:GetMaxHealth(),nil)
	end
end
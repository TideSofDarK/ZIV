if Debug == nil then
    _G.Debug = class({})
end

function Debug:Init()
	CustomGameEventManager:RegisterListener( "ziv_debug_create_boss", Dynamic_Wrap(Debug, 'CreateBoss'))
	CustomGameEventManager:RegisterListener( "ziv_debug_remove_boss", Dynamic_Wrap(Debug, 'RemoveBoss'))
	CustomGameEventManager:RegisterListener( "ziv_debug_heal_boss", Dynamic_Wrap(Debug, 'HealBoss'))
end

function Debug:CreateBoss( args )
	Director:SpawnBoss( args.boss_name )
end

function Debug:RemoveBoss( args )
	local boss = EntIndexToHScript(CustomNetTables:GetTableValue( "scenario", "boss" ).entindex)

	if boss then
		boss:RemoveSelf()
	end
end

function Debug:HealBoss( args )
	local boss = EntIndexToHScript(CustomNetTables:GetTableValue( "scenario", "boss" ).entindex)

	if boss then
		boss:Heal(boss:GetMaxHealth(),nil)
	end
end
if Debug == nil then
    _G.Debug = class({})
end

function Debug:Init()
	CustomGameEventManager:RegisterListener( "ziv_debug_create_boss", Dynamic_Wrap(Debug, 'CreateBoss'))
	CustomGameEventManager:RegisterListener( "ziv_debug_remove_boss", Dynamic_Wrap(Debug, 'RemoveBoss'))
	CustomGameEventManager:RegisterListener( "ziv_debug_change_boss_state", Dynamic_Wrap(Debug, 'ChangeBossState'))
  CustomGameEventManager:RegisterListener( "ziv_debug_change_boss_lock_state", Dynamic_Wrap(Debug, 'LockBossState'))
  CustomGameEventManager:RegisterListener( "ziv_debug_change_boss_health", Dynamic_Wrap(Debug, 'ChangeBossHealth'))
end

function Debug:GetBossUnit()
  local tableValue = CustomNetTables:GetTableValue( "scenario", "boss" )
  if tableValue == nil then
    return nil
  end

  return EntIndexToHScript(tableValue.entindex)
end

function Debug:CreateBoss( args )
  local boss = Debug:GetBossUnit()
  if boss then
		boss:RemoveSelf()
	end
  
  local player = PlayerResource:GetPlayer(args.PlayerID)
  local position = player:GetAssignedHero():GetAbsOrigin()
	Director:SpawnBoss( args.boss_name, position )
end

function Debug:RemoveBoss( args )
	local boss = Debug:GetBossUnit()

	if boss then
		boss:RemoveSelf()
	end
end

function Debug:ChangeBossState( args )
	local boss = Debug:GetBossUnit()
	if boss then
    boss.sfm:SetState(args.state, true)
    boss.sfm:LockState(true)
  end  
end

function Debug:LockBossState( args )
	local boss = Debug:GetBossUnit()
	if boss then
    boss.sfm:LockState(args.lock == 1)
  end  
end
function Debug:ChangeBossHealth( args )
	local boss = Debug:GetBossUnit()
	if boss then
    boss:SetHealth(args.health * boss:GetMaxHealth())
  end  
end

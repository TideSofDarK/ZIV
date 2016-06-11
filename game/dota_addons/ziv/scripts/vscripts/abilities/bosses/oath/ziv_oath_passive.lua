-- Get hero with max aggro
function GetMaxAggro( caster )
  if GetTableLength(caster.aggroTable) < 1 then
    return nil
  end
  
  table.sort(caster.aggroTable)  
  for k,v in pairs(caster.aggroTable) do
    if v == 0 then
      return nil
    end
    
    return EntIndexToHScript(k)
  end
end

-----------------------------
-- Idle handlers
-----------------------------
function Idle( caster )
  caster:MoveToPosition(caster.spawnPoint)
  --caster.aggroTable = {}
end

function IdleChasingCond( caster ) 
  local hero = GetMaxAggro( caster )
  if hero == nil then
    return false
  end
  
  if (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > 500 then
    return true
  end

  return false
end

function IdleCastingCond( caster )
  local hero = GetMaxAggro( caster )
  if hero == nil then
    return false
  end
  
  if hero:IsAlive() and (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < 700 then
    return true
  end

  return false
end

-----------------------------
-- Chasing handlers
-----------------------------
function Chasing( caster )
  local hero = GetMaxAggro( caster )
  caster:MoveToTargetToAttack(hero)
end

function ChasingIdleCond( caster )
  local hero = GetMaxAggro( caster )
  if hero == nil then
    return true
  end 
  
  local length = (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
  if not hero:IsAlive() or length > 1000 then
    return true
  end
  
  return false
end

function ChasingCastingCond( caster )
  local hero = GetMaxAggro( caster )
  
  if hero == nil then
    return false
  end
  
  local length = (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
  if length < 700 then
    return true
  end
end

-----------------------------
-- Casting handlers
-----------------------------
function Casting( caster )
	local hero = GetMaxAggro( caster )
  if hero == nil then
    return
  end
  
  local unit = caster

	local abilities = {}
	for i=0,16 do
		local ability = unit:GetAbilityByIndex(i)

		-- if ability and DOTA_ABILITY_BEHAVIOR_HIDDEN ~= bit.band( DOTA_ABILITY_BEHAVIOR_HIDDEN, ability:GetBehavior() ) and ability:IsCooldownReady() then abilities[ability] = ability:GetCastRange() end 
		if ability 
			and DOTA_ABILITY_BEHAVIOR_HIDDEN ~= bit.band( DOTA_ABILITY_BEHAVIOR_HIDDEN, ability:GetBehavior() ) 
			and ability:IsFullyCastable()
			and (not ability:GetKeyValue("HPThreshold") or (unit:GetHealth() / unit:GetMaxHealth()) < (ability:GetKeyValue("HPThreshold") / 100))
			and ability:IsInAbilityPhase() == false
			and (ability:GetCastRange() >= (hero:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D() or DOTA_ABILITY_BEHAVIOR_NO_TARGET == bit.band( DOTA_ABILITY_BEHAVIOR_NO_TARGET, ability:GetBehavior() ))
			then table.insert(abilities, ability) end 
	end

	local next_ability = GetRandomElement(abilities)

	if next_ability then
		-- Timers:CreateTimer(math.random(0.0, 3.25), function (  )
			if DOTA_ABILITY_BEHAVIOR_NO_TARGET == bit.band( DOTA_ABILITY_BEHAVIOR_NO_TARGET, next_ability:GetBehavior() ) then
				unit:CastAbilityNoTarget(next_ability,-1)
			elseif DOTA_ABILITY_BEHAVIOR_UNIT_TARGET == bit.band( DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, next_ability:GetBehavior() ) then
				unit:CastAbilityOnTarget(hero,next_ability,-1)
			elseif DOTA_ABILITY_BEHAVIOR_POINT == bit.band( DOTA_ABILITY_BEHAVIOR_POINT, next_ability:GetBehavior() ) then
				unit:CastAbilityOnPosition(hero:GetAbsOrigin() + Vector(math.random(-20.0, 20.0), math.random(-20.0, 20.0), 0.0),next_ability,-1)
			end
	end  
end

function CastingChasingCond( caster )
  local hero = GetMaxAggro( caster )
  if hero == nil then
    return false
  end 
  
  local length = (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
  if length > 700 and length < 1000 then
    return true
  end  
end

function CastingIdleCond( caster )
  local hero = GetMaxAggro( caster )
  if hero == nil then
    return true
  end   
  
   if not hero:IsAlive() then
    return true
  end  
end

local sfm = { 
  initial_state = 'idle',
  states = { 
    idle = { funct = Idle, transitions = { chasing = IdleChasingCond, casting = IdleCastingCond } }, 
    chasing = { funct = Chasing, transitions = { idle = ChasingIdleCond, casting = ChasingCastingCond } },
    casting = { funct = Casting, transitions = { idle = CastingIdleCond, chasing = CastingChasingCond } }
  }
}

function Start( keys )
	local caster = keys.caster
  caster.spawnPoint = caster:GetAbsOrigin()
	local ability = keys.ability

	local intro_duration = GetSpecial(ability, "intro_duration")

	AddAnimationTranslate(caster, "desolation")

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_oath_invu",{duration = intro_duration})

	StartAnimation(caster, {duration=intro_duration, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.0})

	Timers:CreateTimer(intro_duration, function (  )
		AI:BossStart( keys, sfm )
		caster:RemoveModifierByName("modifier_boss_hpbar_panel_spawner")
	end)
end
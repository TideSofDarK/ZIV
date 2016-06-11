if AI == nil then
    _G.AI = class({})
end

BOSS_STATE_IDLE = 0
BOSS_STATE_CHASING = 1
BOSS_STATE_CASTING = 2

function AI:BossStart( keys )
	local caster = keys.caster

	caster:AddNewModifier(caster,nil,"modifier_boss_ai",{})

	Timers:CreateTimer(function (  )
		if IsValidEntity(caster) == false then return end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, caster:GetCurrentVisionRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		if #units > 0 then
			if caster.state == BOSS_STATE_CASTING then
				return 0.09
			else
				caster.state = BOSS_STATE_CHASING
			end

			local hero = GetRandomElement(units)

			caster:MoveToNPC(hero)

			-- Timers:CreateTimer(math.random(0.0, 1.0), function (  )
				AI:BossCasting( caster, units )
			-- end)
		elseif caster:IsChanneling() == false then
			caster:Stop()
			caster.state = BOSS_STATE_IDLE
		end

		return 0.5
	end)
end

function AI:BossCasting( unit, targets )
	local hero = GetRandomElement(targets)

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
			unit.state = BOSS_STATE_CASTING
			-- print(next_ability:GetName())
			-- next_ability:StartCooldown(next_ability:GetCooldown(0))
			Timers:CreateTimer((next_ability:GetCastPoint() * 1.1) + next_ability:GetChannelTime(), function (  ) -- + next_ability:GetChannelTime()
				if next_ability:IsInAbilityPhase() == true then
					return 0.1
				else
					unit.state = BOSS_STATE_CHASING
				end
			end)
		-- end)
	end
end
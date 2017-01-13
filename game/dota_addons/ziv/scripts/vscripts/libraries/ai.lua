require('libraries/ai_default_sfm')

if AI == nil then
    _G.AI = class({})
end

-- Init boss AI
function AI:BossStart( boss )
  -- Add SFM to boss
  SFM(boss)
	boss:AddNewModifier(boss, nil,"modifier_boss_ai",{})

	boss.sfm.aggro:SetMode(AggroMode.Random, 10)
	boss.sfm:Think()
end

function AI:CreepStart( unit )
	local flags_string = ZIV.UnitKVs[unit:GetUnitName()]["AIFlags"]
	if flags_string then
		local flags = KeyValues:Split(flags_string, " | ")
		PrintTable(falgs)
		for k,v in pairs(flags) do
			if AI[v] then
				AI[v](nil, unit)
			end
		end
	end
end

function AI:FleeOnLowHP(unit)
	unit:AddOnTakeDamageCallback( function ( keys )
		local damage = keys.damage
		if unit:GetHealthPercent() < 35 then
			unit:MoveToPosition((unit:GetForwardVector() * -600) + unit:GetAbsOrigin())
			return true
		end
	end )
end

function AI:MoveDuringFight(unit)
	unit:AddOnAttackLandedCallback(function (target)
		unit.ai_attacks = (unit.ai_attacks or 0) + 1
		unit.ai_next_attacks = unit.ai_next_attacks or math.random(2, 5)

		if unit.ai_attacks >= unit.ai_next_attacks then
			local target = unit:GetAttackTarget()
			if not target then return end
			local position = RotatePosition(target:GetAbsOrigin(), QAngle(0,math.random(-20, 20),0), unit:GetAbsOrigin())

			unit:MoveToPosition(position)

			unit.ai_attacks = 0
			unit.ai_next_attacks = math.random(1, 4)
		end
	end)
end

function AI:TryToKeepDistance(unit)

end

---------------------------------
-- Following for summons
---------------------------------

function SummonFollow( caster, summon, update_rate, follow_range, attack_range )
	Timers:CreateTimer(update_rate, function (  )
		if caster:IsNull() or summon:IsNull() or not caster:IsAlive() or not summon:IsAlive() then
			return
		end

		local distance = Distance(caster, summon)

		-- if caster:IsAttacking() == true then
		-- 	summon:MoveToTargetToAttack(caster:GetAttackTarget())
		if distance > follow_range + attack_range then
			summon:MoveToPosition((caster:GetAbsOrigin() + (caster:GetForwardVector() * 350)))
		elseif summon:IsAttacking() == false then
			local units = FindUnitsInRadius(caster:GetTeamNumber(), summon:GetAbsOrigin(), nil, attack_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		
			if #units > 0 then
				summon:MoveToTargetToAttack(units[1])
			else
				if distance > follow_range then
					summon:MoveToPosition((caster:GetAbsOrigin() + (caster:GetForwardVector() * 350)))
				else
					summon.last_walking_time = summon.last_walking_time or ZIV.TRUE_TIME
					if ZIV.TRUE_TIME - summon.last_walking_time > math.random(3.5, 5.1) then
						summon:MoveToPosition(caster:GetAbsOrigin() + RandomPointOnCircle(325))
						summon.last_walking_time = ZIV.TRUE_TIME
					end
				end
			end
		end

		return update_rate
	end)
end
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
	unit:AddOnTakeDamageCallback( function ( damage )
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
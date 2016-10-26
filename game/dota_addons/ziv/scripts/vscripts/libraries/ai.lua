require('libraries/ai_default_sfm')

if AI == nil then
    _G.AI = class({})
end

-- Init boss AI
function AI:BossStart( keys, sfm )
	caster = keys.caster
	caster:AddNewModifier(caster,nil,"modifier_boss_ai",{})

	caster.sfm = SFM( caster )
	caster.sfm.aggro:SetMode(AggroMode.Random, 10)
	caster.sfm:Think()
end

function AI:CreepStart( unit )
	local flags_string = ZIV.UnitKVs[unit:GetUnitName()]["AIFlags"]
	if flags_string then
		local flags = KeyValues:Split(flags_string, " | ")
		PrintTable(falgs)
		for k,v in pairs(flags) do
			if AI[v] then

			end
		end
	end
end

function AI:FleeOnLowHP(unit)
	unit:AddOnTakeDamageCallback( function ( damage )
		if unit:GetHealthPercent() < 35 then
			print("Asd")
			return true
		end
	end )
end

function AI:MoveDuringFight(unit)

end

function AI:TryToKeepDistance(unit)

end
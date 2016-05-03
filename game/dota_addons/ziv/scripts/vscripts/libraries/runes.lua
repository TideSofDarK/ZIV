function GRMSC(name,caster)
	return caster:GetModifierStackCount(name,nil) or 0
end

function GetRuneDamageIncrease(name,caster)
	return ((GRMSC(name,caster) / 100) + 1) * caster:GetAverageTrueAttackDamage()
end

function GetRuneChance(name,caster)
	return math.random(0, 100) > GRMSC(name,caster)
end

function BasicPropertyRune(keys)
	local caster = keys.caster
	local ability = keys.ability

	if keys.check_modifier and caster:HasModifier("keys.check_modifier") == false then
		caster:RemoveModifierByName(keys.modifier_name)
	else
		local stacks = GRMSC(keys.rune_modifier,caster)

		if stacks > 0 then
			ability:ApplyDataDrivenModifier(caster,caster,keys.modifier_name,{})
			caster:SetModifierStackCount(keys.modifier_name,caster,stacks)
		else
			caster:RemoveModifierByName(keys.modifier_name)
		end
	end

	Timers:CreateTimer(0.1, function (  )
		BasicPropertyRune(keys)
	end)
end
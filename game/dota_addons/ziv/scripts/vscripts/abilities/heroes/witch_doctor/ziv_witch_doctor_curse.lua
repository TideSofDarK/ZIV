function Curse( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	local damage_amp = ability:GetSpecialValueFor("damage_amp")

	ability.damage = damage_amp

	for k,v in pairs(units) do
		ability:ApplyDataDrivenModifier(caster,v,"modifier_witch_doctor_curse",{duration = GetSpecial(ability, "duration") + GRMSC("ziv_witch_doctor_curse_duration", caster)})
		v:SetModifierStackCount("modifier_witch_doctor_curse",caster,GetSpecial(ability, "slow") + GRMSC("ziv_witch_doctor_curse_slow", caster))
		v:EmitSound("Hero_Treant.Overgrowth.Target")
	end

	caster:EmitSound("Hero_Riki.Pick")
end

function Damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local final_damage = math.ceil(ability.damage) * GetRuneDamage("ziv_witch_doctor_curse_damage",caster)

	PopupDamageOverTime(target, final_damage)

	DealDamage(caster, target, final_damage, DAMAGE_TYPE_DARK)
end
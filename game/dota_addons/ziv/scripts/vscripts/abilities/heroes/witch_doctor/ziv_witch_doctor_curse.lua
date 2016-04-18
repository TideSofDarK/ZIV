function Curse( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	local damage_amp = ability:GetSpecialValueFor("damage_amp")

	ability.damage = caster:GetAverageTrueAttackDamage() * damage_amp

	for k,v in pairs(units) do
		ability:ApplyDataDrivenModifier(v,v,"modifier_witch_doctor_curse",{})
		v:EmitSound("Hero_Treant.Overgrowth.Target")
	end

	caster:EmitSound("Hero_Riki.Pick")
end

function Damage( keys )
	local caster = keys.caster
	local ability = keys.ability

	local final_damage = math.ceil(ability.damage)

	PopupDamageOverTime(caster, final_damage)

	DealDamage(caster, caster, final_damage, DAMAGE_TYPE_MAGICAL)
end
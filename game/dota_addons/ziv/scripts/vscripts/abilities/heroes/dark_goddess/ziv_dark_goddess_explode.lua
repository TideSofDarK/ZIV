function Explode( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),target,nil,ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local max_targets = ability:GetSpecialValueFor("max_targets") + GRMSC("ziv_dark_goddess_explode_targets",caster)

	if #units > 0 then
		StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.5})
		caster:EmitSound("Ability.DarkRitual")

		local i = 1
		for k,v in pairs(units) do
			if i > max_targets then
				return
			end
			if v:GetUnitName() == "npc_dark_goddess_spirit" then
				local explosion = ParticleManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_explode.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)

				local units_to_damage = FindUnitsInRadius(caster:GetTeamNumber(),v:GetAbsOrigin(),nil,ability:GetSpecialValueFor("explosion_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				for k2,v2 in pairs(units_to_damage) do
					DealDamage(caster, v2, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_DARK)
				end

				v:EmitSound("Hero_Enigma.Pick")

				DestroyEntityBasedOnHealth(v, v)

				i = i + 1
			end
		end
	end
end
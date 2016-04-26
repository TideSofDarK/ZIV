function Explode( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),target,nil,ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for k,v in pairs(units) do
		if v:GetUnitName() == "npc_dark_goddess_spirit" then
			local explosion = ParticleManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_explode.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
			v:AddNewModifier(v, ability, "modifier_kill", {duration = 0.1})

			local units_to_damage = FindUnitsInRadius(caster:GetTeamNumber(),v:GetAbsOrigin(),nil,ability:GetSpecialValueFor("explosion_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for k2,v2 in pairs(units_to_damage) do
				DealDamage(caster, v, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_MAGICAL)
			end

			v:EmitSound("Hero_Enigma.Pick")
		end
	end
end
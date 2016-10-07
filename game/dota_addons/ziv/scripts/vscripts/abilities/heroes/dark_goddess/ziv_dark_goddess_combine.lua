function Combine( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),target,nil,ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local max_targets = ability:GetSpecialValueFor("max_targets") + GRMSC("ziv_dark_goddess_combine_targets",caster)

	if #units > 0 then
		StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.5})
		caster:EmitSound("Ability.DarkRitual")

		local i = 1
		for k,v in pairs(units) do
			if i > max_targets then
				return
			end
			if v:GetUnitName() == "npc_dark_goddess_spirit" then
				if i == #units then
					-- v:RemoveModifierByName("modifier_kill")
					v:SetModelScale(v:GetModelScale() + (i * 0.1325))
					ability:ApplyDataDrivenModifier(caster,v,"modifier_corrupted_spirit_combined",{})
					v:SetModifierStackCount("modifier_corrupted_spirit_combined",caster,i)
					v:AddNewModifier(caster,ability,"modifier_invulnerable",{(i * ability:GetSpecialValueFor("bonus_duration")) * 0.97})
					v:AddNewModifier(caster,ability,"modifier_kill",{i * ability:GetSpecialValueFor("bonus_duration")})
				else
					local explosion = ParticleManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_explode.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)

					v:EmitSound("Hero_Enigma.Pick")

					v:RemoveSelf()
				end

				i = i + 1
			end
		end
	end
end
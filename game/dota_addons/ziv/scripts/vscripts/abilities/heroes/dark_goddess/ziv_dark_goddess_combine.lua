function Combine( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),target,nil,ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local spirits_needed = GetSpecial(ability, "spirits_needed")
	local max_combined_spirits = GetSpecial(ability, "max_combined_spirits")

	ability.combined_spirits = ability.combined_spirits or {}

	if #ability.combined_spirits >= max_combined_spirits then
		return
	end

	if #units >= spirits_needed then
		-- StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.5})
		caster:EmitSound("Ability.DarkRitual")

		local i = 1
		for k,v in pairs(units) do
			if v:GetUnitName() == "npc_dark_goddess_spirit" then
				if i == spirits_needed then
					v:SetModelScale(v:GetModelScale() * 2.0)
					ability:ApplyDataDrivenModifier(caster,v,"modifier_corrupted_spirit_combined",{})

					v:RemoveAllOnDiedCallbacks( )

					v:AddOnDiedCallback(function ()
						ability.combined_spirits[v:entindex()] = nil
					end)

					ability.combined_spirits[v:entindex()] = v

					v:SetRenderColor(255,138,13)

					v:EmitSound("Hero_Enigma.Pick")

					return
				else
					local explosion = ParticleManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_explode.vpcf",PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(explosion,0,v:GetAttachmentOrigin(v:ScriptLookupAttachment("attach_hitloc")))

					v:ForceKill(false)
				end

				i = i + 1
			end
		end
	end
end
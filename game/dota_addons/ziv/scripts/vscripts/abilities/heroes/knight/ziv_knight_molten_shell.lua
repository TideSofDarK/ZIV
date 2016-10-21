function MoltenShell( keys )
	local caster = keys.caster
	local ability = keys.ability

	StartAnimation(caster, {duration=0.75, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.8})

	local particle = ParticleManager:CreateParticle( "particles/heroes/knight/knight_molten_shell.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	-- ParticleManager:SetParticleControlEnt( particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( particle, 6, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex( particle )
end
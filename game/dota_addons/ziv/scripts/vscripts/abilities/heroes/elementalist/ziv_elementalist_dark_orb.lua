function FireOrb( keys )
	keys.on_hit = DarkOrbOnHit
	keys.standard_targeting = true
	SimulateRangeAttack(keys)
end

function DarkOrbOnHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local particle = ParticleManager:CreateParticle("particles/heroes/elementalist/elementalist_dark_orb_explosion.vpcf",PATTACH_ABSORIGIN,target)
	ParticleManager:SetParticleControl(particle,3,target:GetAttachmentOrigin(target:ScriptLookupAttachment(keys.attachment or "attach_hitloc")))

	local units = FindUnitsInRadius(caster:GetTeamNumber(),target:GetAbsOrigin(),nil,ability:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

	for k,v in pairs(units) do
		if IsValidEntity(v) then
			DealDamage(caster, v, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_elementalist_dark_orb_damage"), DAMAGE_TYPE_DARK)
		end
	end
end
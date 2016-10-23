function MoltenShell( keys )
	local caster = keys.caster
	local ability = keys.ability

	StartRuneCooldown(ability,"ziv_knight_molten_shell_cd",caster)

	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_OVERRIDE_ABILITY_4, rate=2.2, translate="sven_warcry", translate2="sven_shield"})

	local particle = ParticleManager:CreateParticle( "particles/heroes/knight/knight_molten_shell.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )

	ParticleManager:SetParticleControlEnt( particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( particle, 6, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex( particle )

	local duration = GetSpecial(ability, "duration")

	Damage:Modify(caster, Damage.FIRE_RESISTANCE, GetSpecial(ability, "fire_damage_reduction"), duration)
	Damage:Modify(caster, Damage.COLD_RESISTANCE, GetSpecial(ability, "cold_damage_reduction"), duration)
	Damage:Modify(caster, Damage.LIGHTNING_RESISTANCE, GetSpecial(ability, "lightning_damage_reduction"), duration)
	Damage:Modify(caster, Damage.DARK_RESISTANCE, GetSpecial(ability, "dark_damage_reduction"), duration)

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_molten_shell_buff",{duration = duration})

	caster:EmitSound("Hero_Juggernaut.OmniSlash")
end

function OnTakeDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.attack_damage

	if not ability:IsCooldownReady() then return end

	local current_stacks = caster:GetModifierStackCount("modifier_molten_shell",caster)

	current_stacks = current_stacks - damage

	if current_stacks <= 0 then
		ResetThreshold( keys )
		MoltenShell( keys )
	else
		caster:SetModifierStackCount("modifier_molten_shell",caster,current_stacks)
	end
end

function ResetThreshold( keys )
	local caster = keys.caster
	local ability = keys.ability

	local threshold = GetSpecial(ability, "damage_threshold") - GRMSC("ziv_knight_molten_shell_threshold", caster)

	caster:SetModifierStackCount("modifier_molten_shell",caster,threshold)
end
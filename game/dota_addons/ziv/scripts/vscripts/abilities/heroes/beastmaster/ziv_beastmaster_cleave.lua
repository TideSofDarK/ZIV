function Cleave( keys )
	local keys = keys

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	StartRuneCooldown(ability,"ziv_beastmaster_cleave_speed",caster)

	ability.activity = ability.activity or ACT_DOTA_ATTACK_EVENT
	if ability.activity == ACT_DOTA_ATTACK_EVENT then
		ability.activity = ACT_DOTA_ATTACK2
		keys.attack_particle = "particles/units/heroes/hero_ursa/ursa_claw_right.vpcf"
	else
		ability.activity = ACT_DOTA_ATTACK_EVENT
		keys.attack_particle = "particles/units/heroes/hero_ursa/ursa_claw_left.vpcf"
	end

	keys.activity = ability.activity

	keys.duration = 0.1
	keys.rate = 3.0
	keys.base_attack_time = 0.25

	keys.on_impact = (function ( caster )
		local units = FindUnitsInCone(caster:GetAbsOrigin(), caster:GetForwardVector(), 300, 300 + GRMSC("ziv_beastmaster_cleave_aoe", caster), caster:GetTeamNumber(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER)
		
		for k,v in pairs(units) do
			ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf",PATTACH_ABSORIGIN,v)
			ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_poison_touch_blood.vpcf",PATTACH_ABSORIGIN,v)
			DealDamage(caster,v,caster:GetAverageTrueAttackDamage(), DAMAGE_TYPE_PHYSICAL)
		end
	end)

	SimulateMeleeAttack( keys )
end
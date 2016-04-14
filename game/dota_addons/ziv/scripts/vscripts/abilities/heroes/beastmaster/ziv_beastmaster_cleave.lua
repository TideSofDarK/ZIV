function Cleave( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:SetForwardVector((target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized())
	caster:Stop()

	local attack = ACT_DOTA_ATTACK
	if math.random(0,1) == 0 then
		attack = ACT_DOTA_ATTACK
	end

	local attack_particle = "particles/units/heroes/hero_ursa/ursa_claw_right.vpcf"
	if math.random(0,1) == 0 then
		attack_particle = "particles/units/heroes/hero_ursa/ursa_claw_left.vpcf"
	end
	ParticleManager:CreateParticle(attack_particle,PATTACH_ABSORIGIN,caster)

	caster:EmitSound("Hero_Ursa.Attack")

	DealDamage(caster,target,caster:GetAverageTrueAttackDamage()/2, DAMAGE_TYPE_PHYSICAL)

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 128, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(units) do
		ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf",PATTACH_ABSORIGIN,v)
		ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_poison_touch_blood.vpcf",PATTACH_ABSORIGIN,v)
		Timers:CreateTimer(0.06,function (  )
			DealDamage(caster,v,caster:GetAverageTrueAttackDamage()/2, DAMAGE_TYPE_PHYSICAL)
		end)
	end

	StartAnimation(caster, {duration=0.2, activity=attack, rate=3.0})
end
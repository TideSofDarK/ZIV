function Slash( keys )
	local keys = keys

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	keys.duration = 0.2
	keys.rate = 3.0
	keys.base_attack_time = 0.5

	keys.on_hit = (function ( keys )
		local target = keys.target
		local sparks = TimedEffect("particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire_explosion_c.vpcf", caster, 1.0, 3)
		ParticleManager:SetParticleControlEnt(sparks, 3, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)

		TimedEffect("particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire_explosion_c.vpcf", target, 1.0, 3)

		if GetRuneChance("item_rune_knight_slash_aoe_chance",caster) then
			TimedEffect("particles/heroes/knight/knight_slash_ring.vpcf", target, 1.0)
			DoToUnitsInRadius( caster, target:GetAbsOrigin(), 300, target_team, target_type, target_flags, function ( v )
				DealDamage(caster,v,GetRuneDamage("item_rune_knight_slash_damage",caster), DAMAGE_TYPE_PHYSICAL)
			end )
		else
			DealDamage(caster,target,GetRuneDamage("item_rune_knight_slash_damage",caster), DAMAGE_TYPE_PHYSICAL)
			if GetRuneChance("item_rune_knight_slash_stun_chance",caster) then
				target:AddNewModifier(caster,ability,"modifier_stunned",{duration = 0.2})
			end
		end
	end)

	SimulateMeleeAttack( keys )

	local sword_trail = ParticleManager:CreateParticle("particles/heroes/knight/knight_slash_trail.vpcf",PATTACH_POINT_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(sword_trail, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	Timers:CreateTimer(keys.base_attack_time, function (  )
		ParticleManager:DestroyParticle(sword_trail,false)
	end)
end
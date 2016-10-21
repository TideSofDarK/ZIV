function NewOrb( keys )
	local keys = keys

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability.orbs = ability.orbs or {}

	local particle = ParticleManager:CreateParticle("particles/heroes/knight/knight_orb_weapon.vpcf",PATTACH_CUSTOMORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(particle,0,caster,PATTACH_POINT_FOLLOW,"attach_attack1",caster:GetAbsOrigin(),false)

	table.insert(ability.orbs, particle)
end

function LaunchOrb( keys )
	local keys = keys
	
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	keys.bonus_attack_speed = GRMSC("ziv_knight_orb_as", caster)

	keys.projectile_speed = GetSpecial(ability, "projectile_speed") + GRMSC("ziv_knight_orb_projectile_speed", caster)

	keys.attack_sound = "Hero_DragonKnight.AttackOrb"

	keys.attachment = "attach_attack1"
	keys.interruptable = false
	keys.standard_targeting = true
	keys.on_impact = (function ( caster )
		ParticleManager:DestroyParticle(ability.orbs[#ability.orbs], true)

		Timers:CreateTimer(function (  )
			NewOrb( keys )
		end)
	end)
	keys.on_hit = OrbOnHit

	SimulateRangeAttack(keys)
end

function OrbOnHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	DoToUnitsInRadius( caster, target:GetAbsOrigin(), GetSpecial(ability, "explosion_radius"), nil, nil, nil, function ( v )
		if GetRuneChance("ziv_knight_orb_burn_chance",caster) then
			ability:ApplyDataDrivenModifier(caster,v,"modifier_knight_orb_burn",{})
		end
		
		DealDamage(caster, v, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_knight_orb_damage"), DAMAGE_TYPE_FIRE)

		TimedEffect("particles/heroes/knight/knight_orb_attack_o.vpcf", v, 3.0, 1, PATTACH_POINT_FOLLOW)
	end)
end
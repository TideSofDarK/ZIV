function Rain( keys )
	local caster = keys.caster
	local ability = keys.ability

	StartSoundEvent("Hero_DoomBringer.Doom",caster)

	Timers:CreateTimer(function ()
		TimedEffect("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_death.vpcf", caster, 1.0, 1)

		local position = RandomPointInsideCircle(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, ability:GetCastRange(), ability:GetCastRange() / 3)

		position.z = GetGroundHeight(position,caster)

		Blast( caster, ability, position)
		if ability:IsChanneling() then return GetSpecial(ability, "tick") 
		else
			StopSoundEvent("Hero_DoomBringer.Doom",caster)
		end
	end)
end

function Blast( caster, ability, position )
	EmitSoundOnLocationWithCaster(position,"Hero_SkeletonKing.Hellfire_Blast",caster)
	local particle = TimedEffect("particles/bosses/doom/doom_explosion.vpcf", caster, 5.0)
	ParticleManager:SetParticleControl(particle, 0, position)

	DoToUnitsInRadius( caster, position, ability:GetCastRange() / 5, nil, nil, nil, function ( target )
		Damage:Deal(caster, target, GetSpecial(ability, "damage_percent") * target:GetMaxHealth() / 2, DAMAGE_TYPE_FIRE)
		Damage:Deal(caster, target, GetSpecial(ability, "damage_percent") * target:GetMaxHealth() / 2, DAMAGE_TYPE_PHYSICAL)
	end )
end
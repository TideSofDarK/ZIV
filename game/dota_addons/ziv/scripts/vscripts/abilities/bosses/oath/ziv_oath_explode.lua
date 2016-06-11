function ExplodeStart( keys )
	local caster = keys.caster
	local ability = keys.ability

	local duration = tonumber(ability:GetKeyValue("AbilityChannelTime"))

	StartAnimation(caster, {duration=duration, activity=ACT_DOTA_TELEPORT, rate=1.0})

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_oath_exploding",{duration=duration})
	Explode( keys )
end

function Explode( keys )
	local caster = keys.caster
	local ability = keys.ability

	local delay = GetSpecial(ability, "delay")

	local position = RandomPointInsideCircle(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, GetSpecial(ability, "max_radius"), GetSpecial(ability, "min_radius"))
	position.z = GetGroundHeight(position,caster) + 64

	local particle = TimedEffect("particles/bosses/oath/oath_explode.vpcf", caster, 2.5)
	ParticleManager:SetParticleControl(particle,0,position)

	EmitSoundOnLocationWithCaster(position,"Hero_ObsidianDestroyer.EssenceAura",caster)
	
	Timers:CreateTimer(delay, function (  )
		ParticleManager:DestroyParticle(particle,true)

		particle = TimedEffect("particles/bosses/oath/oath_explode_explosion.vpcf", caster, 1.0)
		ParticleManager:SetParticleControl(particle,0,position)

		EmitSoundOnLocationWithCaster(position,"Hero_Invoker.ChaosMeteor.Impact",caster)

		DoToUnitsInRadius( caster, position, GetSpecial(ability, "explosion_radius"), target_team, target_type, target_flags, function ( v )
			DealDamage(caster, v, GetSpecial(ability, "damage_percent") * v:GetMaxHealth(), DAMAGE_TYPE_PHYSICAL)
		end)
	end)
end
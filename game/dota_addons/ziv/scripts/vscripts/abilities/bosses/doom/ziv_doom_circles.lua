function Circles( keys )
	local caster = keys.caster
	local ability = keys.ability

	local count = GetSpecial(ability, "circles_count")
	local duration = GetSpecial(ability, "duration")

	local points = RandomPointsInsideCircleUniform( caster:GetAbsOrigin(), ability:GetCastRange(), count, 210 )

	for i=1,count do
		local position = points[i]
		position.z = GetGroundHeight(position,caster)

		ability:ApplyDataDrivenThinker(caster,position,"modifier_doom_circle",{duration=duration})
		local particle = TimedEffect("particles/units/heroes/hero_doom_bringer/doom_bringer_doom_ring.vpcf", caster, duration + randomf( -1, 1 ))
		ParticleManager:SetParticleControl(particle,0,position)
	end

	Timers:CreateTimer(duration, function (  )
		StopSoundEvent("Hero_DoomBringer.Doom",caster)
	end)
end

function CircleThink(keys)
	local caster = keys.caster
	local thinker = keys.target
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),thinker:GetAbsOrigin(),nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	for k,v in pairs(units) do
		ability:ApplyDataDrivenModifier(caster,v,"modifier_doom_circle_damage",{})

		DealDamage(caster, v, GetSpecial(ability, "damage_percent") * v:GetMaxHealth(), DAMAGE_TYPE_FIRE)
	end
end
function Smoke( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenThinker(caster,caster:GetAbsOrigin(),"modifier_samurai_smoke",{duration = GetSpecial(ability, "duration")})
end

function SmokeParticle( keys )
	local caster = keys.caster
	local ability = keys.ability
	local thinker = keys.target

	local particle = TimedEffect("particles/heroes/samurai/samurai_smoke.vpcf", thinker, GetSpecial(ability, "duration"))
	ParticleManager:SetParticleControl(particle,1,Vector(GetSpecial(ability, "radius"),GetSpecial(ability, "radius"),GetSpecial(ability, "radius")))
end

function SmokeSlow( keys )
	local caster = keys.caster
	local ability = keys.ability
	local thinker = keys.target

	DoToUnitsInRadius( caster, thinker:GetAbsOrigin(), GetSpecial(ability, "radius"), nil, nil, nil, function ( creep )
		ability:ApplyDataDrivenModifier(caster,creep,"modifier_samurai_smoke_slow",{duration=0.5})
	end )
end
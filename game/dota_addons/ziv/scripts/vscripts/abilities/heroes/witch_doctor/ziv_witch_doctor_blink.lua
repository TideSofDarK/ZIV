function Blink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	caster:EmitSound("Hero_WitchDoctor.Maledict_Cast")

	local particle = ParticleManager:CreateParticle("particles/heroes/witch_doctor/witch_doctor_blink_fx.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(particle,0,target)

	Timers:CreateTimer(0.2, function ()
		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.9})
	end)

	Timers:CreateTimer(0.5, function ()
		FindClearSpaceForUnit(caster,target,false)
		
		Timers:CreateTimer(0.1,function (  )
			ParticleManager:CreateParticle("particles/econ/events/nexon_hero_compendium_2014/teleport_end_dust_nexon_hero_cp_2014.vpcf",PATTACH_ABSORIGIN,caster)
		end)
	end)
end
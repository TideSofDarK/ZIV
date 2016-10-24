function Descent(args)
	local caster = args.caster
	local ability = args.ability

	caster:RemoveModifierByName("modifier_spider_check")

	if not caster.descended then
		Timers:CreateTimer(math.random(0.0, 1.1), function (  )
			if not caster:IsNull() and caster:IsAlive() then
				return false
			end 
			local time = 2.5
			local distance = 1500

			StartAnimation(caster, {duration=time, activity=ACT_DOTA_RUN, rate=0.4})

			local old_pos = caster:GetAbsOrigin()
			local pos = old_pos
			pos.z = pos.z + distance
			caster:SetAbsOrigin(pos)

			EmitSoundOnLocationWithCaster(old_pos,"Spider.Spawn",caster)

			local web_particle = ParticleManager:CreateParticle("particles/creeps/ziv_spider.vpcf",PATTACH_RENDERORIGIN_FOLLOW,caster)
			ParticleManager:SetParticleControl(web_particle,6,pos)
			ParticleManager:SetParticleControlEnt(web_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

			Physics:Unit(caster)
			caster:SetPhysicsVelocityMax(600)
			caster:PreventDI()
			caster:SetPhysicsAcceleration(Vector(0,0,-1) * 2000)

			caster:RemoveModifierByName("modifier_spider_invisible")

			local t = 0.0
			Timers:CreateTimer(function (  )
				t = t + 0.03

				if t < 2.5 then
					return 0.03
				else
					TimedEffect("particles/units/heroes/hero_meepo/meepo_poof_dust_ring.vpcf", caster, 4.0)

					caster:RemoveModifierByName("modifier_spider_out")
					ParticleManager:DestroyParticle(web_particle, false)
				end
			end)
		end)
	end

	caster.descended = true
end
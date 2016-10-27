function InitFireBomb( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:AddOnDiedCallback(function ()
		local bomb = ParticleManager:CreateParticle("particles/creeps/ziv_creep_fire_bomb.vpcf",PATTACH_CUSTOMORIGIN,nil)
		ParticleManager:SetParticleControl(bomb,0,caster:GetAbsOrigin())

		StartSoundEvent("Hero_Rattletrap.Rocket_Flare.Travel",caster)

		Timers:CreateTimer(2, function (  )
			EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"Hero_Techies.LandMine.Detonate",caster)

			StopSoundEvent("Hero_Rattletrap.Rocket_Flare.Travel",caster)

			DoToUnitsInRadius( caster, caster:GetAbsOrigin(), 270, target_team, target_type, target_flags, function ( unit )
				Damage:Deal( caster, unit, unit:GetMaxHealth() * (GetSpecial(ability, "damage_percent") / 100), DAMAGE_TYPE_FIRE, true)
			end )
		end)
	end)
end
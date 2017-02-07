function InitIceBomb( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:AddOnDiedCallback(function ()
		local bomb = ParticleManager:CreateParticle("particles/creeps/ziv_creep_ice_bomb.vpcf",PATTACH_CUSTOMORIGIN,nil)
		local pos = caster:GetAbsOrigin()
		pos.z = GetGroundHeight(pos,caster)
		ParticleManager:SetParticleControl(bomb,0,pos)

		StartSoundEvent("Hero_Ancient_Apparition.ColdFeetCast",caster)

		Timers:CreateTimer(2, function (  )
			EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"Ability.FrostNova",caster)
			EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"Hero_Ancient_Apparition.ColdFeetTick",caster)

			StopSoundEvent("Hero_Ancient_Apparition.ColdFeetCast",caster)

			DoToUnitsInRadius( caster, caster:GetAbsOrigin(), 270, target_team, target_type, target_flags, function ( unit )
				Damage:Deal( caster, unit, unit:GetMaxHealth() * (GetSpecial(ability, "damage_percent") / 100), DAMAGE_TYPE_COLD, true)
			end )
		end)
	end)
end
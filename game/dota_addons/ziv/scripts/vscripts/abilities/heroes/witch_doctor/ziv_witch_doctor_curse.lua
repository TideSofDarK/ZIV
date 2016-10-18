function CreateCurseThinker( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local duration = GetSpecial(ability, "duration") + (GRMSC("ziv_witch_doctor_curse_duration", caster) / 100)

	local thinker = ability:ApplyDataDrivenThinker(caster,target,"modifier_witch_doctor_curse_thinker",{duration = duration})

	local particle = ParticleManager:CreateParticle("particles/heroes/witch_doctor/witch_doctor_curse.vpcf",PATTACH_CUSTOMORIGIN,thinker)
	ParticleManager:SetParticleControl(particle,0,target)
	ParticleManager:SetParticleControl(particle,16,Vector(duration, 0, 0))
end

function Curse( keys )
	local caster = keys.caster
	local target = keys.target_points[1] or keys.target:GetAbsOrigin()
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	for k,v in pairs(units) do
		if not v:HasModifier("modifier_witch_doctor_curse_debuff") then
			v:AddNewModifier(caster,ability,"modifier_witch_doctor_curse_debuff",{duration = 0.2})
			v:EmitSound("Hero_Treant.Overgrowth.Target")
		else
			local debuff = v:FindModifierByName("modifier_witch_doctor_curse_debuff")

			debuff:SetDuration(0.2, false)
		end
		ability:ApplyDataDrivenModifier(caster,v,"modifier_witch_doctor_curse_slow",{duration = 0.1})
		v:SetModifierStackCount("modifier_witch_doctor_curse_slow",caster,GetSpecial(ability, "slow") + GRMSC("ziv_witch_doctor_curse_slow", caster))
	end
end
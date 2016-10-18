ziv_witch_doctor_blink = class({})

function ziv_witch_doctor_blink:GetManaCost()
	return 40
end

function ziv_witch_doctor_blink:GetCastRange()
	return 850
end

function ziv_witch_doctor_blink:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end

function ziv_witch_doctor_blink:OnAbilityPhaseStart()
	self.cast_point = GetRunePercentDecrease(0.3, "ziv_witch_doctor_blink_speed", self:GetOwner())

	self:SetOverrideCastPoint(self.cast_point)
	StartAnimation(self:GetOwner(), {duration=self.cast_point, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.3})
	return true
end

function ziv_witch_doctor_blink:OnAbilityPhaseInterrupted()
	EndAnimation(self:GetOwner())
end

function ziv_witch_doctor_blink:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local target = self:GetCursorPosition()

    caster:EmitSound("Hero_WitchDoctor.Maledict_Cast")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf",PATTACH_ABSORIGIN_FOLLOW,nil)
    ParticleManager:SetParticleControl(particle,0,target)
    ParticleManager:SetParticleControl(particle,1,Vector(80,80,80))

	particle = ParticleManager:CreateParticle("particles/heroes/witch_doctor/witch_doctor_blink_fx.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(particle,0,target)

	Timers:CreateTimer(0.2, function ()
		StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.9})
	end)

	Timers:CreateTimer(0.5, function ()
		FindClearSpaceForUnit(caster,target,false)

		local heal = GRMSC("ziv_witch_doctor_blink_heal", caster)
		if heal > 0 then
			caster:Heal((caster:GetMaxHealth() / 100) * heal,ability)
			caster:EmitSound("Hero_Warlock.ShadowWordCastGood")
		end
		
		Timers:CreateTimer(0.1,function (  )
			ParticleManager:CreateParticle("particles/econ/events/nexon_hero_compendium_2014/teleport_end_dust_nexon_hero_cp_2014.vpcf",PATTACH_ABSORIGIN,caster)
		end)
	end)
end
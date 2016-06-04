function SMGSpecial(keys)
	local keys = keys

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local spread = GetModifierCount( caster, "modifier_smg_special_spread" )

	keys.effect = "particles/heroes/sniper/sniper_smg_special_projectile.vpcf"
	keys.projectile_speed = 2300
	keys.duration = 0.1
	keys.rate = 3.0
	keys.base_attack_time = 0.1
	keys.ignore_z = true
	keys.spread = spread * 4
	keys.interruptable = false
	keys.standard_targeting = true
	keys.on_impact = (function ( caster )
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_smg_special_spread",{})
		EmitGunsmoke( keys )
		if spread > 20 then
			local sparks = TimedEffect("particles/heroes/sniper/sniper_smg_special_sparks.vpcf", caster, 1.0, 3)
			ParticleManager:SetParticleControlEnt(sparks, 3, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
		end
	end)

	SimulateRangeAttack(keys)
end

function EndSpreadStack( keys )
	local caster = keys.caster
	local ability = keys.ability

	EmitGunsmoke( keys )
end

function EmitGunsmoke( keys )
	local caster = keys.caster
	local ability = keys.ability

	local particle = ParticleManager:CreateParticle("particles/heroes/sniper/sniper_smg_special_gunsmoke.vpcf",PATTACH_CUSTOMORIGIN,caster)
	ParticleManager:SetParticleControl(particle,0,caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))

	local spread = GetModifierCount( caster, "modifier_smg_special_spread" )
	ParticleManager:SetParticleControl(particle,1,Vector(spread * 2,0,0))

	ParticleManager:SetParticleControlForward(particle,0,Vector(0,1,0))
end
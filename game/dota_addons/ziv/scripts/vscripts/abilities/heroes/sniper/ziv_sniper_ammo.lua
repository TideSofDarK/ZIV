ziv_sniper_ammo = class({})
LinkLuaModifier("modifier_ammo_poison_debuff", "abilities/heroes/sniper/modifier_ammo_poison_debuff.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function ziv_sniper_ammo:ApplyAmmo(target)
		local hero = self:GetOwner()

		local modifier

		if hero:HasModifier("ziv_sniper_ammo_poison") then
			modifier = "modifier_ammo_poison_debuff"
		elseif hero:HasModifier("ziv_sniper_ammo_frag") then
			DoToUnitsInRadius(hero, target:GetAbsOrigin(), 128, nil, nil, nil, function (creep)
				if creep ~= target then
					Damage:Deal( hero, creep, GetRuneDamage(hero, 1.0, "ziv_sniper_ammo_frag"), DAMAGE_TYPE_PHYSICAL, true )
					TimedEffect("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack_explosion.vpcf", creep, 1.0, 3)
				end
			end)
		end

		if modifier then
			target:AddNewModifier(hero,self,modifier,{})
		end
	end

	function ziv_sniper_ammo:OnCreated( keys )

	end
end
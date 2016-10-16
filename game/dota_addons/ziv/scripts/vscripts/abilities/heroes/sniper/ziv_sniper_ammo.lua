ziv_sniper_ammo = class({})
LinkLuaModifier("modifier_ammo_poison_debuff", "abilities/heroes/sniper/modifier_ammo_poison_debuff.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function ziv_sniper_ammo:ApplyAmmo(target)
		local hero = self:GetOwner()

		local modifier

		if hero:HasModifier("ziv_sniper_ammo_poison") then
			modifier = "modifier_ammo_poison_debuff"
		elseif hero:HasModifier("ziv_sniper_ammo_ice") then
			modifier = "modifier_ammo_ice_debuff"
		end

		if modifier then
			target:AddNewModifier(hero,self,modifier,{})
		end
	end

	function ziv_sniper_ammo:OnCreated( keys )

	end
end
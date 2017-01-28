ziv_dark_goddess_concentration = class({})

function ziv_dark_goddess_concentration:OnUpgrade()
	local caster = self:GetCaster()

	local evasion = GetSpecial(self, "evasion")
	local pierce = GetSpecial(self, "pierce")

	Damage:Modify(caster, Damage.EVASION, evasion)
	Damage:Modify(caster, Damage.PIERCE, pierce)

	caster:AddOnRuneModifierAppliedCallback(function ( modifier_name, value )
		if modifier_name == "ziv_dark_goddess_concentration_pierce" then
			Damage:Modify(caster, Damage.PIERCE, value)
		end
		if modifier_name == "ziv_dark_goddess_concentration_evasion" then
			Damage:Modify(caster, Damage.EVASION, value)
		end
	end)
	caster:AddOnRuneModifierRemovedCallback(function ( modifier_name, value )
		if modifier_name == "ziv_dark_goddess_concentration_pierce" then
			Damage:Modify(caster, Damage.PIERCE, -value)
		end
		if modifier_name == "ziv_dark_goddess_concentration_evasion" then
			Damage:Modify(caster, Damage.EVASION, -value)
		end
	end)
end

function ziv_dark_goddess_concentration:GetIntrinsicModifierName()
  return "ziv_dark_goddess_concentration_movespeed"
end

ziv_dark_goddess_concentration_movespeed = class({})

if IsServer() then
	function ziv_dark_goddess_concentration_movespeed:OnCreated()
		self.bonus = GetSpecial(self:GetCaster():FindAbilityByName("ziv_dark_goddess_concentration"), "movespeed")
	end

	function ziv_dark_goddess_concentration_movespeed:DeclareFunctions()
	  local funcs = {
	    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	  }

	  return funcs
	end

	function ziv_dark_goddess_concentration_movespeed:GetModifierMoveSpeedBonus_Constant()
		return self.bonus + GRMSC("ziv_dark_goddess_concentration_ms", self:GetCaster())
	end
end

LinkLuaModifier("ziv_dark_goddess_concentration_movespeed", "abilities/heroes/dark_goddess/ziv_dark_goddess_concentration.lua", LUA_MODIFIER_MOTION_NONE)
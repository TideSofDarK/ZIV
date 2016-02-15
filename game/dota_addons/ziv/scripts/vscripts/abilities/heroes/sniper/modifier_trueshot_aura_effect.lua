modifier_trueshot_aura_effect = class({})

function modifier_trueshot_aura_effect:IsHidden()
    return true
end

function modifier_trueshot_aura_effect:IsBuff()
    return true
end

function modifier_trueshot_aura_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }

    return funcs
end

function modifier_trueshot_aura_effect:GetModifierPreAttack_BonusDamage(params)
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    if not caster then
        return 0
    end

    if IsServer() and parent:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
		local damage = math.ceil(((parent:GetBaseDamageMin() + parent:GetBaseDamageMax()) / 200.0) * ability:GetLevelSpecialValueFor("damage_bonus", ability:GetLevel()-1))
		self:SetStackCount(damage)

		return damage
    else
    	return self:GetStackCount()
    end
end
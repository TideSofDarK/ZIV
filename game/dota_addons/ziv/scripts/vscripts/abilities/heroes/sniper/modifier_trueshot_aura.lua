modifier_trueshot_aura = class({})

function modifier_trueshot_aura:IsHidden()
    return true
end

function modifier_trueshot_aura:IsPassive()
    return true
end

function modifier_trueshot_aura:IsAura()
    return true
end

function modifier_trueshot_aura:GetAuraRadius()
    return 1000
end

function modifier_trueshot_aura:GetAuraDuration()
    return 0.1
end

function modifier_trueshot_aura:GetModifierAura()
    return "modifier_trueshot_aura_effect"
end

function modifier_trueshot_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_trueshot_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end
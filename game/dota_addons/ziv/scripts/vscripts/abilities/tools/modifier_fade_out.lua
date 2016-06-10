modifier_fade_out = class({})

function modifier_fade_out:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = self:GetElapsedTime() >= 3
    }

    return state
end

function modifier_fade_out:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

function modifier_fade_out:GetModifierInvisibilityLevel(params)
    return math.min(self:GetElapsedTime() / 3, 3)
end

function modifier_fade_out:IsHidden()
    return true
end
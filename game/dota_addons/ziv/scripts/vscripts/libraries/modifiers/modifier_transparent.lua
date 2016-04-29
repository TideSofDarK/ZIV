modifier_transparent = class({})

function modifier_transparent:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = false
    }

    return state
end

function modifier_transparent:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

function modifier_transparent:GetModifierInvisibilityLevel(params)
    return 0.3
end

function modifier_transparent:IsHidden()
    return true
end
modifier_hide_health_bar = class({})

function modifier_hide_health_bar:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function modifier_hide_health_bar:IsHidden()
    return true
end
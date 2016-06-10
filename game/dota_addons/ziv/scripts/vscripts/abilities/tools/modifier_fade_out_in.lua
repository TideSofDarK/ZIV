modifier_fade_out_in = class({})

function modifier_fade_out_in:OnCreated(args)
    self:StartIntervalThink(0.03)
    self.time = 0.0
    self.duration = args.duration
end

function modifier_fade_out_in:OnIntervalThink()
    self.time = self.time + 0.03
end

function modifier_fade_out_in:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = false
    }

    return state
end

function modifier_fade_out_in:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

function modifier_fade_out_in:GetModifierInvisibilityLevel(params)
    return math.sin(self:GetElapsedTime() / self:GetDuration() * math.pi * 2) / 2 + 1 
end

function modifier_fade_out_in:IsHidden()
    return true
end
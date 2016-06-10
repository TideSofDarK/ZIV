modifier_smooth_floating = class({})

function modifier_smooth_floating:OnCreated()
    self:StartIntervalThink(0.03)
    self.time = 0.0

    if IsServer() then
        self:GetParent():SetAngles(0, math.random(0, 360), 0)
    end
end

function modifier_smooth_floating:OnIntervalThink()
    self.time = self.time + 0.03

    if IsServer() then
        self:GetParent():SetAngles(0, self:GetParent():GetAngles().y + 1.2, 0)
    end
end

function modifier_smooth_floating:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        caster.reserved_floating_z = nil
    end
end

function modifier_smooth_floating:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVISIBLE] = false
    }

    return state
end

function modifier_smooth_floating:IsStunDebuff()
    return true
end

function modifier_smooth_floating:GetVisualZDelta(params)
    return (math.abs(math.sin(self.time * 1.35)) * 50) + 80
end

function modifier_smooth_floating:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_VISUAL_Z_DELTA
    }

    return funcs
end

function modifier_smooth_floating:GetOverrideAnimation(params)
    return ACT_DOTA_FLAIL
end

function modifier_smooth_floating:IsHidden()
    return true
end
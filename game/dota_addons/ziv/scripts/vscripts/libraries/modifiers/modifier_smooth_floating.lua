modifier_smooth_floating = class({})

if IsServer() then
    function modifier_smooth_floating:OnCreated()
        self:StartIntervalThink(.066)
    end

    function modifier_smooth_floating:OnIntervalThink()
        local caster = self:GetParent()

        local pos = caster:GetAbsOrigin()

        if not caster.reserved_floating_z then
            caster.reserved_floating_z = pos.z
        end
        pos.z = caster.reserved_floating_z + (math.abs(math.sin(ZIV.TRUE_TIME * 1.35)) * 50) + 80

        caster:SetAngles(0, caster:GetAngles().y + 7, 0)

        caster:SetAbsOrigin(pos)
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

function modifier_smooth_floating:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function modifier_smooth_floating:GetOverrideAnimation(params)
    return ACT_DOTA_FLAIL
end

function modifier_smooth_floating:IsHidden()
    return true
end
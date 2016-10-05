modifier_hide = class({})

function modifier_hide:IsDebuff()
    return true
end

function modifier_hide:OnCreated()
    if IsServer() then
        self:GetCaster():AddEffects(EF_NODRAW)
    end
end

function modifier_hide:OnDestroy()
    if IsServer() then
        self:GetCaster():RemoveEffects(EF_NODRAW)
    end
end
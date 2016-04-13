modifier_disable_auto_attack = class({})

function modifier_disable_auto_attack:OnCreated( kv )
    if IsServer() then
        self:GetCaster():SetIdleAcquire(false)
        self:GetCaster():SetAcquisitionRange(0) 
    end
end

function modifier_disable_auto_attack:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
        MODIFIER_EVENT_ON_ATTACK
    }

    return funcs
end

function modifier_disable_auto_attack:OnAttack( params )
    if not IsServer() then return end
    if params.attacker ~= self:GetParent() then return end

    self:GetCaster():Stop()
end

function modifier_disable_auto_attack:GetDisableAutoAttack(params)
    return 1
end

function modifier_disable_auto_attack:IsHidden()
    return true
end
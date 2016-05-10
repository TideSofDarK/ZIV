modifier_custom_attack = class({})

function modifier_custom_attack:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER
    }

    return funcs
end

function modifier_custom_attack:OnOrder( params )
    if IsServer() then 
        self:GetCaster():RemoveModifierByName("modifier_custom_attack")
        EndAnimation(self:GetCaster())
    end
end

function modifier_custom_attack:IsHidden()
    return true
end
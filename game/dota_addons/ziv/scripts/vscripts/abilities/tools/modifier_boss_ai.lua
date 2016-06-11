modifier_boss_ai = class({})

function modifier_boss_ai:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_boss_ai:OnTakeDamage( params )
    if IsServer() then 
        if params.unit == self:GetParent() then
            
        end
    end
end

function modifier_boss_ai:IsHidden()
    return true
end
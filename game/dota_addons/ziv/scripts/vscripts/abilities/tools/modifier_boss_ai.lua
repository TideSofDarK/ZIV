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
          
          local attacker
          if not params.attacker:IsHero() then
            attacker = params.attacker:GetOwner():entindex()
          else
            attacker = params.attacker:entindex()
          end
          
          params.unit.aggroTable[attacker] = (params.unit.aggroTable[attacker] or 0) + params.damage
        end
    end
end

function modifier_boss_ai:IsHidden()
    return true
end
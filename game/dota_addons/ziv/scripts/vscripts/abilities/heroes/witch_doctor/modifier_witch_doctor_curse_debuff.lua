modifier_witch_doctor_curse_debuff = class({})

if IsServer() then
    function modifier_witch_doctor_curse_debuff:OnCreated(keys)
        self.tick = 0.03
        self:StartIntervalThink(self.tick)
    end

    function modifier_witch_doctor_curse_debuff:OnIntervalThink(keys)
        local caster = self:GetCaster()
        local target = self:GetParent()

        Damage:Deal( caster, target, GetRuneDamage(caster, GetSpecial(self:GetAbility(), "damage_amp"), "ziv_witch_doctor_curse_damage") * self.tick, DAMAGE_TYPE_DARK, true, true )

        return self.tick
    end

    function modifier_witch_doctor_curse_debuff:IsHidden()
        return true
    end

    function modifier_witch_doctor_curse_debuff:DeclareFunctions()
        local funcs = {
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        }
     
        return funcs
    end

    function modifier_witch_doctor_curse_debuff:GetModifierIncomingDamage_Percentage(params)
        return GetSpecial(self:GetAbility(), "incoming_damage_bonus")
    end
end

function modifier_witch_doctor_curse_debuff:GetEffectName()
    return "particles/heroes/witch_doctor/witch_doctor_curse_debuff.vpcf"
end

function modifier_witch_doctor_curse_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_witch_doctor_curse_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_stickynapalm.vpcf"
end
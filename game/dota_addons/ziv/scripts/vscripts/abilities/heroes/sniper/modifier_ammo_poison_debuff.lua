modifier_ammo_poison_debuff = class({})

if IsServer() then
    function modifier_ammo_poison_debuff:OnOrder( params )
        if IsServer() then 
            self:GetCaster():RemoveModifierByName("modifier_custom_attack")
            EndAnimation(self:GetCaster())
        end
    end

    function modifier_ammo_poison_debuff:OnCreated(keys)
        self:SetDuration(2.0, false)
        self.tick = 0.03
        self:StartIntervalThink(self.tick)
    end

    function modifier_ammo_poison_debuff:OnIntervalThink(keys)
        local caster = self:GetCaster()
        local target = self:GetParent()

        local damage_amp = GRMSC("ziv_sniper_ammo_poison", caster)

        if not damage_amp or damage_amp == 0 then
            self:Destroy()
            return
        end

        DealDamage( caster, target, GetRuneDamage(caster, 1.0, "ziv_sniper_ammo_poison") * self.tick, DAMAGE_TYPE_DARK, true )

        return self.tick
    end

    function modifier_ammo_poison_debuff:IsHidden()
        return true
    end
end

function modifier_ammo_poison_debuff:GetEffectName()
    return "particles/heroes/sniper/sniper_ammo_poison_debuff.vpcf"
end

function modifier_ammo_poison_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
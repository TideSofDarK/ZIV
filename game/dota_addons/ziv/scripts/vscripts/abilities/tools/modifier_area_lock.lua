modifier_area_lock = class({})

function modifier_area_lock:OnCreated(args)
    if IsServer() then
        self:StartIntervalThink(0.03)
    end
end

function modifier_area_lock:OnIntervalThink()
    if IsServer() then
        if self.area then
            local caster = self:GetParent()
            if caster:IsInsidePolygon(self.area) then
                self.old_pos = caster:GetAbsOrigin()
            else
                FindClearSpaceForUnit(caster,self.old_pos,true)
            end
        end
    end
end

function modifier_area_lock:OnDestroy()
    if IsServer() then
        
    end
end

function modifier_area_lock:IsHidden()
    return true
end
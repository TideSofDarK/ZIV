modifier_hide = class({})

function modifier_hide:IsDebuff()
    return true
end

function modifier_hide:CheckState() 
    local state = {
    	[MODIFIER_STATE_UNSELECTABLE] = true
    }

    return state
end

function modifier_hide:OnCreated()
    if IsServer() then
		self:GetCaster():AddEffects(EF_NODRAW)

		self.temp_model = self:GetCaster():GetModelName()
		self:GetCaster():SetModel("models/development/invisiblebox.vmdl")
		self:GetCaster():SetOriginalModel("models/development/invisiblebox.vmdl")
    end
end

function modifier_hide:OnDestroy()
    if IsServer() then
    	self:GetCaster():RemoveEffects(EF_NODRAW)
		self:GetCaster():SetModel(self.temp_model)
		self:GetCaster():SetOriginalModel(self.temp_model)
    end
end
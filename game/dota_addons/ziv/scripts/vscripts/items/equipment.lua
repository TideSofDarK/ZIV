if not Equipment then
    Equipment = class({})
end

function Equipment:Init()

end

function Equipment:Unequip( unit, item )
	local itemName = item:GetName()

	for id,gem_table in pairs(item.fortify_modifiers) do
		for k,v in pairs(gem_table) do
			if unit:HasModifier(k) then
				if unit:HasModifier(k) == false then
					unit:FindAbilityByName("ziv_passive_hero"):ApplyDataDrivenModifier(unit,unit,k,{})
				end

				local new_count = unit:GetModifierStackCount(k, unit) - v
				unit:SetModifierStackCount(k, unit, new_count)
				if new_count <= 0 then
					unit:RemoveModifierByName(k)
				end
			end
		end
	end
end

function Equipment:Equip( unit, item )
	local itemName = item:GetName()

	for i=1,2 do
		local custom_skill = ZIV.ItemKVs[itemName]["CustomSkill"..tostring(i)]
		if custom_skill then
			for k,v in pairs(custom_skill) do
				unit:RemoveAbility(k)
				unit:AddAbility(v):UpgradeAbility(true)
			end
		end
	end

	if item.fortify_modifiers and unit:HasAbility("ziv_passive_hero") then
		local fortify_modifiers_ability = unit:FindAbilityByName("ziv_passive_hero")

		for id,gem_table in pairs(item.fortify_modifiers) do
			for k,v in pairs(gem_table) do
				if k ~= "gem" then
					if unit:HasModifier(k) then
						unit:SetModifierStackCount(k, unit, v + unit:GetModifierStackCount(k, unit))
					else
						fortify_modifiers_ability:ApplyDataDrivenModifier(unit, unit, k, {})
						unit:SetModifierStackCount(k, unit, v)
					end
				end
			end
		end
	end
end
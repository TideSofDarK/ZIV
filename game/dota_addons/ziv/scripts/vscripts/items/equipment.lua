if not Equipment then
    Equipment = class({})
end

function Equipment:Init()

end

function Equipment:Unequip( unit, item )
	local itemName = item:GetName()

	local RemoveModifiers = (function (modifiers, unit)
		if modifiers then
			for id,gem_table in pairs(modifiers) do
				for k,v in pairs(gem_table) do
					if Damage[k] then -- Custom resistances
						Damage:Modify(unit, Damage[k], -v)
					else
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

					if unit._OnRuneModifierRemovedCallbacks then
				    	for _,callback in pairs(unit._OnRuneModifierRemovedCallbacks) do
				    		callback(k, v)
				    	end
				    end
				end
			end
		end
	end)

	RemoveModifiers(item.built_in_modifiers, unit)
	RemoveModifiers(item.fortify_modifiers, unit)
end

function Equipment:Equip( unit, item )
	local item_name = item:GetName()

	for i=1,2 do
		local custom_skill = ZIV.ItemKVs[item_name]["CustomSkill"..tostring(i)]
		if custom_skill then
			for k,v in pairs(custom_skill) do
				unit:RemoveAbility(unit:GetAbilityByIndex(tonumber(k)):GetName())
				unit:AddAbility(v):UpgradeAbility(true)
			end
		end
	end

	local ApplyModifiers = (function (modifiers, unit)
		if modifiers and unit:HasAbility("ziv_passive_hero") then
			local fortify_modifiers_ability = unit:FindAbilityByName("ziv_passive_hero")

			for id,gem_table in pairs(modifiers) do
				for k,v in pairs(gem_table) do
					if k ~= "gem" then
						if Damage[k] then -- Custom resistances
							Damage:Modify(unit, Damage[k], v)
						else
							if unit:HasModifier(k) then
								unit:SetModifierStackCount(k, unit, v + unit:GetModifierStackCount(k, unit))
							else
								fortify_modifiers_ability:ApplyDataDrivenModifier(unit, unit, k, {})
								unit:SetModifierStackCount(k, unit, v)
							end
						end

						if unit._OnRuneModifierAppliedCallbacks then
					    	for _,callback in pairs(unit._OnRuneModifierAppliedCallbacks) do
					    		callback(k, v)
					    	end
					    end
					end
				end
			end
		end
	end)

	ApplyModifiers(item.built_in_modifiers, unit)
	ApplyModifiers(item.fortify_modifiers, unit)
end

function Equipment:CreateInventory( hero )
	return Containers:CreateContainer({
		layout 			= {5,5,5,5,5},
		skins 			= {"Inventory"},
		headerText 		= "Bag",
		pids 			= {hero:GetPlayerOwnerID()},
		entity 			= hero,
		closeOnOrder 	= false,
		position 		= "0px 0px 0px",
		OnDragWorld 	= true,
		-- OnDragFrom 		= (function (playerID, container, unit, item, fromSlot, toContainer, toSlot)
		-- 	local canChange = Containers.itemKV[item:GetAbilityName()].ItemCanChangeContainer
		-- 	if toContainer._OnDragTo == false or canChange == 0 then return end

		-- 	if unit.equipment.id == toContainer.id then
		-- 		print("dcis1")
		-- 		local toSlotName = KeyValues:Split(ZIV.HeroesKVs[unit:GetUnitName()]["EquipmentSlots"], ';')[toSlot]

		-- 		if ZIV.ItemKVs[item:GetName()]["Slot"] and string.match(toSlotName, ZIV.ItemKVs[item:GetName()]["Slot"]) then
		-- 			Equipment:Equip( hero, item )
		-- 		end
		-- 	end

		-- 	local fun = nil

		-- 	if type(toContainer._OnDragTo) == "function" then
		--   		fun = toContainer._OnDragTo
		-- 	end

		-- 	if fun then
		--   		fun(playerID, container, unit, item, fromSlot, toContainer, toSlot)
		-- 	else
		--   		Containers:OnDragTo(playerID, container, unit, item, fromSlot, toContainer, toSlot)
		-- 	end
		-- end)
		OnDragTo = (function (playerID, container, unit, item, fromSlot, toContainer, toSlot) 
			local item2 = toContainer:GetItemInSlot(toSlot)
			local addItem = nil
			if item2 and IsValidEntity(item2) and (item2:GetAbilityName() ~= item:GetAbilityName() or not item2:IsStackable() or not item:IsStackable()) then
				if Containers.itemKV[item2:GetAbilityName()].ItemCanChangeContainer == 0 then
					return false
				end
				toContainer:RemoveItem(item2)
				addItem = item2

				if unit.equipment.id == container.id then
					local toSlotName = KeyValues:Split(ZIV.HeroesKVs[unit:GetUnitName()]["EquipmentSlots"], ';')[fromSlot]

					if ZIV.ItemKVs[addItem:GetName()]["Slot"] and string.match(toSlotName, ZIV.ItemKVs[addItem:GetName()]["Slot"]) then
						Equipment:Equip( unit, addItem )
					end
				end
			end

			if toContainer:AddItem(item, toSlot) then
				container:ClearSlot(fromSlot)
				if addItem then
					if container:AddItem(addItem, fromSlot) then
						return true
					else
						toContainer:RemoveItem(item)
						toContainer:AddItem(item2, toSlot, nil, true)
						container:AddItem(item, fromSlot, nil, true)
						return false
					end
				end
				return true
			elseif addItem then
				toContainer:AddItem(item2, toSlot, nil, true)
			end

			return false 
		end)
	})
end

function Equipment:CreateContainer( hero )
	return Containers:CreateContainer({
		layout        = {6},
		skins         = {"Equipment"},
		position      = "0px 0px 0px",
		pids          = {hero:GetPlayerOwnerID()},
		entity        = hero,
		closeOnOrder  = false,
		OnDragWorld   = false,
		OnDragTo = (function (playerID, container, unit, item, fromSlot, toContainer, toSlot) 
			-- Containers:print('Containers:OnDragTo', playerID, container, unit, item, fromSlot, toContainer, toSlot)

			local toSlotName = KeyValues:Split(ZIV.HeroesKVs[unit:GetUnitName()]["EquipmentSlots"], ';')[toSlot]

			if ZIV.ItemKVs[item:GetName()]["Slot"] and string.match(toSlotName, ZIV.ItemKVs[item:GetName()]["Slot"]) then
				Equipment:Equip( unit, item )
			else
				return false
			end

			local item2 = toContainer:GetItemInSlot(toSlot)
			local addItem = nil
			if item2 and IsValidEntity(item2) and (item2:GetAbilityName() ~= item:GetAbilityName() or not item2:IsStackable() or not item:IsStackable()) then
				if Containers.itemKV[item2:GetAbilityName()].ItemCanChangeContainer == 0 then
					return false
				end
				toContainer:RemoveItem(item2)
				addItem = item2

				Equipment:Unequip( unit, item2 )
			end

			if toContainer:AddItem(item, toSlot) then
				container:ClearSlot(fromSlot)
				if addItem then
					if container:AddItem(addItem, fromSlot) then
						return true
					else
						toContainer:RemoveItem(item)
						toContainer:AddItem(item2, toSlot, nil, true)
						container:AddItem(item, fromSlot, nil, true)
						return false
					end
				end
				return true
			elseif addItem then
				toContainer:AddItem(item2, toSlot, nil, true)
			end

			return false 
		end),
		OnDragWithin = (function(playerID, container, unit, item, fromSlot, toSlot)
			-- Containers:print('Containers:OnDragWithin', playerID, container, unit, item, fromSlot, toSlot)

			local toSlotName = KeyValues:Split(ZIV.HeroesKVs[unit:GetUnitName()]["EquipmentSlots"], ';')[toSlot]

			if ZIV.ItemKVs[item:GetName()]["Slot"] and string.match(toSlotName, ZIV.ItemKVs[item:GetName()]["Slot"]) then
				container:SwapSlots(fromSlot, toSlot, true)
			end
		end),
		OnDragFrom = (function (playerID, container, unit, item, fromSlot, toContainer, toSlot) 
			-- Containers:print('Containers:OnDragFrom', playerID, container, unit, item, fromSlot, toContainer, toSlot)

			local canChange = Containers.itemKV[item:GetAbilityName()].ItemCanChangeContainer
			if toContainer._OnDragTo == false or canChange == 0 then return end

			Equipment:Unequip( unit, item )

			local fun = nil

			if type(toContainer._OnDragTo) == "function" then
		  		fun = toContainer._OnDragTo
			end

			if fun then
		  		fun(playerID, container, unit, item, fromSlot, toContainer, toSlot)
			else
		  		Containers:OnDragTo(playerID, container, unit, item, fromSlot, toContainer, toSlot)
			end
		end)
    })
end
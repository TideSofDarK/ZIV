if not Items then
    Items = class({})
end

Items.ITEM_GC_TIME = 20

function Items:Init()
	PlayerTables:CreateTable("items", {}, true)

	Items:Update()
end

function Items:Update()
	Timers:CreateTimer(function()
		local items = PlayerTables:GetAllTableValues("items")
		local updated_items = {}

		for k,v in pairs(items) do
			local item = EntIndexToHScript(k)

			if item and not item:IsNull() then
				if item.fortify_modifiers then
					local fortify_modifiers = {} 
					for k,v in pairs(item.fortify_modifiers) do table.insert(fortify_modifiers, v) end	
					v.fortify_modifiers = fortify_modifiers
				end

				if item.built_in_modifiers then
					local built_in_modifiers = {} 
					for k,v in pairs(item.built_in_modifiers) do table.insert(built_in_modifiers, v) end	
					v.built_in_modifiers = built_in_modifiers
				end

				v.rarity = item.rarity or 1

				updated_items[k] = v
			else
				PlayerTables:SetTableValue("items", k, {})
			end
		end

		PlayerTables:SetTableValues("items", updated_items)

		return 0.03
	end)
end

function Items:Create(item_name, owner)
	local item = CreateItem(item_name, owner, owner)

	PlayerTables:SetTableValue("items", item:entindex(), {})

	return item
end

function Items:CreateItemPanel( item_container, gc )
	item_container.worldPanel = WorldPanels:CreateWorldPanelForAll({
		layout = "file://{resources}/layout/custom_game/worldpanels/item.xml",
		entity = item_container:GetEntityIndex(),
		data = {name = item_container:GetContainedItem():GetName(), item_entity = item_container:GetContainedItem():GetEntityIndex() },
		entityHeight = 150,
    })

	if gc then
	    Timers:CreateTimer(Items.ITEM_GC_TIME, function (  )
	    	if item_container then
		    	UTIL_Remove(item_container:GetContainedItem())
		    	UTIL_Remove(item_container)
	    	end
	    end)
	end
end
if not Items then
    Items = class({})
end

Items.ITEM_GC_TIME = 30

function Items:Init()
	PlayerTables:CreateTable("items", {}, true)
end

function Items:UpdateItem(item)
	local fortify_modifiers = {}
	local built_in_modifiers = {}

	if item.fortify_modifiers then
		for k,v in pairs(item.fortify_modifiers) do
			local t = {}
			for k2,v2 in pairs(v) do
				t[k2] = v2
			end
			table.insert(fortify_modifiers, t)
		end
	end

	if item.built_in_modifiers then
		for k,v in pairs(item.built_in_modifiers) do
			local t = {}
			for k2,v2 in pairs(v) do
				t[k2] = v2
			end
			table.insert(built_in_modifiers, t)
		end
	end

	PlayerTables:SetTableValue("items", item:entindex(), { caption = item.caption, fortify_modifiers = fortify_modifiers, built_in_modifiers = built_in_modifiers, rarity = item.rarity or 1, sockets = item.sockets or 0})

	if item:GetOwnerEntity() then
		if item:GetOwnerEntity().equipment then
			if item:GetOwnerEntity().equipment:ContainsItem(item) then
				Equipment:Unequip( item:GetOwnerEntity(), item )
				Equipment:Equip( item:GetOwnerEntity(), item )
			end
		end
	end
end

function Items:Create(item_name, owner)
	local item = CreateItem(item_name, owner, owner)

	Items:UpdateItem(item)

	return item
end

function Items:CreateItemPanel( item_container, gc )
	item_container.worldPanel = WorldPanels:CreateWorldPanelForAll({
		layout = "item",
		entity = item_container:GetEntityIndex(),
		data = {name = item_container:GetContainedItem():GetName(), item_entity = item_container:GetContainedItem():GetEntityIndex() },
		entityHeight = 150,
    })

	if gc then
	    Timers:CreateTimer(Items.ITEM_GC_TIME, function (  )
	    	if item_container and not item_container:IsNull() then
		    	UTIL_Remove(item_container:GetContainedItem())
		    	UTIL_Remove(item_container)
	    	end
	    end)
	end
end
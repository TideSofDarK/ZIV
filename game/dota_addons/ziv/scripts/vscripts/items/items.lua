if not Items then
    Items = class({})
end

Items.ITEM_GC_TIME = 30

function Items:Init()
	PlayerTables:CreateTable("items", {}, true)
end

function Items:UpdateItem(item)
	PlayerTables:SetTableValue("items", item:entindex(), { fortify_modifiers = item.fortify_modifiers, built_in_modifiers = item.built_in_modifiers, rarity = item.rarity or 1, sockets = item.sockets or 0})
end

function Items:Create(item_name, owner)
	local item = CreateItem(item_name, owner, owner)

	Items:UpdateItem(item)

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
	    	if item_container and not item_container:IsNull() then
		    	UTIL_Remove(item_container:GetContainedItem())
		    	UTIL_Remove(item_container)
	    	end
	    end)
	end
end
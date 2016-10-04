if not Items then
    Items = class({})
end

function Items:Init()
	PlayerTables:CreateTable("items", {}, true)

	Items:Update()
end

function Items:Update()
	Timers:CreateTimer(function()
		local items = PlayerTables:GetAllTableValues("items")

		for k,v in pairs(items) do
			local item = EntIndexToHScript(k)
			v.fortify_modifiers = item.fortify_modifiers
			v.built_in_modifiers = item.fortify_modifiers
			v.rarity = item.rarity or 0
		end

		PlayerTables:SetTableValues("items", items)

		return 0.03
	end)
end

function Items:Create(item_name, owner)
	local item = CreateItem(item_name, owner, owner)

	PlayerTables:SetTableValue("items", item:entindex(), {})

	return item
end
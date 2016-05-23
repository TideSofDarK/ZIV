if Crafting == nil then
    _G.Crafting = class({})
end

function Crafting:UsePart( item, count, pID )
	item:SetCurrentCharges(item:GetCurrentCharges() - count)

	if item:GetCurrentCharges() == 0 then
		ZIV.INVENTORY[pID]:RemoveItem(item)
	end
end

function Crafting:CraftingRequest( keys )
	local item_name = string.gsub(keys["item"], "Recipe_", "")
	local pID = tonumber(keys["pID"])

	local recipe = ZIV.RecipesKVs[item_name]["Recipe"]

	local pass = true

	for k,v in pairs(recipe) do
		if ZIV.INVENTORY[pID]:CheckForItem(k, v) == false then
			pass = false
			return false
		end
	end

	for k,v in pairs(recipe) do
		local item = ZIV.INVENTORY[pID]:GetItemsByName(k)[1]
		Crafting:UsePart( item, v, pID )
	end

	local item = CreateItem(item_name, PlayerResource:GetPlayer(pID):GetAssignedHero(), PlayerResource:GetPlayer(pID):GetAssignedHero())
  	ZIV.INVENTORY[pID]:AddItem(item)

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pID), "ziv_craft_result", { } )
end
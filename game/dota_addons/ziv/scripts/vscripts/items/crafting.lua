if Crafting == nil then
    _G.Crafting = class({})
end

function Crafting:Init()
	CustomGameEventManager:RegisterListener("ziv_recycle_request", Dynamic_Wrap(Crafting, 'Recycle'))
end

function Crafting:CreateRecycleContainer( hero )
	hero.recycle = Containers:CreateContainer({
		layout 			= {4,4},
		skins 			= {"Recycle"},
		headerText 		= "",
		pids 			= {hero:GetPlayerOwnerID()},
		entity 			= hero,
		closeOnOrder 	= false,
		position 		= "0% 0%",
		OnDragWorld 	= true
		--,
		-- OnDragTo = (function (playerID, container, unit, item, fromSlot, toContainer, toSlot) 
		-- 	return false 
		-- end)
	})
end

function Crafting:Recycle(args)
	local hero = Characters.current_session_characters[args.PlayerID]

	local container = hero.recycle

	local items = container:GetAllItems()
	for _,item in ipairs(items) do
		container:RemoveItem(item)
		Containers:AddItemToUnit(unit,item)
	end
end

function Crafting:UsePart( item, count, pID )
	item:SetCurrentCharges(item:GetCurrentCharges() - count)

	if item:GetCurrentCharges() == 0 then
		Characters:GetInventory(pID):RemoveItem(item)
	end
end

function Crafting:CraftingRequest( keys )
	local item_name = string.gsub(keys["item"], "Recipe_", "")
	local pID = tonumber(keys["pID"])

	local recipe = ZIV.RecipesKVs[item_name]["Recipe"]

	local pass = true

	for k,v in pairs(recipe) do
		if Characters:GetInventory(pID):CheckForItem(k, v) == false then
			pass = false
			return false
		end
	end

	for k,v in pairs(recipe) do
		local item = Characters:GetInventory(pID):GetItemsByName(k)[1]
		Crafting:UsePart( item, v, pID )
	end

	local item = Items:Create(item_name, PlayerResource:GetPlayer(pID):GetAssignedHero())
  	Characters:GetInventory(pID):AddItem(item)

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pID), "ziv_craft_result", { } )
end

function Crafting:GenerateRecipes()
	local slots = {}
	local recipes = {}
	for k,v in pairs(LoadKeyValues('scripts/kv/Equipment.kv')) do
		if string.match(v, ";") then
			for k1,v1 in pairs(KeyValues:Split(v, ";")) do
				if not string.match(v1, "2") then
					table.insert(slots, v1)
				end
			end
		else
			table.insert(slots, v)
		end
	end
	for _,slot in pairs(slots) do
		for i=2,4 do
			local materials = {}
			for k,v in pairs(ZIV.ItemKVs) do
				if v.Craft and v.Slot and v.Slot == slot then
					materials[v.Craft] = materials[v.Craft] or {}
					materials[v.Craft]["PossibleResults"] = materials[v.Craft]["PossibleResults"] or {}
					materials[v.Craft]["Parts"] = materials[v.Craft]["Parts"] or {}

					materials[v.Craft]["PossibleResults"][k] = "1"
					materials[v.Craft]["Parts"]["item_craft_"..v.Craft] = tostring(i * 2)
					materials[v.Craft]["Parts"]["item_craft_parts"] = tostring(i)

					if v.Craft == "iron" and i > 2 then
						materials[v.Craft]["Parts"]["item_craft_gold"] = tostring(i - 2)
					end

					if slot == "ring" then
						materials[v.Craft]["Parts"]["item_craft_gold"] = tostring(i - 1)
					end
				end
			end
			for k,v in pairs(materials) do
				recipes["random_"..k.."_"..slot.."_"..tostring(i)] = v
			end
		end
	end
	PrintKV(recipes)
end
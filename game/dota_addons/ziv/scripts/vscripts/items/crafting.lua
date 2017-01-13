if Crafting == nil then
    _G.Crafting = class({})
end

Crafting.RECYCLE_TIME = 1.25
Crafting.CRAFT_TIME = 1.25

function Crafting:Init()
	CustomGameEventManager:RegisterListener("ziv_recycle_request", Dynamic_Wrap(Crafting, 'RecycleRequest'))
	CustomGameEventManager:RegisterListener("ziv_craft_request", Dynamic_Wrap(Crafting, 'CraftingRequest'))
end

function Crafting:BlockContainer(container, block, pID)
	container:SetCanDragFrom(pID, block)
	container:SetCanDragWithin(pID, block)
	container:SetCanDragTo(pID, block)
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

function Crafting:CreateCraftingContainer( hero )
	hero.crafting = Containers:CreateContainer({
		layout 			= {4,4},
		skins 			= {"Crafting"},
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

function Crafting:RecycleRequest(args)
	local hero = Characters.current_session_characters[args.PlayerID]

	local container = hero.recycle

	local items = container:GetAllItems()

	for _,item in ipairs(items) do
		if ZIV.ItemKVs[item:GetName()].Craft then
			Crafting:BlockContainer(container, false, hero:GetPlayerOwnerID())

			Timers:CreateTimer(Crafting.RECYCLE_TIME, function (  )
				for _,item in ipairs(items) do
					if not string.match(item:GetName(),"craft") then
						local kv = ZIV.ItemKVs[item:GetName()]
						if kv.Craft then
							container:AddItem(Items:Create("item_craft_"..kv.Craft, hero))
						end
					end
					container:RemoveItem(item)
				end

				Crafting:BlockContainer(container, true, hero:GetPlayerOwnerID())
			end)

			CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(),"ziv_recycle_confirm",{duration = Crafting.RECYCLE_TIME})
			return
		end
	end

	EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(args.PlayerID))
end

function Crafting:UsePart( item, count, crafting )
	local used = 0

	for k,v in pairs(crafting:GetItemsByName(item)) do
		local charges = v:GetCurrentCharges()
		local to_spend = count - used
		if charges >= to_spend then
			v:SetCurrentCharges(charges - to_spend)
		else
			v:SetCurrentCharges(0)
		end

		if v:GetCurrentCharges() <= 0 then
			crafting:RemoveItem(v)
		end

		used = used + charges

		if used == count then
			return
		end
	end
end

function Crafting:CraftingRequest( keys )
	local item_name = string.gsub(keys["item"], "Recipe_", "")
	local rarity = tonumber(string.match(keys["item"],"%d+"))
	local pID = tonumber(keys.PlayerID)
	local hero = Characters.current_session_characters[pID]

	local crafting = hero.crafting

	local recipe = ZIV.RecipesKVs[item_name].Parts

	local pass = true

	for k,v in pairs(recipe) do
		if crafting:CheckForItem(k, tonumber(v)) == false then
			pass = false
			EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
			return false
		end
	end

	if pass then
		Crafting:BlockContainer(crafting, false, pID)

		Timers:CreateTimer(Crafting.CRAFT_TIME, function (  )
			for k,v in pairs(recipe) do
				Crafting:UsePart( k, v, crafting )
			end

			local base = GetRandomElement(ZIV.RecipesKVs[item_name].PossibleResults, nil, true)

			local item = Loot:CreateItem( hero, 2, rarity, nil, base )
		  	crafting:AddItem(item)

		  	Crafting:BlockContainer(crafting, true, pID)
		end)

		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pID), "ziv_craft_confirm", {duration = Crafting.CRAFT_TIME} )
	end
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
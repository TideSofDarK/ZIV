if Socketing == nil then
    _G.Socketing = class({})
end

-- Fortifying equipment
function Socketing:OnFortify( keys )
  	local playerID = keys.pID
  	local item = EntIndexToHScript(keys.item)
  	local tool = EntIndexToHScript(keys.tool)
  	if keys.seed then
  		math.randomseed(keys.seed)
  	end

  	local toolKV = ZIV.ItemKVs[tool:GetName()]
  	
  	item.fortify_modifiers = item.fortify_modifiers or {}

  	local new_modifiers = Socketing:GetRandomFortifyModifiers( toolKV["FortifyModifiers"], tonumber(toolKV["FortifyModifiersCount"]) or 0 )
  	new_modifiers["gem"] = tool:GetName()

  	if string.match(tool:GetName(), "rune") and tool.fortify_modifiers then
  		for k,v in pairs(tool.fortify_modifiers) do
  			for k2,v2 in pairs(v) do
  				if k2 ~= "gem" then
  					new_modifiers[k2] = (new_modifiers[k2] or 0) + v2
  				end
  			end
  		end
  	end

  	table.insert(item.fortify_modifiers, new_modifiers)

    Items:UpdateItem(item)

  	if playerID and playerID >= 0 then
	  	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "ziv_fortify_item_result", { itemID = keys.item, modifiers = item.fortify_modifiers } )

	  	Crafting:UsePart( tool, 1, tonumber(playerID) )
  	end

  	ResetRandomSeed()
end

function Socketing:GetRandomFortifyModifiers( modifiers_kv, count )
	local modifiers = {}

	if not modifiers_kv or not count then return modifiers end

	for i=1,count do
		local modifier = ""
		local value = 0
		local seed = math.random(1, GetTableLength(modifiers_kv))

		local x = 1
		for modifier_name,modifier_values in pairs(modifiers_kv) do
			if x == seed then
				modifier = modifier_name
				value = math.random(tonumber(modifier_values["min"]), tonumber(modifier_values["max"]))
				break
			end
			x = x + 1
		end
		
		modifiers[modifier] = value
	end

	return modifiers
end

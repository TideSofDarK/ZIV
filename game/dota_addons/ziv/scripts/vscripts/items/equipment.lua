function CheckSlot( unit, slot )
	local modifierCount = unit:GetModifierCount()
	for i=0,modifierCount do
		local modifier = unit:GetModifierNameByIndex(i)
		if modifier then
			if string.match(modifier, "_equipped_"..slot) then
				unit:RemoveModifierByName(modifier)
				UnEquip( unit, modifier )
				break
			end
		end
	end
end

function UnEquip( unit, buffName )
	if string.match(buffName, "_equipped_") then
    	unit:RemoveModifierByName(buffName)

    	local itemName = string.gsub (string.gsub (buffName, "modifier", "item"), "_equipped_%a+", "")

    	local new_item = unit:AddItemByName(itemName)

    	if unit.fortify_modifiers[itemName] and unit:HasAbility("ziv_fortify_modifiers") then
			for k,v in pairs(unit.fortify_modifiers[itemName]) do
				if unit:HasModifier(k) then
					unit:SetModifierStackCount(k, unit, unit:GetModifierStackCount(k, unit) - v)
				end
			end

			new_item.fortify_modifiers = unit.fortify_modifiers[itemName]
			unit.fortify_modifiers[itemName] = nil
		end
  	end
end

function Equip( keys )
	local caster = keys.caster
	local ability = keys.ability

	local itemName = ability:GetName()

	CheckSlot( caster, ZIV.ItemKVs[itemName]["Slot"] )

	for i=1,2 do
		local custom_skill = ZIV.ItemKVs[itemName]["CustomSkill"..tostring(i)]
		if custom_skill then

			caster.ability_levels = caster.ability_levels or {}
			caster.ability_levels[i] = caster:GetAbilityByIndex(i-1):GetLevel()
			
			caster:RemoveAbility(caster:GetAbilityByIndex(i-1):GetName())
			caster:AddAbility(custom_skill)

			caster:FindAbilityByName(custom_skill):SetLevel(caster.ability_levels[i])
		end
	end

	if ability.fortify_modifiers and caster:HasAbility("ziv_fortify_modifiers") then
		local fortify_modifiers_ability = caster:FindAbilityByName("ziv_fortify_modifiers")

		for k,v in pairs(ability.fortify_modifiers) do

			if caster:HasModifier(k) then
				caster:SetModifierStackCount(k, caster, v + caster:GetModifierStackCount(k, caster))
			else
				fortify_modifiers_ability:ApplyDataDrivenModifier(caster, caster, k, {})
				caster:SetModifierStackCount(k, caster, v)
			end
		end

		caster.fortify_modifiers = caster.fortify_modifiers or {}
		caster.fortify_modifiers[itemName] = ability.fortify_modifiers
	end

	Timers:CreateTimer(0.03, function (  )
      	UTIL_Remove(ability)
    end)
end

-- Equipping
function ZIV:OnBuffClicked(keys)
  	local playerID = keys.pID
  	local unit = EntIndexToHScript(keys.entityID)
  	local buffName = keys.buffName

  	UnEquip( unit, buffName )
end

-- Fortifying equipment
function ZIV:OnFortify( keys )
  	local playerID = keys.pID
  	local item = EntIndexToHScript(keys.item)
  	local tool = EntIndexToHScript(keys.tool)

  	local toolKV = ZIV.ItemKVs[tool:GetName()]
  	item.fortify_modifiers = GetRandomFortifyModifiers( toolKV["FortifyModifiers"], tonumber(toolKV["FortifyModifiersCount"]) )

  	UTIL_Remove(tool)
end

function GetRandomFortifyModifiers( modifiers_kv, count )
	local modifiers = {}
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
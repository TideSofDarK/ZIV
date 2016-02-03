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

    	unit:AddItemByName(itemName)
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

	Timers:CreateTimer(0.03, function (  )
      	UTIL_Remove(ability)
    end)
end
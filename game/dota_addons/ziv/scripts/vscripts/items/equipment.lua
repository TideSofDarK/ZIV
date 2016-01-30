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

	Timers:CreateTimer(0.06, function (  )
      	UTIL_Remove(ability)
    end)
end
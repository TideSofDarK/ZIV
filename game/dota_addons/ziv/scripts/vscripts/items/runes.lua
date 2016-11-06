function CDOTA_BaseNPC_Hero:AddOnRuneModifierAppliedCallback( callback )
  self._OnRuneModifierAppliedCallbacks = self._OnRuneModifierAppliedCallbacks or {}

  local callback_string = DoUniqueString("callback")

  self._OnRuneModifierAppliedCallbacks[callback_string] = callback

  return callback_string
end

function CDOTA_BaseNPC_Hero:AddOnRuneModifierRemovedCallback( callback )
  self._OnRuneModifierRemovedCallbacks = self._OnRuneModifierRemovedCallbacks or {}

  local callback_string = DoUniqueString("callback")

  self._OnRuneModifierRemovedCallbacks[callback_string] = callback

  return callback_string
end

function GRMSC(name, caster)
	if not caster.GetModifierStackCount then return 0 end
	return caster:GetModifierStackCount(name,nil) or 0
end

function StartRuneCooldown(ability,name,caster)
	ability:EndCooldown()
	ability:StartCooldown((1 - (GRMSC(name,caster) / 100)) * ability:GetCooldown(ability:GetLevel())) 
end

function GetRuneDamage(caster, damage_amp, name)
	return (damage_amp + (GRMSC(name,caster) / 100)) * caster:GetAverageTrueAttackDamage(caster)
end

function GetRunePercentIncrease(value,name,caster)
	return ((GRMSC(name,caster) / 100) + 1) * value
end

function GetRunePercentDecrease(value,name,caster)
	return (1 - (GRMSC(name,caster) / 100)) * value
end

function GetRuneChance(name,caster)
	local result = math.random(0, 100) > (100 - GRMSC(name,caster))
	if result then
		caster:EmitSound("Hero_ObsidianDestroyer.EssenceAura")
	end
	return result
end

function BasicPropertyRune(keys)
	local caster = keys.caster
	local ability = keys.ability

	local target = caster

	if keys["pet_key"] and IsValidEntity(caster[keys["pet_key"]]) then
		target = caster[keys["pet_key"]]
	end

	if keys.check_modifier and target:HasModifier("keys.check_modifier") == false then
		target:RemoveModifierByName(keys.modifier_name)
	else
		local stacks = GRMSC(keys.rune_modifier,target)

		if stacks > 0 then
			ability:ApplyDataDrivenModifier(target,target,keys.modifier_name,{})
			target:SetModifierStackCount(keys.modifier_name,target,stacks)
		else
			target:RemoveModifierByName(keys.modifier_name)
		end
	end

	Timers:CreateTimer(0.1, function (  )
		BasicPropertyRune(keys)
	end)
end

function RuneToHero( rune_modifier )
	for k,v in pairs(ZIV.HeroesKVs) do
		if string.match(rune_modifier, v.SecondName) then
			return v.override_hero
		end
	end
end
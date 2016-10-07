DAMAGE_TYPE_FIRE = 9
DAMAGE_TYPE_COLD = 10
DAMAGE_TYPE_LIGHTNING = 11
DAMAGE_TYPE_DARK = 12

function DealDamage( attacker, victim, damage, damage_type, no_popup)
	local damage_type = damage_type
	local damage = damage
	if damage_type >= DAMAGE_TYPE_FIRE then
		local resistance = victim:GetModifierStackCount("modifier_all_resistances",nil) or 0

		if damage_type == DAMAGE_TYPE_FIRE then
			resistance = victim:GetModifierStackCount("modifier_fire_resistance",nil) + resistance
		elseif damage_type == DAMAGE_TYPE_COLD then
			resistance = victim:GetModifierStackCount("modifier_cold_resistance",nil) + resistance
		elseif damage_type == DAMAGE_TYPE_LIGHTNING then
			resistance = victim:GetModifierStackCount("modifier_lightning_resistance",nil) + resistance
		elseif damage_type == DAMAGE_TYPE_DARK then
			resistance = victim:GetModifierStackCount("modifier_dark_resistance",nil) + resistance
		end

		damage = damage - (damage * (resistance/100))

		damage_type = DAMAGE_TYPE_MAGICAL
	end

	local min_damage = damage * 0.75
	local max_damage = damage * 1.25
	local coef = max_damage - damage

	damage = math.random(min_damage, max_damage)

	local damage_table = {
		victim = victim,
		attacker = attacker,
		damage = damage,
		damage_type = damage_type
	}

	if math.random(0, 1) == 0 then
		StartAnimation(victim, {duration=0.3, activity=ACT_DOTA_FLINCH, rate=1.5})
	end
	
	ApplyDamage(damage_table)
	if attacker.GetPlayerOwnerID and 
		attacker:GetPlayerOwnerID() >= 0 and 
		GetZIVSpecificSetting(attacker:GetPlayerOwnerID(), "Damage") 
		and not no_popup then 
		if damage >= (min_damage + max_damage) / 2 then
			PopupDamage(attacker:GetPlayerOwner(), victim, round(damage), clamp(damage / max_damage, 0, 1))
		end
	end
	-- PopupExperience(victim, math.ceil(damage))

	return round(damage)
end
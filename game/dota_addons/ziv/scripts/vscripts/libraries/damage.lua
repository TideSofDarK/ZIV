DAMAGE_TYPE_FIRE = 9
DAMAGE_TYPE_COLD = 10
DAMAGE_TYPE_LIGHTNING = 11
DAMAGE_TYPE_DARK = 12

function DealDamage( _attacker, _victim, _damage, _type, no_popup)
	local _type = _type
	local _damage = _damage
	if _type >= DAMAGE_TYPE_FIRE then
		local resistance = _victim:GetModifierStackCount("modifier_all_resistances",nil) or 0

		if _type == DAMAGE_TYPE_FIRE then
			resistance = _victim:GetModifierStackCount("modifier_fire_resistance",nil) + resistance
		elseif _type == DAMAGE_TYPE_COLD then
			resistance = _victim:GetModifierStackCount("modifier_cold_resistance",nil) + resistance
		elseif _type == DAMAGE_TYPE_LIGHTNING then
			resistance = _victim:GetModifierStackCount("modifier_lightning_resistance",nil) + resistance
		elseif _type == DAMAGE_TYPE_DARK then
			resistance = _victim:GetModifierStackCount("modifier_dark_resistance",nil) + resistance
		end

		_damage = _damage - (_damage * (resistance/100))

		_type = DAMAGE_TYPE_MAGICAL
	end

	local min_damage = _damage * 0.75
	local max_damage = _damage * 1.25
	local coef = max_damage - _damage

	_damage = math.random(min_damage, max_damage)

	local damage_table = {
		victim = _victim,
		attacker = _attacker,
		damage = _damage,
		damage_type = _type
	}

	if math.random(0, 1) == 0 then
		StartAnimation(_victim, {duration=0.3, activity=ACT_DOTA_FLINCH, rate=1.5})
	end
	
	ApplyDamage(damage_table)
	if _attacker.GetPlayerOwnerID and 
		_attacker:GetPlayerOwnerID() >= 0 and 
		GetZIVSpecificSetting(_attacker:GetPlayerOwnerID(), "Damage") 
		and not no_popup then 
		PopupDamage(_attacker:GetPlayerOwner(), _victim, round(_damage), clamp(_damage / max_damage, 0, 1))
	end
	-- PopupExperience(_victim, math.ceil(_damage))

	return round(_damage)
end
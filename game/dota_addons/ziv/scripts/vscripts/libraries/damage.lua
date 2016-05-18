DAMAGE_TYPE_FIRE = 9
DAMAGE_TYPE_COLD = 10
DAMAGE_TYPE_LIGHTNING = 11
DAMAGE_TYPE_DARK = 12

function DealDamage( _attacker, _victim, _damage, _type )
	local _type = _type
	local _damage = _damage
	if _type >= DAMAGE_TYPE_FIRE then
		local resistance = 0
		resistance = _victim:GetModifierStackCount("modifier_all_resistances",nil) or resistance

		if _type == DAMAGE_TYPE_FIRE then
			resistance = _victim:GetModifierStackCount("modifier_fire_resistance",nil) or resistance
		elseif _type == DAMAGE_TYPE_COLD then
			resistance = _victim:GetModifierStackCount("modifier_cold_resistance",nil) or resistance
		elseif _type == DAMAGE_TYPE_LIGHTNING then
			resistance = _victim:GetModifierStackCount("modifier_lightning_resistance",nil) or resistance
		elseif _type == DAMAGE_TYPE_DARK then
			resistance = _victim:GetModifierStackCount("modifier_dark_resistance",nil) or resistance
		end

		_damage = _damage - (_damage * (resistance/100))

		_type = DAMAGE_TYPE_MAGICAL
	end

	local damageTable = {
		victim = _victim,
		attacker = _attacker,
		damage = _damage,
		damage_type = _type
	}

	if math.random(0, 1) == 0 then
		StartAnimation(_victim, {duration=0.3, activity=ACT_DOTA_FLINCH, rate=1.5})
	end
	
	ApplyDamage(damageTable)
	PopupDamage(_victim, math.ceil(_damage))
	-- PopupExperience(_victim, math.ceil(_damage))
end
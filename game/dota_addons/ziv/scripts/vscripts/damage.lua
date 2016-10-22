if Damage == nil then
    _G.Damage = class({})
end

Damage.ALL_RESISTANCES 			= 0
Damage.FIRE_RESISTANCE 			= 1
Damage.COLD_RESISTANCE 			= 2
Damage.LIGHTNING_RESISTANCE 	= 3
Damage.DARK_RESISTANCE 			= 4

DAMAGE_TYPE_FIRE 		= 9
DAMAGE_TYPE_COLD 		= 10
DAMAGE_TYPE_LIGHTNING 	= 11
DAMAGE_TYPE_DARK 		= 12

function Damage:Init()
	PlayerTables:CreateTable("resistances", {}, true)
end

function Damage:ModifyResist(unit, resist, amount, time)
	local unit_resistances = PlayerTables:GetTableValue("resistances", unit:entindex()) or {}

	unit_resistances[resist] = unit_resistances[resist] or 0
	unit_resistances[resist] = unit_resistances[resist] + amount

	PlayerTables:SetTableValue("resistances", unit:entindex(), unit_resistances)

	if time then
		Timers:CreateTimer(time, function (  )
			Damage:ModifyResist(unit, resist, -amount)
		end)
	end
end

function Damage:GetResist( unit, resist )
	local unit_resistances = PlayerTables:GetTableValue("resistances", unit:entindex()) or {}
	if resist ~= ALL_RESISTANCES then
		return (unit_resistances[resist] or 0) + (unit_resistances[ALL_RESISTANCES] or 0)
	else
		return unit_resistances[resist] or 0
	end
end

function Damage:Deal( attacker, victim, damage, damage_type, no_popup)
	local damage_type = damage_type
	local damage = damage
	if damage_type >= DAMAGE_TYPE_FIRE then
		local resistance = 0

		if damage_type == DAMAGE_TYPE_FIRE then
			resistance = Damage:GetResist( unit, Damage.FIRE_RESISTANCE )
		elseif damage_type == DAMAGE_TYPE_COLD then
			resistance = Damage:GetResist( unit, Damage.COLD_RESISTANCE )
		elseif damage_type == DAMAGE_TYPE_LIGHTNING then
			resistance = Damage:GetResist( unit, Damage.LIGHTNING_RESISTANCE )
		elseif damage_type == DAMAGE_TYPE_DARK then
			resistance = Damage:GetResist( unit, Damage.DARK_RESISTANCE )
		end

		damage = damage - (damage * (resistance/100))
	end

	local min_damage = damage * 0.75
	local max_damage = damage * 1.25
	local coef = max_damage - damage

	damage = math.random(min_damage, max_damage)

	local damage_table = {
		victim = victim,
		attacker = attacker,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE
	}

	if math.random(0, 1) == 0 then
		StartAnimation(victim, {duration=0.3, activity=ACT_DOTA_FLINCH, rate=1.5})
	end
	
	ApplyDamage(damage_table)
	if attacker.GetPlayerOwnerID and 
		attacker:GetPlayerOwnerID() >= 0 and 
		GetZIVSpecificSetting(attacker:GetPlayerOwnerID(), "Damage") 
		and not no_popup then 
		-- if damage >= (min_damage + max_damage) / 2 then
			PopupDamage(attacker:GetPlayerOwner(), victim, round(damage), clamp(damage / max_damage, 0, 1))
		-- end
	end
	-- PopupExperience(victim, math.ceil(damage))

	return round(damage)
end
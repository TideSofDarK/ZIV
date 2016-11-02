if Damage == nil then
    _G.Damage = class({})
end

Damage.ALL_RESISTANCES 				= 0
Damage.FIRE_RESISTANCE 				= 1
Damage.COLD_RESISTANCE 				= 2
Damage.LIGHTNING_RESISTANCE 		= 3
Damage.DARK_RESISTANCE 				= 4

Damage.FIRE_DAMAGE_INCREASE 		= 5
Damage.COLD_DAMAGE_INCREASE 		= 6
Damage.LIGHTNING_DAMAGE_INCREASE 	= 7
Damage.DARK_DAMAGE_INCREASE 		= 8

Damage.CRIT_CHANCE 					= 9
Damage.CRIT_DAMAGE 					= 10

Damage.DEFAULTS = {}
Damage.DEFAULTS[Damage.CRIT_CHANCE] = 5
Damage.DEFAULTS[Damage.CRIT_DAMAGE] = 200

Damage.ESSENCE_PARTICLES = {}
Damage.ESSENCE_PARTICLES[1] = "particles/creeps/ziv_creep_essence_a.vpcf"
Damage.ESSENCE_PARTICLES[2] = "particles/creeps/ziv_creep_essence_b.vpcf"

Damage.BONES_PARTICLES = {}
Damage.BONES_PARTICLES[1] = "particles/creeps/ziv_creep_bones_a.vpcf"
Damage.BONES_PARTICLES[2] = "particles/creeps/ziv_creep_bones_b.vpcf"

Damage.BLOOD_PARTICLES = {}
Damage.BLOOD_PARTICLES[1] = "particles/creeps/ziv_creep_blood_a.vpcf"
Damage.BLOOD_PARTICLES[2] = "particles/creeps/ziv_creep_blood_b.vpcf"
Damage.BLOOD_PARTICLES[3] = "particles/creeps/ziv_creep_blood_c.vpcf"
Damage.BLOOD_PARTICLES[4] = "particles/creeps/ziv_creep_blood_d.vpcf"

DAMAGE_TYPE_FIRE 					= 9
DAMAGE_TYPE_COLD 					= 10
DAMAGE_TYPE_LIGHTNING 				= 11
DAMAGE_TYPE_DARK 					= 12

function Damage:Init()
	PlayerTables:CreateTable("damage", {}, true)
end

function Damage:InitHero( hero )
	for k,v in pairs(Damage.DEFAULTS) do
		Damage:Modify(hero, k, v)
	end
end

function Damage:Modify(unit, value, amount, time)
	local values = PlayerTables:GetTableValue("damage", unit:entindex()) or {}

	values[value] = values[value] or 0
	values[value] = values[value] + amount

	PlayerTables:SetTableValue("damage", unit:entindex(), values)

	if time then
		Timers:CreateTimer(time, function (  )
			Damage:Modify(unit, value, -amount)
		end)
	end
end

function Damage:GetValue( unit, value )
	local values = PlayerTables:GetTableValue("damage", unit:entindex()) or {}
	return values[value] or 0
end

function Damage:GetResist( unit, resist )
	if resist == Damage.ALL_RESISTANCES then
		return Damage:GetValue( unit, resist )
	else
		return Damage:GetValue( unit, resist ) + Damage:GetValue( unit, Damage.ALL_RESISTANCES )
	end
end

function Damage:Deal( attacker, victim, damage, damage_type, no_popup, no_blood)
	local damage_type = damage_type
	local damage = damage

	-- Check for modifier_kill 
	if damage_type == DAMAGE_TYPE_PURE and victim:IsSummoned() and attacker:GetPlayerOwnerID() == attacker:GetPlayerOwnerID() then
		no_blood = true
		no_popup = true
	end

	if damage_type >= DAMAGE_TYPE_FIRE then
		local increase = 0

		if damage_type == DAMAGE_TYPE_FIRE then
			increase = Damage:GetValue( attacker, Damage.FIRE_DAMAGE_INCREASE )
		elseif damage_type == DAMAGE_TYPE_COLD then
			increase = Damage:GetValue( attacker, Damage.COLD_DAMAGE_INCREASE )
		elseif damage_type == DAMAGE_TYPE_LIGHTNING then
			increase = Damage:GetValue( attacker, Damage.LIGHTNING_DAMAGE_INCREASE )
		elseif damage_type == DAMAGE_TYPE_DARK then
			increase = Damage:GetValue( attacker, Damage.DARK_DAMAGE_INCREASE )
		end

		damage = damage + (damage * (increase/100))

		local resistance = 0

		if damage_type == DAMAGE_TYPE_FIRE then
			resistance = Damage:GetResist( victim, Damage.FIRE_RESISTANCE )
		elseif damage_type == DAMAGE_TYPE_COLD then
			resistance = Damage:GetResist( victim, Damage.COLD_RESISTANCE )
		elseif damage_type == DAMAGE_TYPE_LIGHTNING then
			resistance = Damage:GetResist( victim, Damage.LIGHTNING_RESISTANCE )
		elseif damage_type == DAMAGE_TYPE_DARK then
			resistance = Damage:GetResist( victim, Damage.DARK_RESISTANCE )
		end

		damage = damage - (damage * (resistance/100))
	elseif damage_type == DAMAGE_TYPE_PHYSICAL then

	end
	
	local min_damage = damage * 0.75
	local max_damage = damage * 1.25
	local coef = max_damage - damage

	damage = math.random(min_damage, max_damage)

	if RollPercentage(Damage:GetValue( attacker, Damage.CRIT_CHANCE )) then
		damage = damage * (Damage:GetValue( attacker, Damage.CRIT_DAMAGE ) / 100)
		local particle = ParticleManager:CreateParticle("particles/ziv_damage_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
	end

	local damage_table = {
		victim = victim,
		attacker = attacker,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE
	}
	ApplyDamage(damage_table)

	if math.random(0, 1) == 0 then
		StartAnimation(victim, {duration=0.3, activity=ACT_DOTA_FLINCH, rate=1.5})
	end

	if not no_blood then
		Damage:BloodParticle( victim )
	end
	
	if attacker.GetPlayerOwnerID and 
		attacker:GetPlayerOwnerID() >= 0 and 
		GetZIVSpecificSetting(attacker:GetPlayerOwnerID(), "Damage") 
		and not no_popup then 
		-- if damage >= (min_damage + max_damage) / 2 then
			PopupDamage(attacker:GetPlayerOwner(), victim, round(damage), damage / max_damage)
		-- end
	end
	-- PopupExperience(victim, math.ceil(damage))

	return round(damage)
end

function Damage:BloodParticle( unit )
	local particle_name = GetRandomElement(Damage.BLOOD_PARTICLES)

	local unitKV = ZIV.UnitKVs[unit:GetUnitName()]
	if not unitKV then
		return
	end
	
	local particle_type = unitKV["ImpactParticleType"]
	if particle_type then
		if particle_type == "Essence" then
			particle_name = GetRandomElement(Damage.ESSENCE_PARTICLES)
		elseif particle_type == "Bones" then
			particle_name = GetRandomElement(Damage.BONES_PARTICLES)
		elseif particle_type == "No" then return end
	end

	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, unit)
end
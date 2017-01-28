if Damage == nil then
    _G.Damage = class({})
end

--[[
	Possible modifiers:

	MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT_REDUCE
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	MODIFIER_PROPERTY_HEALTH_BONUS
	MODIFIER_PROPERTY_STATS_ALL_BONUS

	ALL_RESISTANCES
	FIRE_RESISTANCE
	COLD_RESISTANCE
	LIGHTNING_RESISTANCE
	DARK_RESISTANCE

	FIRE_DAMAGE_INCREASE
	COLD_DAMAGE_INCREASE
	LIGHTNING_DAMAGE_INCREASE
	DARK_DAMAGE_INCREASE

	CRIT_CHANCE
	CRIT_DAMAGE

	EVASION
	ARMOR

	HP_LEECH
	EP_LEECH

	PIERCE
]]

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

Damage.EVASION 						= 11
Damage.ARMOR 						= 12

Damage.HP_LEECH 					= 13
Damage.EP_LEECH 					= 14

Damage.PIERCE 						= 15

Damage.DEFAULTS = {}
Damage.DEFAULTS[Damage.ALL_RESISTANCES] 			= 0
Damage.DEFAULTS[Damage.FIRE_RESISTANCE] 			= 0
Damage.DEFAULTS[Damage.COLD_RESISTANCE] 			= 0
Damage.DEFAULTS[Damage.LIGHTNING_RESISTANCE] 		= 0
Damage.DEFAULTS[Damage.DARK_RESISTANCE] 			= 0
Damage.DEFAULTS[Damage.FIRE_DAMAGE_INCREASE] 		= 0
Damage.DEFAULTS[Damage.COLD_DAMAGE_INCREASE] 		= 0
Damage.DEFAULTS[Damage.LIGHTNING_DAMAGE_INCREASE] 	= 0
Damage.DEFAULTS[Damage.DARK_DAMAGE_INCREASE] 		= 0
Damage.DEFAULTS[Damage.CRIT_CHANCE] 				= 5
Damage.DEFAULTS[Damage.CRIT_DAMAGE] 				= 200
Damage.DEFAULTS[Damage.EVASION] 					= 100
Damage.DEFAULTS[Damage.ARMOR] 						= 0
Damage.DEFAULTS[Damage.HP_LEECH] 					= 10
Damage.DEFAULTS[Damage.EP_LEECH] 					= 10
Damage.DEFAULTS[Damage.PIERCE] 						= 0

DAMAGE_TYPE_FIRE 					= 9
DAMAGE_TYPE_COLD 					= 10
DAMAGE_TYPE_LIGHTNING 				= 11
DAMAGE_TYPE_DARK 					= 12

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

Damage.DAMAGE_POPUP_SIZE = 35

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

function Damage:Deal( attacker, victim, damage, damage_type, no_popup, no_blood, no_random)
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
		local armor = Damage:GetValue( attacker, Damage.ARMOR )

		damage = damage - (damage * (armor/200))
	end

	if damage_type ~= DAMAGE_TYPE_PURE then
		local evasion = Damage:GetValue( attacker, Damage.EVASION )
		if attacker.evasion_rng and attacker.evasion_rng:Next(evasion / 300) then
			damage = (damage / 10)
		end
	end
	
	local min_damage = damage * 0.75
	local max_damage = damage * 1.25
	local coef = max_damage - damage

	if not no_random then
		damage = math.random(min_damage, max_damage)

		local attacker_player = attacker:GetPlayerOwner()
		if attacker_player and PlayerResource:IsValidPlayer(attacker_player:GetPlayerID()) and RollPercentage(Damage:GetValue( attacker, Damage.CRIT_CHANCE )) then
			damage = damage * (Damage:GetValue( attacker, Damage.CRIT_DAMAGE ) / 100)

			if not no_blood and not no_popup then
				local shake = ParticleManager:CreateParticleForPlayer("particles/ziv_damage_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker, attacker_player)
			end	
		end
	end

	local damage_table = {
		victim = victim,
		attacker = attacker,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE
	}

	-- Process damage callbacks
	if victim._OnTakeDamageCallbacks then
		for k,v in pairs(victim._OnTakeDamageCallbacks) do
      		local result = v(damage_table)
    		if type(result) == "table" then
    			damage_table = result
    		elseif result then 
        		victim._OnTakeDamageCallbacks[k] = nil 
        	end
      	end
    end
    
	ApplyDamage(damage_table)

	if victim:GetTeamNumber() ~= attacker:GetTeamNumber() then
		local hp_leech = Damage:GetValue( attacker, Damage.HP_LEECH )
		local ep_leech = Damage:GetValue( attacker, Damage.EP_LEECH )

		if hp_leech > 0 then
			attacker:Heal(damage * (hp_leech / 100),nil)
		end

		if ep_leech > 0 then
			attacker:GiveMana(damage * (ep_leech / 100))
		end

		if math.random(0, 1) == 0 then
			StartAnimation(victim, {duration=0.3, activity=ACT_DOTA_FLINCH, rate=1.5})
		end

		if not no_blood then
			Damage:BloodParticle( victim )
		end
	end
	
	if attacker.GetPlayerOwnerID and 
		attacker:GetPlayerOwnerID() >= 0 and 
		GetZIVSpecificSetting(attacker:GetPlayerOwnerID(), "Damage") 
		and not no_popup then 

		PopupDamage(attacker:GetPlayerOwner(), victim, round(damage), damage / max_damage)
	end

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
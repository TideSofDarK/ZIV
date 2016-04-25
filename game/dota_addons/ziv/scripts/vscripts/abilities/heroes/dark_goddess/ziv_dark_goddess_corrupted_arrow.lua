function ToggleArrows( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability:RefundManaCost()

	if ability:GetToggleState() == true then
		caster:RemoveModifierByName("modifier_corrupted_arrow")
	else
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_corrupted_arrow",{})
	end

	ability:ToggleAbility()
end

function SpawnSpirit( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability

	local pID = caster:GetPlayerOwnerID()

	local spirit_duration = ability:GetSpecialValueFor("spirit_duration")

	PrecacheUnitByNameAsync("npc_dark_goddess_spirit", function (  )
		local spirit_count = math.random(ability:GetSpecialValueFor("spirit_min"), ability:GetSpecialValueFor("spirit_max"))

		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),  nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		local i = 1
		for k,v in pairs(units) do
			if i >= spirit_count then break end
			if v then
				SpawnSingleSpirit(caster, ability, v:GetAbsOrigin(), spirit_duration) 
				i = i + 1
			end
		end

		SpawnSingleSpirit(caster, ability, target:GetAbsOrigin(), spirit_duration) 

		caster:EmitSound("Hero_Enigma.Demonic_Conversion")
	end, pID)
end

function SpawnSingleSpirit(caster, ability, position, spirit_duration) 
	local spirit = CreateUnitByName("npc_dark_goddess_spirit", position, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster,spirit,"modifier_corrupted_spirit",{})

	spirit:AddNewModifier(spirit, nil, "modifier_kill", {duration = spirit_duration})

	Timers:CreateTimer(function (  )
		if spirit:IsAlive() then
			spirit:MoveToPositionAggressive(spirit:GetAbsOrigin())
		end
	end)

	return spirit
end

function RestoreEnergy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local energy_restored = ability:GetSpecialValueFor("energy_restored")
	
	caster:GiveMana(energy_restored)
	PopupMana(target, energy_restored)
end

function AdditionalDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target then return end

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),  nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(units) do
		local particle = ParticleManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_corrupted_arrow_dispersion.vpcf", PATTACH_CUSTOMORIGIN, target)

    	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin() + Vector(0,0,16), true)
    	ParticleManager:SetParticleControlEnt(particle, 1, v, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin() + Vector(0,0,16), true)

		DealDamage(caster, v, (ability:GetSpecialValueFor("attack_damage_amp") * caster:GetAverageTrueAttackDamage()) / 3, DAMAGE_TYPE_PURE)
		v:EmitSound("Hero_Spectre.PreAttack")
	end

	DealDamage(caster, target, ability:GetSpecialValueFor("attack_damage_amp") * caster:GetAverageTrueAttackDamage(), DAMAGE_TYPE_PURE)
end
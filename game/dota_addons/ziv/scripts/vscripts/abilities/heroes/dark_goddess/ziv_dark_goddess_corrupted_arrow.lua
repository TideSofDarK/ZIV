function FireArrow( keys )
	keys.on_hit = AdditionalDamage
	keys.on_kill = SpawnSpirit
	keys.pierce = GetSpecial(keys.ability, "pierce")
	keys.attachment = "bow_mid"
	keys.impact_effect = "particles/heroes/dark_goddess/dark_goddess_corrupted_arrow_g.vpcf"
	SimulateRangeAttack(keys)
end

function SpawnSpirit( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability

	if target:HasModifier("modifier_corrupted_arrow_effect") == false then return end

	local pID = caster:GetPlayerOwnerID()

	local spirit_duration = ability:GetSpecialValueFor("spirit_duration")

	PrecacheUnitByNameAsync("npc_dark_goddess_spirit", function (  )
		if target and target:IsAlive() == false then
			local spirit_count = 1 + GRMSC("ziv_dark_goddess_corrupted_arrow_spirit_count",caster)

			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),  nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			local i = 0
			for k,v in pairs(units) do
				if i >= spirit_count then break end
				if v then
					AddChildEntity(caster,SpawnSingleSpirit(caster, ability, v:GetAbsOrigin(), spirit_duration) )
					i = i + 1
				end
			end

			-- caster:EmitSound("Hero_Enigma.Demonic_Conversion")
		end
	end, pID)
end

function SpawnSingleSpirit(caster, ability, position, spirit_duration) 
	local spirit = CreateUnitByNameAsync("npc_dark_goddess_spirit", position, true, caster, caster, caster:GetTeamNumber(), function ( spirit )
		ability:ApplyDataDrivenModifier(caster,spirit,"modifier_corrupted_spirit",{})

		spirit:AddNewModifier(spirit, ability, "modifier_kill", {duration = spirit_duration})

		spirit:SetModelScale(0.59)
		spirit:SetAngles(0,math.random(0,360),0)

		Timers:CreateTimer(function (  )
			if spirit:IsAlive() then
				spirit:MoveToPositionAggressive(spirit:GetAbsOrigin() + Vector(0, 0, 0))
			end
		end)
	end)
end

function RestoreEnergy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	DealDamage(caster, target, caster:GetAverageTrueAttackDamage(), DAMAGE_TYPE_DARK)

	local energy_restored = ability:GetSpecialValueFor("energy_restored")
	
	caster:GiveMana(energy_restored)
	-- PopupMana(target, energy_restored)
end

function AdditionalDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target then return end

	ability:ApplyDataDrivenModifier(caster,target,"modifier_corrupted_arrow_effect",{duration = GetSpecial(ability, "corruption_duration")})

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, GetSpecial(ability, "aoe_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(units) do
		if v ~= target then
			local particle = ParticleManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_corrupted_arrow_dispersion.vpcf", PATTACH_CUSTOMORIGIN, target)

	    	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin() + Vector(0,0,16), true)
	    	ParticleManager:SetParticleControlEnt(particle, 1, v, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin() + Vector(0,0,16), true)

			-- DealDamage(caster, v, (ability:GetSpecialValueFor("damage_amp") * caster:GetAverageTrueAttackDamage()) / 3, DAMAGE_TYPE_DARK)
		end
	end

	target:EmitSound("Hero_Spectre.PreAttack")

	DealDamage(caster, target, ability:GetSpecialValueFor("damage_amp") * caster:GetAverageTrueAttackDamage(), DAMAGE_TYPE_DARK)
end
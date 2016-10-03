function SpawnPet( keys )
	local caster = keys.caster
	local ability = keys.ability

	local level = ability:GetLevel()

	KillPet( keys )

	if ability:GetToggleState() == false then
		local unit_name = keys.unit_name or "npc_beastmaster_pet1"
		PrecacheUnitByNameAsync(unit_name, function () 
			caster.pet = CreateUnitByName(unit_name, caster:GetAbsOrigin() + RandomPointOnCircle(75), false, caster, caster, caster:GetTeamNumber())

			ability:ApplyDataDrivenModifier(caster, caster.pet, "modifier_beastmaster_pet", {})

			caster:EmitSound("Hero_Beastmaster.Call.Boar")

			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_call_boar.vpcf", PATTACH_ABSORIGIN, caster.pet)
			ParticleManager:SetParticleControl(particle, 0, caster.pet:GetAbsOrigin())

			SetToggleState( ability, true )
		end, caster:GetPlayerOwnerID())
	else
		SetToggleState( ability, false )
	end
end

function KillPet( keys )
	local caster = keys.caster
	local ability = keys.ability

	if caster.pet and not caster.pet:IsNull() then
		caster.pet:Kill(ability, caster)
	end
end

function PetDied(keys)
	local ability = keys.ability

	if keys.attacker ~= keys.caster then
		SetToggleState( ability, false )
	end
end

function PetAI( keys )
	local caster = keys.caster

	local distance = (caster:GetAbsOrigin() - caster.pet:GetAbsOrigin()):Length()

	if caster:IsAttacking() == true then
		ExecuteOrderFromTable({ UnitIndex = caster.pet:entindex(), OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, TargetIndex = caster:GetAttackTarget():entindex(), Queue = nil})
	elseif caster.pet:IsAttacking() == false then
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	
		if #units > 0 then
			ExecuteOrderFromTable({ UnitIndex = caster.pet:entindex(), OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, TargetIndex = units[1]:entindex(), Queue = nil})
		else
			if distance > 550 then
				ExecuteOrderFromTable({ UnitIndex = caster.pet:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = (caster:GetAbsOrigin() + (caster:GetForwardVector() * 350)), Queue = nil})
			else
				caster.pet.last_walking_time = caster.pet.last_walking_time or ZIV.TRUE_TIME
				if ZIV.TRUE_TIME - caster.pet.last_walking_time > math.random(3.5, 5.1) then
					ExecuteOrderFromTable({ UnitIndex = caster.pet:entindex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = caster:GetAbsOrigin() + RandomPointOnCircle(325), Queue = nil})
					caster.pet.last_walking_time = ZIV.TRUE_TIME
				end
			end
		end
	end
end

function WolfAttack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local damage = caster:GetAverageTrueAttackDamage() * GetSpecial(ability, "wolf_damage_amp")

	if GetChance(GetSpecial(ability, "wolf_crit_chance") + GRMSC("ziv_beastmaster_pet_crit_chance", caster)) then
		StartSoundEvent('Hero_PhantomAssassin.CoupDeGrace', target)
 		local particle = ParticleManager:CreateParticle('particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf', PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(particle,0,target,PATTACH_POINT,"attach_hitloc",target:GetAbsOrigin(),false)
		ParticleManager:SetParticleControlEnt(particle,1,target,PATTACH_POINT,"attach_hitloc",target:GetAbsOrigin(),false)
		ParticleManager:SetParticleControlOrientation(particle, 1, caster.pet:GetForwardVector() * -1, Vector(0, 1, 0), Vector(0, 0, 1))

		damage = damage * ((GetSpecial(ability, "wolf_crit_damage") + GRMSC("ziv_beastmaster_pet1_crit_damage", caster)) / 100)
	end

	DealDamage(caster,target,damage, DAMAGE_TYPE_PHYSICAL)
end

function BearAttack( keys )
	local caster = keys.caster
	local ability = keys.ablity
	local target = keys.target

	if GetChance(GetSpecial(ability, "bear_stun_chance") + GRMSC("ziv_beastmaster_pet2_stun_chance", caster)) then
		target:AddNewModifier(caster,ability,"modifier_stunned",{duration = GetSpecial(ability, "bear_stun_duration")})
	end

	DealDamage(caster,target,caster:GetAverageTrueAttackDamage() * GetSpecial(ability, "bear_damage_amp"),DAMAGE_TYPE_PHYSICAL)
end
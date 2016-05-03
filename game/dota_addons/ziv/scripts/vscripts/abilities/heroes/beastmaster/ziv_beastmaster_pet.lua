function BasicPropertyRunePet( keys)
	if caster.pet ~= nil and caster.pet:IsNull() == false and level == caster.pet:GetLevel() and not keys.respawn_pet then
		Timers:CreateTimer(0.1, function (  )
			BasicPropertyRunePet(keys)
		end)
	else
		keys.caster = caster.pet
		BasicPropertyRune(keys)
	end
end

function SpawnPet( keys )
	local caster = keys.caster
	local ability = keys.ability

	local level = ability:GetLevel()

	if caster.pet ~= nil and caster.pet:IsNull() == false and level == caster.pet:GetLevel() and not keys.respawn_pet then
		return
	else
		if keys.respawn_pet then
			KillPet( keys )
		end
		caster.pet = CreateUnitByName("npc_beastmaster_pet_level"..tostring(level), caster:GetAbsOrigin() + RandomPointOnCircle(400), false, caster, caster, caster:GetTeamNumber())
		ability:ApplyDataDrivenModifier(caster, caster.pet, "modifier_beastmaster_pet", {})

		if keys.model then
			caster.pet:SetModel(keys.model)
			caster.pet:SetOriginalModel(keys.model)
		end

		caster:EmitSound("Hero_Beastmaster.Call.Boar")

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_call_boar.vpcf", PATTACH_ABSORIGIN, caster.pet)
		ParticleManager:SetParticleControl(particle, 0, caster.pet:GetAbsOrigin())
	end
end

function KillPet( keys )
	local caster = keys.caster
	local ability = keys.ability

	if caster.pet then
		caster.pet:RemoveSelf()
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

function Crit( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, caster.pet, "modifier_wolf_crit", {})
end

function EndCrit( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster.pet:RemoveModifierByName("modifier_wolf_crit")
end
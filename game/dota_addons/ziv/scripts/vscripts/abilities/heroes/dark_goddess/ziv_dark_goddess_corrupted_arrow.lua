function FireArrow( keys )
	local caster = keys.caster

	keys.bonus_attack_speed = GRMSC("ziv_dark_goddess_corrupted_arrow_as", caster)
	keys.on_hit = OnHit
	keys.pierce = GetSpecial(keys.ability, "pierce") + GRMSC("modifier_concentration_pierce_rune", keys.caster)
	keys.attachment = "attach_hitloc"
	keys.translate = "frost_arrow"
	keys.impact_effect = "particles/heroes/dark_goddess/dark_goddess_corrupted_arrow_g.vpcf"
	SimulateRangeAttack(keys)
end

function SpawnSpirit( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability

	if target:HasModifier("modifier_corrupted_arrow_effect") == false then return end

	ability.spirits = ability.spirits or {}

	if GetTableLength(ability.spirits) < GetSpecial(ability, "spirits_count") + GRMSC("ziv_dark_goddess_corrupted_arrow_spirit_count",caster) then 
		local pID = caster:GetPlayerOwnerID()

		PrecacheUnitByNameAsync("npc_dark_goddess_spirit", function (  )
			if target and target:IsAlive() == false then
				local spirit = CreateUnitByName("npc_dark_goddess_spirit", target:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
				ability:ApplyDataDrivenModifier(caster,spirit,"modifier_corrupted_spirit",{})

				spirit:SetMaxHealth(caster:GetMaxHealth() * (GetSpecial(ability, "spirit_hp_percent") / 100))
				spirit:SetHealth(spirit:GetMaxHealth())

				spirit:SetModelScale(0.59)

				SetRandomAngle( spirit )

				SummonFollow( caster, spirit, 0.3, 325, 500 )

				Timers:CreateTimer(function (  )
					if spirit:IsAlive() then
						spirit:MoveToPositionAggressive(spirit:GetAbsOrigin() + Vector(0, 0, 0))
					end
				end)

				spirit:AddOnDiedCallback(function ()
					ability.spirits[spirit:entindex()] = nil
				end)

				ability.spirits[spirit:entindex()] = spirit

				AddChildEntity(caster, spirit)
			end
		end, pID)
	end
end

function SpiritAttack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	Damage:Deal(caster, target, GetRuneDamage(caster, GetSpecial(ability, "spirit_damage_amp"), ""), DAMAGE_TYPE_PHYSICAL)
end

function OnHit( keys )
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
		end
	end

	target:EmitSound("Hero_Spectre.PreAttack")

	Damage:Deal(caster, target, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), ""), DAMAGE_TYPE_DARK)
end
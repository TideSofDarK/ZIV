function Cleave( keys )
	local keys = keys

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- ability.activity = ability.activity or ACT_DOTA_ATTACK_EVENT
	-- if ability.activity == ACT_DOTA_ATTACK_EVENT then
	-- 	ability.activity = ACT_DOTA_ATTACK2
	-- 	keys.attack_particle = "particles/units/heroes/hero_ursa/ursa_claw_right.vpcf"
	-- else
	-- 	ability.activity = ACT_DOTA_ATTACK_EVENT
	-- 	keys.attack_particle = "particles/units/heroes/hero_ursa/ursa_claw_left.vpcf"
	-- end

	-- keys.activity = ability.activity

	keys.attack_speed_bonus = GetSpecial(ability, "attack_speed") + GRMSC("ziv_beastmaster_cleave_as", caster)

	keys.on_impact = (function ( keys )
		local radius = GetSpecial(ability, "radius")
		local units = FindUnitsInCone(caster:GetAbsOrigin(), caster:GetForwardVector(), radius, radius + GRMSC("ziv_beastmaster_cleave_aoe", caster), caster:GetTeamNumber(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER)
		
		if #units > 0 then
			caster:EmitSound(keys.attack_sound)

			for k,v in pairs(units) do
				Damage:Deal(caster,v,GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), ""), DAMAGE_TYPE_PHYSICAL)

				if GetRuneChance("ziv_beastmaster_cleave_stun_chance",caster) then
					v:AddNewModifier(caster,ability,"modifier_stunned",{duration = 0.1})
				end
			end
		end
	end)

	SimulateMeleeAttack( keys )
end
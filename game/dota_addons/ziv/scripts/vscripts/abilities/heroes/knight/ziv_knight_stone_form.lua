function StoneFormStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_stone_form_stacks",{})

	StartAnimation(caster, {duration=-1, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.6})
	Timers:CreateTimer(0.6, function ()
		FreezeAnimation(caster)
	end)

	ability.scale = caster:GetModelScale()
	caster:SetModelScale(1.25)
end

function StoneFormEnd( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),  nil, ability:GetLevelSpecialValueFor("explosion_radius",ability:GetLevel()-1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local damage = caster:GetModifierStackCount("modifier_stone_form_stacks",caster) * GetRuneDamage("ziv_knight_stone_form_damage", caster) * ability:GetLevelSpecialValueFor("damage_amp",ability:GetLevel()-1)

	for k,v in pairs(units) do
		DealDamage(caster, v, damage, DAMAGE_TYPE_PHYSICAL)

		TimedEffect( "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_ground_rocks.vpcf", v, 1.0, 5 )

		local knockbackModifierTable =
	    {
	        should_stun = 1,
	        knockback_duration = 1,
	        duration = 1,
	        knockback_distance = 150,
	        knockback_height = 80,
	        center_x = caster:GetAbsOrigin().x,
	        center_y = caster:GetAbsOrigin().y,
	        center_z = caster:GetAbsOrigin().z
	    }
		v:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )
	end

	TimedEffect( "particles/units/heroes/hero_visage/visage_stone_form.vpcf", caster, 2.0 )

	caster:RemoveModifierByName("modifier_stone_form_stacks")
	caster:RemoveModifierByName("modifier_stone_form")

	UnfreezeAnimation(caster)
	EndAnimation(caster)

	caster:SetModelScale(ability.scale)
end

function OnAttacked( keys )
	local caster = keys.caster
	local ability = keys.ability

	local stacks = caster:GetModifierStackCount("modifier_stone_form_stacks",caster)

	caster:SetModifierStackCount("modifier_stone_form_stacks",caster,stacks+1)

	if stacks >= ability:GetLevelSpecialValueFor("max_targets",ability:GetLevel()-1) + GRMSC("ziv_knight_stone_form_targets", caster) then
		ability:EndChannel(false)
	end
end
function BallLightningTraverse( keys )
	if keys.caster.ball_lightning_is_running ~= nil and keys.caster.ball_lightning_is_running == true then
		keys.ability:RefundManaCost()
		return
	end

	local caster = keys.caster
	local caster_loc = caster:GetAbsOrigin()
	local target = keys.target_points[ 1 ] 
	local ability = keys.ability
	
	local speed = ability:GetLevelSpecialValueFor( "ball_lightning_move_speed", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor( "ball_lightning_aoe", ability:GetLevel() - 1 )
	
	local particle_dummy = "particles/status_fx/status_effect_base.vpcf"
	local loop_sound_name = "Hero_StormSpirit.BallLightning.Loop"
	local modifier_name = "modifier_ball_lightning_buff"
	
	local current_pos = caster_loc
	local intervals_per_second = speed / 100
	local forward_vec = ( target - caster_loc ):Normalized()
	
	caster.ball_lightning_start_pos = caster_loc
	caster.ball_lightning_is_running = true
	
	local distance = 0.0

	caster:AddNoDraw()
		
	local projectileTable =
	{
		EffectName = particle_dummy,
		Ability = ability,
		vSpawnOrigin = caster:GetAbsOrigin(),
		vVelocity = speed * forward_vec,
		fDistance = 99999,
		fStartRadius = radius,
		fEndRadius = radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		bProvidesVision = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	local projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
	
	Timers:CreateTimer( function()
			distance = distance + speed / intervals_per_second

			current_pos = current_pos + forward_vec * ( speed / intervals_per_second )

			FindClearSpaceForUnit( caster, current_pos, false )
			FindClearSpaceForUnit( dummy_unit, current_pos, false )
			
			if ( target - current_pos ):Length2D() <= speed / intervals_per_second then
				caster:RemoveModifierByName( modifier_name )
				StopSoundEvent( loop_sound_name, caster )
				caster.ball_lightning_is_running = false

				caster:RemoveNoDraw()

				caster:SetForwardVector(UnitLookAtPoint( caster, target ))
				caster:Stop()

				return nil
			else
				return 0.03
			end
		end
	)
end

function BallLightningDamage( keys )
	DealDamage(keys.caster, keys.target, keys.caster:GetAverageTrueAttackDamage() / 10, DAMAGE_TYPE_PURE)
end
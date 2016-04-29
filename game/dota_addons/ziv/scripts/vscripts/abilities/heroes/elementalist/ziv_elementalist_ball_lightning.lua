function BallLightningTraverse( keys )
	if keys.caster.ball_lightning_is_running ~= nil and keys.caster.ball_lightning_is_running == true then
		keys.ability:RefundManaCost()
		return
	end

	local caster = keys.caster
	local casterLoc = caster:GetAbsOrigin()
	local target = keys.target_points[ 1 ] 
	local ability = keys.ability
	
	local speed = ability:GetLevelSpecialValueFor( "ball_lightning_move_speed", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor( "ball_lightning_aoe", ability:GetLevel() - 1 )
	
	local particle_dummy = "particles/status_fx/status_effect_base.vpcf"
	local loop_sound_name = "Hero_StormSpirit.BallLightning.Loop"
	local modifierName = "modifier_ball_lightning_buff"
	
	local currentPos = casterLoc
	local intervals_per_second = speed / 100
	local forwardVec = ( target - casterLoc ):Normalized()
	
	caster.ball_lightning_start_pos = casterLoc
	caster.ball_lightning_is_running = true

	caster:AddNoDraw()
	
	local distance = 0.0
		
	local projectileTable =
	{
		EffectName = particle_dummy,
		Ability = ability,
		vSpawnOrigin = caster:GetAbsOrigin(),
		vVelocity = speed * forwardVec,
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

			currentPos = currentPos + forwardVec * ( speed / intervals_per_second )

			FindClearSpaceForUnit( caster, currentPos, false )
			
			if ( target - currentPos ):Length2D() <= speed / intervals_per_second then
				caster:RemoveModifierByName( modifierName )
				StopSoundEvent( loop_sound_name, caster )
				caster.ball_lightning_is_running = false

				caster:RemoveNoDraw()
				return nil
			else
				return 1 / intervals_per_second
			end
		end
	)
end

function BallLightningDamage( keys )
	DealDamage(keys.caster, keys.target, keys.caster:GetAverageTrueAttackDamage() / 10, DAMAGE_TYPE_PURE)
end
function Animation( keys )
	local caster = keys.caster
	local ability = keys.ability

	StartAnimation(caster, {duration=GetRunePercentDecrease(1.0,"ziv_dark_goddess_transform_speed",caster), activity=ACT_DOTA_SPAWN, rate=1.3})

	caster:EmitSound("Hero_DrowRanger.Transform")

	Transform( keys )
end

function Transform( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	StartRuneCooldown(ability,"ziv_dark_goddess_transform_cd",caster)

	local units = caster.child_entities or {}

	for i=#units,1,-1 do
		local v = units[i]
	    
	    if IsValidEntity(v) then
			if v:HasModifier("modifier_glaive_unit") == true or v:HasModifier("modifier_corrupted_spirit") == true then
				TransformPosition( caster, ability, v:GetAbsOrigin() )

				Timers:CreateTimer(function (  )
					caster:EmitSound("Hero_Luna.MoonGlaive.Impact")
					UTIL_Remove(v)
				end)
				return
			else
				table.remove(caster.child_entities, i)
			end
		else
			if v.GetVelocity and v.GetPosition then
				if not v.IsNull and Projectiles.timers[v.ProjectileTimerName] ~= nil then
					TransformPosition( caster, ability, v:GetPosition() )

					Timers:CreateTimer(function (  )
						v:Destroy()
					end)
					return
				end
			else
				table.remove(caster.child_entities, i)
			end
		end
	end

	TransformPosition( caster, ability, caster:GetAbsOrigin() )
end

function TransformPosition( caster, ability, position )
	caster:SetForwardVector(UnitLookAtPoint( caster, position ))
	caster:Stop()

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_dark_goddess_transform",{duration=GetRunePercentDecrease(0.5,"ziv_dark_goddess_transform_speed",caster) })

	Timers:CreateTimer(0.1, function (  )
		if caster:HasModifier("modifier_dark_goddess_transform") then
			FindClearSpaceForUnit(caster,position,false)

			caster:AddNewModifier(caster,nil,"modifier_rooted",{duration = 0.9})

			Timers:CreateTimer(function (  )
				caster:Stop()
				local particle = TimedEffect("particles/units/heroes/hero_drow/drow_silence_wave_ground_pnt.vpcf", caster, 2.0, 3)
				local orientation = caster:GetForwardVector()
				-- ParticleManager:SetParticleControlOrientation(particle,3,orientation,Vector(0,1,0),Vector(1,0,0))
				ParticleManager:SetParticleControlForward(particle,3,orientation)

				TimedEffect("particles/econ/items/drow/drow_bow_monarch/drow_frost_arrow_launch_monarch.vpcf", caster, 2.0, 3, PATTACH_OVERHEAD_FOLLOW)
			end)
		else
			EndAnimation(caster)
		end
	end)
end
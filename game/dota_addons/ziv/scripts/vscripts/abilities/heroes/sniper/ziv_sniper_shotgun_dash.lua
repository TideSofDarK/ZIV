function ShotgunDash(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target_points[1]

    StartRuneCooldown(ability,"ziv_sniper_shotgun_dash_cd",caster)

    local range = GetSpecial(ability,"maximum_range") + GRMSC("ziv_sniper_shotgun_dash_range", caster)
    local speed = GetSpecial(ability,"dash_speed") + GRMSC("ziv_sniper_shotgun_dash_speed", caster)

    if Distance(caster, target) > range then
        local temp_z = target.z
        target = caster:GetAbsOrigin() + ((caster:GetAbsOrigin() - target):Normalized() * -range)
        target.z = temp_z
    end

    ability:ApplyDataDrivenModifier(caster,caster,"modifier_dash_running",{})
    StartAnimation(caster, {duration=-1, activity=ACT_DOTA_RUN, rate=3.0})

    caster:AddNewModifier(caster,ability,"modifier_fade_out_in",{duration = Distance(caster, target) / speed})

    TimedEffect("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", caster, 1.0)

    local start_point = caster:GetAbsOrigin()

    MoveTowards(caster, target, speed, function (  )
        caster:RemoveModifierByName("modifier_dash_running")

        caster:SetForwardVector(UnitLookAtPoint( caster, start_point ))
        caster:Stop()

        local special = caster:FindAbilityByName("ziv_sniper_shotgun_special")
        special:EndCooldown()
        caster:CastAbilityOnPosition(start_point,special,caster:GetPlayerOwnerID())

        Timers:CreateTimer(0.05, function (  )
            TimedEffect("particles/heroes/sniper/sniper_shotgun_dash_endcap.vpcf", caster, 1.0)
        end)

        EndAnimation(caster)
    end, true)
end
function SMGBackup( keys )
    local caster = keys.caster
    local target = keys.target_points[1]
    local ability = keys.ability

    local height = GetSpecial(ability, "spawn_height")
    local radius = GetSpecial(ability, "spawn_radius")
    local offset = GetSpecial(ability, "hero_offset")
    local speed = 700

    StartAnimation(caster, {duration=-1, activity=ACT_DOTA_TELEPORT, rate=1.0})

    local gyro = CreateUnitByNameAsync("npc_smg_backup", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber(), function ( gyro )
        ability:ApplyDataDrivenModifier(caster, gyro, "modifier_gyro", {})

        local start_point = caster:GetAbsOrigin() + ((target - caster:GetAbsOrigin()):Normalized() * -radius)
        local end_point = caster:GetAbsOrigin() + ((target - caster:GetAbsOrigin()):Normalized() * radius * 2) + Vector(0,0,height)
        start_point.z = height

        gyro:SetAbsOrigin(start_point)
        
        gyro:EmitSound("gyrocopter_gyro_laugh_02")

        Attachments:AttachProp(gyro, "attach_homing_missile", "models/heroes/rattletrap/rattletrap_weapon.vmdl")

        StartSoundEvent("Hero_Gyrocopter.IdleLoop",caster)

        local t = 0

        Timers:CreateTimer(1.0, function (  )
            if IsValidEntity(caster) and IsValidEntity(gyro) then
                gyro:EmitSound("Hero_Rattletrap.Hookshot.Fire")
            end
        end)

        MoveTowards(gyro, caster, 700, function (  )
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_smg_backup", {})
            gyro:SetForwardVector(UnitLookAtPoint( gyro, target ))
            StartAnimation(caster, {duration=-1, activity=ACT_DOTA_FLAIL, rate=1.0})

            caster:EmitSound("Hero_Rattletrap.Hookshot.Damage")
            gyro:EmitSound("gyrocopter_gyro_move_29")

            MoveTowards(gyro, target, 700, function (  )
                MoveTowards(gyro, end_point, 700, function (  )
                    StopSoundEvent("Hero_Gyrocopter.IdleLoop",caster)
                    gyro:ForceKill(false)
                end, true)
            end)
            MoveTowards(caster, target, 700, function (  )
                FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),false)

                caster:RemoveModifierByName("modifier_smg_backup")
                EndAnimation(caster)
            end)
        end, true)
    end)
end
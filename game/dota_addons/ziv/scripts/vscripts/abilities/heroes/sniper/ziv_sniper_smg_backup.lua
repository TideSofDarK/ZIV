function SMGBackup( keys )
    local caster = keys.caster
    local target = keys.target_points[1]
    local ability = keys.ability

    local height = GetSpecial(ability, "spawn_height")
    local radius = GetSpecial(ability, "spawn_radius")
    local offset = GetSpecial(ability, "hero_offset")

    local flee_seconds = 14

    local gyro = CreateUnitByNameAsync("npc_smg_backup", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber(), function ( gyro )
        ability:ApplyDataDrivenModifier(caster, gyro, "modifier_gyro", {})

        local start_point = (target - caster:GetAbsOrigin()):Normalized() * -radius * 2
        start_point.z = height

        gyro:SetAbsOrigin(start_point)

        local t = 0

        MoveTowards(gyro, caster, 600, function (  )
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_smg_backup", {})
            gyro:SetForwardVector(UnitLookAtPoint( gyro, target ))
            StartAnimation(caster, {duration=-1, activity=ACT_DOTA_TELEPORT, rate=1.0})
            MoveTowards(gyro, target, 600, function (  )
                gyro:ForceKill(false)
            end)
            MoveTowards(caster, target, 600, function (  )
                FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),false)

                caster:RemoveModifierByName("modifier_smg_backup")
                EndAnimation(caster)
            end)
        end, true)
    end)
end
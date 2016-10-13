function SetupCallback( keys )
    local caster = keys.caster
    local ability = keys.ability

    local chance = (GetSpecial(ability, "snare_chance") / 100) + GRSMC("ziv_huntress_passives_chance", caster)

    ability.rng = ability.rng or PseudoRNG.create( chance )

    caster.OnDamageDealCallbacks = caster.OnDamageDealCallbacks or {}
    table.insert(caster.OnDamageDealCallbacks, function (caster, target, damage)
        ability.rng = ability.rng:Init( chance, true )
        if ability.rng:Next() then
            local projectile_info = {
                EffectName = "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
                Ability = ability,
                Target = target,
                Source = caster,
                bDodgeable = true,
                bProvidesVision = false,
                vSpawnOrigin = caster:GetAbsOrigin(),
                iMoveSpeed = 900,
                iVisionRadius = 0,
                iVisionTeamNumber = caster:GetTeamNumber(),
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
            }
            ProjectileManager:CreateTrackingProjectile( projectile_info )
            caster:EmitSound("Hero_NagaSiren.Ensnare.Cast")
        end
    end)
end
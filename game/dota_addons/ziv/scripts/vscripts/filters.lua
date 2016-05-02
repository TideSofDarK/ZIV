function ZIV:FilterExecuteOrder( filterTable )
    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]

    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]

    local issuerUnit
    if units["0"] then
      issuerUnit = EntIndexToHScript(units["0"])
    end

    -- PrintTable(filterTable)

    return true
end

function ZIV:DamageFilter( filterTable )
    local _attacker = EntIndexToHScript(filterTable["entindex_attacker_const"])
    local _victim = EntIndexToHScript(filterTable["entindex_victim_const"])
    local damage = filterTable["damage"]
    local damage_type = filterTable["damagetype_const"]

    if damage_type ~= DAMAGE_TYPE_PHYSICAL then
        damage_type = DAMAGE_TYPE_PURE
    end

    -- if _victim:IsHero() and _attacker:IsHero() == false then
    --     local damage = (_victim:GetMaxHealth() / 100) * _attacker:GetAverageTrueAttackDamage()
    --     _victim:SetHealth(_victim:GetHealth() - damage)

    --     return false
    -- end

    return true
end
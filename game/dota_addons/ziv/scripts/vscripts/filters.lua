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

    if filterTable.queue > 0 then
        filterTable.queue = 0
    end

    return true
end

function ZIV:DamageFilter( filterTable )
    local attacker = EntIndexToHScript(filterTable["entindex_attacker_const"])
    local victim = EntIndexToHScript(filterTable["entindex_victim_const"])
    local damage = filterTable["damage"]
    local damage_type = filterTable["damagetype_const"]

    if damage_type ~= DAMAGE_TYPE_PHYSICAL then
        damage_type = DAMAGE_TYPE_PURE
    end

    if victim:IsHero() == false and attacker:IsHero() == false then
        if attacker:GetPlayerOwnerID() >= 0 then
            attacker = PlayerResource:GetPlayer(attacker:GetPlayerOwnerID()):GetAssignedHero()
            DealDamage( attacker, victim, damage, damage_type )
        end

        return false
    end

    return true
end
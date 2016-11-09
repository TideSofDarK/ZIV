if Filters == nil then
    _G.Filters = class({})
end

PATHFINDING_RATIO = -20
PATHFINDING_THRESHOLD = 256

function Filters:Init(  )
    GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( Filters, "FilterExecuteOrder" ), self )
    GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( Filters, "DamageFilter" ), self )
end

function Filters:FilterExecuteOrder( filterTable )
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

    if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        local position = Vector(filterTable.position_x, filterTable.position_y, filterTable.position_z)
        issuerUnit:SetForwardVector(UnitLookAtPoint( issuerUnit, position ))
        issuerUnit:Stop()

        local distance = Distance(issuerUnit, position)

        for i=distance,0,PATHFINDING_RATIO do
            local target = issuerUnit:GetAbsOrigin() + (((position - issuerUnit:GetAbsOrigin()):Normalized()) * i)
            target.z = GetGroundHeight(target, issuerUnit)

            local path_length = GridNav:FindPathLength(issuerUnit:GetAbsOrigin(),target)
            local new_distance = Distance(issuerUnit, target)

            if path_length ~= -1 and math.abs(path_length - new_distance) < PATHFINDING_THRESHOLD then
                
                filterTable.position_x = target.x
                filterTable.position_y = target.y
                filterTable.position_z = target.z

                break
            end
        end
    end

    return true
end

function Filters:DamageFilter( filterTable )
    local victim = EntIndexToHScript(filterTable["entindex_victim_const"])

    local attacker
    if not filterTable["entindex_attacker_const"] then
        attacker = victim
        filterTable["entindex_attacker_const"] = filterTable["entindex_victim_const"]
    else
        attacker = EntIndexToHScript(filterTable["entindex_attacker_const"])
    end
    
    local damage = filterTable["damage"]
    local damage_type = filterTable["damagetype_const"]

    if damage_type ~= DAMAGE_TYPE_PHYSICAL then
        damage_type = DAMAGE_TYPE_PURE
    end

    if attacker:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS and victim:IsHero() == false and attacker:IsHero() == false then
        if attacker:GetPlayerOwnerID() >= 0 then
            attacker = PlayerResource:GetPlayer(attacker:GetPlayerOwnerID()):GetAssignedHero()

            local same_team = attacker:GetTeamNumber() == victim:GetTeamNumber()
            Damage:Deal( attacker, victim, damage, damage_type, same_team, same_team )
        end

        return false
    end

    return true
end
if Filters == nil then
    _G.Filters = class({})
end

PATHFINDING_RATIO = -20
PATHFINDING_THRESHOLD = 256

function Filters:Init(  )
    GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( Filters, "FilterExecuteOrder" ), self )
    GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( Filters, "DamageFilter" ), self )
end

function Filters:FilterExecuteOrder( filter_table )
    local units = filter_table["units"]
    local order_type = filter_table["order_type"]
    local issuer = filter_table["issuer_player_id_const"]

    local ability_index = filter_table["entindex_ability"]
    local target_index = filter_table["entindex_target"]

    local issuer_unit
    if units["0"] then
      issuer_unit = EntIndexToHScript(units["0"])
    end

    if filter_table.queue > 0 then
        filter_table.queue = 0
    end

    -- if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
    --     if Controls:AbilityPhaseCheck( issuer_unit ) then
    --         return false
    --     end

    --     local position = Vector(filter_table.position_x, filter_table.position_y, filter_table.position_z)
    --     issuer_unit:SetForwardVector(UnitLookAtPoint( issuer_unit, position ))
    --     issuer_unit:Stop()

    --     local distance = Distance(issuer_unit, position)

    --     for i=distance,0,PATHFINDING_RATIO do
    --         local target = issuer_unit:GetAbsOrigin() + (((position - issuer_unit:GetAbsOrigin()):Normalized()) * i)
    --         target.z = GetGroundHeight(target, issuer_unit)

    --         local path_length = GridNav:FindPathLength(issuer_unit:GetAbsOrigin(),target)
    --         local new_distance = Distance(issuer_unit, target)

    --         if path_length ~= -1 and math.abs(path_length - new_distance) < PATHFINDING_THRESHOLD then
                
    --             filter_table.position_x = target.x
    --             filter_table.position_y = target.y
    --             filter_table.position_z = target.z

    --             break
    --         end
    --     end
    -- end

    return true
end

function Filters:DamageFilter( filter_table )
    local victim = EntIndexToHScript(filter_table["entindex_victim_const"])

    local attacker
    if not filter_table["entindex_attacker_const"] then
        attacker = victim
        filter_table["entindex_attacker_const"] = filter_table["entindex_victim_const"]
    else
        attacker = EntIndexToHScript(filter_table["entindex_attacker_const"])
    end
    
    local damage = filter_table["damage"]
    local damage_type = filter_table["damagetype_const"]
    
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

    -- if victim:HasModifier("modifier_passive_hero") then
        
    -- end

    return true
end
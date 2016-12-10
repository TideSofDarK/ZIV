if Wearables == nil then
    _G.Wearables = class({})
end

Wearables.DEFAULT_WEARABLES = LoadKeyValues("scripts/kv/DefaultWearables.kv")

function Wearables:InitDefaultWearables(unit)
    local t = Wearables.DEFAULT_WEARABLES[unit:GetUnitName()]
    if t then
        for k,v in pairs(t) do
            Wearables:AttachWearable(unit, v, "default_wearables")
        end
    end
end

function Wearables:AttachWearable(unit, modelPath, t)
    local wearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelPath, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})

    wearable:FollowEntity(unit, true)

    unit._wearables = unit._wearables or {}

    if t then
        unit._wearables[t] = unit._wearables[t] or {}
        table.insert(unit._wearables[t], wearable)
    else
        unit._wearables["temporary_wearables"] = unit._wearables["temporary_wearables"] or {}
        table.insert(unit._wearables["temporary_wearables"], wearable)
    end

    return wearable
end

function Wearables:RemoveTemporaryWearables( unit )
    Wearables:RemoveWearablesGroup( unit, "temporary_wearables" )
end

function Wearables:RemoveWearablesGroup( unit, t )
    if not unit._wearables or not unit._wearables[t] then return end

    for k,v in pairs(unit._wearables[t]) do
        if not v:IsNull() then
            v:RemoveSelf()
        end
    end
end

function Wearables:Remove(unit)
    if not unit._wearables then
        return
    end

    for k,v in pairs(unit._wearables) do
        Wearables:RemoveWearablesGroup( unit, k )
    end

    unit.wearables = {}
end

function Wearables:DoToAllWearables( unit, callback )
    if not unit._wearables then
        return
    end

    for group,wearables in pairs(unit._wearables) do
        for k,v in pairs(wearables) do
            if not v:IsNull() then
                callback(v)
            end
        end
    end
end

-- function Wearables:HideDefaultWearables( event )
--   local hero = event.caster
--   local ability = event.ability

--   hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
--     local model = hero:FirstMoveChild()
--     while model ~= nil do
--         if model:GetClassname() == "dota_item_wearable" then
--             model:AddEffects(EF_NODRAW) -- Set model hidden
--             table.insert(hero.hiddenWearables, model)
--         end
--         model = model:NextMovePeer()
--     end
-- end

-- function Wearables:ShowDefaultWearables( event )
--   local hero = event.caster

--   for i,v in pairs(hero.hiddenWearables) do
--     v:RemoveEffects(EF_NODRAW)
--   end
-- end
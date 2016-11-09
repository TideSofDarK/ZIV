if Wearables == nil then
    _G.Wearables = class({})
end

function Wearables:AttachWearable(unit, modelPath)
    local wearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelPath, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})

    wearable:FollowEntity(unit, true)

    unit.wearables = unit.wearables or {}
    table.insert(unit.wearables, wearable)

    return wearable
end

function Wearables:Remove(unit)
    if not unit.wearables or #unit.wearables == 0 then
        return
    end

    for _, part in pairs(unit.wearables) do
        if not part:IsNull() then
            part:RemoveSelf()
        end
    end

    unit.wearables = {}
end
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

    if t then
        unit[t] = unit[t] or {}
        table.insert(unit[t], wearable)
    else
        unit.wearables = unit.wearables or {}
        table.insert(unit.wearables, wearable)
    end

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

function Wearables:HideDefaultWearables( event )
  local hero = event.caster
  local ability = event.ability

  hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function Wearables:ShowDefaultWearables( event )
  local hero = event.caster

  for i,v in pairs(hero.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end
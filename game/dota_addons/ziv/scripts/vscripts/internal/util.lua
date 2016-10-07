function ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function GeneratePlayerArray(default_value)
  pIDs = {}
  for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
    pIDs[#pIDs+1] = default_value
  end
  return pIDs
end

function RandomPointOnMap(offset)
  local offset = offset or 100

  local worldX = math.random(GetWorldMinX() + offset, GetWorldMaxX() - offset)
  local worldY = math.random(GetWorldMinY() + offset, GetWorldMaxY() - offset)

  return Vector(worldX,worldY,0)
end

function DistributeUnits( points, unit_name, count, team, on_kill )
  if #points == 0 then return end
  local random_points = Shuffle(points)

  local units = {}

  local i = 1
  for k,v in pairs(random_points) do
    if i > count then break end 
    local unit = CreateUnitByName(unit_name, v:GetAbsOrigin(), false, nil, nil,team)
    unit.on_kill = on_kill
    table.insert(units, unit)
    i = i + 1
  end

  return units
end

function DoToAllPlayers(action)
  if not action then return end
  for pID = 0, DOTA_MAX_PLAYERS do
    if PlayerResource:IsValidPlayerID(pID) then
      if not PlayerResource:IsBroadcaster(pID) then
        if PlayerResource:GetConnectionState(pID) == DOTA_CONNECTION_STATE_CONNECTED then
          action(PlayerResource:GetPlayer(pID))
        end
      end
    end
  end
end

function DoToAllHeroes(action)
  if not action then return end
  for k,v in pairs(HeroList:GetAllHeroes()) do
    if IsValidEntity(v) == true then
      action(v)
    end
  end
end

function DoToUnitsInRadius( caster, position, radius, target_team, target_type, target_flags, action )
  local units = FindUnitsInRadius(caster:GetTeamNumber(),position,nil,radius,target_team or DOTA_UNIT_TARGET_TEAM_ENEMY, target_type or DOTA_UNIT_TARGET_ALL, target_flags or DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

  for k,v in pairs(units) do
    action(v)
  end
end

function GetRandomElement(list, checker, return_key)
  local new_table = {}

  for k,v in pairs(list) do
    if (checker and checker(v) == false) then

    else
      new_table[k] = v
    end
  end

  local count = GetTableLength(new_table)
  local seed = math.random(1, count)
  local i = 1
  
  for k,v in pairs(new_table) do
    if i == seed then
      if return_key then
        return k
      end
      return v
    end
    i = i + 1
  end
end

function Shuffle(list)
    local indices = {}
    for i = 1, #list do
        indices[#indices+1] = i
    end

    local shuffled = {}
    for i = 1, #list do
        local index = math.random(#indices)

        local value = list[indices[index]]

        table.remove(indices, index)

        shuffled[#shuffled+1] = value
    end

    return shuffled
end

function GetTableKeys(t)
  local keyset={}
  local n=0

  for k,v in pairs(t) do
    n=n+1
    keyset[n]=k
  end

  return keyset
end

function CreateItemPanel( item_container )
  item_container.worldPanel = WorldPanels:CreateWorldPanelForAll(
    {layout = "file://{resources}/layout/custom_game/worldpanels/item.xml",
      entity = item_container:GetEntityIndex(),
      data = { 
        name = item_container:GetContainedItem():GetName(), 
        item_entity = item_container:GetContainedItem():GetEntityIndex() 
      },
      entityHeight = 150,
    })
end

function DestroyEntityBasedOnHealth(killer, target)
  local damageTable = {
    victim = target,
    attacker = killer,
    damage = target:GetMaxHealth(),
    damage_type = DAMAGE_TYPE_PURE,
  }
  ApplyDamage(damageTable)
end

function DebugPrint(...)
  local spew = Convars:GetInt('ziv_spew') or -1
  if spew == -1 and ZIV_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('ziv_spew') or -1
  if spew == -1 and ZIV_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function GetTableLength( t )
  if not t then return nil end
  local length = 0

  for k,v in pairs(t) do
    length = length + 1
  end

  return length
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

function ResetRandomSeed()
  -- Change random seed
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables( event )
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

function ShowWearables( event )
  local hero = event.caster

  for i,v in pairs(hero.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

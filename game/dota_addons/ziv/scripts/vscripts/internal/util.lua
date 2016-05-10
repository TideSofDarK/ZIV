function UnitLookAtPoint( unit, point )
  local dir = (point - unit:GetAbsOrigin()):Normalized()
  dir.z = 0
  return dir
end

function GetRandomElement(list, checker)
  local new_table = {}

  for k,v in pairs(list) do
    if (checker and checker(v) == false) then

    else
      table.insert(new_table, v)
    end
  end

  local count = GetTableLength(new_table)
  local seed = math.random(1, count)
  local i = 1
  -- print("dick", count)
  for k,v in pairs(new_table) do
    if i == seed then
      return v
    end
    i = i + 1
  end
end

function CreateItemPanel( item_container )
  item_container.worldPanel = WorldPanels:CreateWorldPanelForAll(
    {layout = "file://{resources}/layout/custom_game/worldpanels/item.xml",
      entity = item_container:GetEntityIndex(),
      data = { 
        name = item_container:GetContainedItem():GetName(), 
        item_entity = item_container:GetContainedItem():GetEntityIndex() 
      },
      entityHeight = 100,
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

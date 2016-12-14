require("internal/util_debug")
require("internal/util_spawning")
require("internal/util_tables")
require("internal/util_unit")

function GeneratePlayerArray(default_value)
  pIDs = {}
  for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
    pIDs[i] = default_value
  end
  return pIDs
end

function DoToAllPlayers(action)
  if not action then return end
  for pID = 0, DOTA_MAX_PLAYERS do
    if PlayerResource:IsValidPlayerID(pID) then
      if not PlayerResource:IsBroadcaster(pID) then
        if PlayerResource:GetConnectionState(pID) >= 1 then
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

  return units
end

function SetRandomAngle( unit )
  unit:SetAngles(0, math.random(0, 360), 0)
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
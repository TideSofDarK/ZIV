function CDOTA_BaseNPC:AddOnAttackLandedCallback( callback )
  self._OnAttackLandedCallbacks = self._OnAttackLandedCallbacks or {}

  local callback_string = DoUniqueString("callback")

  self._OnAttackLandedCallbacks[callback_string] = callback

  return callback_string
end

function CDOTA_BaseNPC:RemoveOnAttackLandedCallback( callback_string )
  self._OnAttackLandedCallbacks[callback_string] = nil
end

function CDOTA_BaseNPC:AddOnTakeDamageCallback( callback )
  self._OnTakeDamageCallbacks = self._OnTakeDamageCallbacks or {}

  local callback_string = DoUniqueString("callback")

  self._OnTakeDamageCallbacks[callback_string] = callback

  return callback_string
end

function CDOTA_BaseNPC:RemoveOnTakeDamageCallback( callback_string )
  self._OnTakeDamageCallbacks[callback_string] = nil
end

function CDOTA_BaseNPC:AddOnDiedCallback( callback )
  self._OnDiedCallbacks = self._OnDiedCallbacks or {}

  local callback_string = DoUniqueString("callback")

  self._OnDiedCallbacks[callback_string] = callback

  return callback_string
end

function CDOTA_BaseNPC:RemoveOnDiedCallback( callback_string )
  self._OnDiedCallbacks[callback_string] = nil
end

function CDOTA_BaseNPC:RemoveAllOnDiedCallbacks( )
  self._OnDiedCallbacks = {}
end

function CDOTA_BaseNPC:SetBoss( bool )
  self._is_boss = bool
end

function CDOTA_BaseNPC:IsBoss(  )
  return self._is_boss or false
end

function CDOTA_BaseNPC:SetHasLoot( bool )
  self._has_loot = bool
end

function CDOTA_BaseNPC:HasLoot(  )
  return self._has_loot or false
end

function CDOTA_BaseNPC:SetWaitingForRespawn( bool )
  self._waiting_for_respawn = bool
end

function CDOTA_BaseNPC:IsWaitingForRespawn(  )
  return self._waiting_for_respawn or false
end

function CDOTA_BaseNPC:IsInsidePolygon(polygon)
  return IsPointInsidePolygon(self:GetAbsOrigin(), polygon)
end

if not IsClient() then
  function OverrideFunction( baseclass, func_name, func )
    if baseclass[func_name.."Overriden"] then return end

    local OriginalFunction = baseclass[func_name]

    baseclass[func_name] = function(...)
      OriginalFunction(...)

      func(...)
    end

    baseclass[func_name.."Overriden"] = true
  end

  OverrideFunction( CDOTA_BaseNPC, "AddNoDraw", function ( ... )
    local self = ({...})[1]

    Wearables:DoToAllWearables( self, function ( wearable )
      wearable:AddEffects(EF_NODRAW)
    end)
  end)

  OverrideFunction( CDOTA_BaseNPC, "RemoveNoDraw", function ( ... )
    local self = ({...})[1]

    Wearables:DoToAllWearables( self, function ( wearable )
      wearable:RemoveEffects(EF_NODRAW)
    end)
  end)
end
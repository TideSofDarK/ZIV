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

function CDOTA_BaseNPC:IsInsidePolygon(polygon)
  return IsPointInsidePolygon(self:GetAbsOrigin(), polygon)
end
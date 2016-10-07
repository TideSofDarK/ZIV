for k,v in pairs(LoadKeyValues("scripts/npc/npc_items_custom.txt")) do
  if string.match(k,"item_rune_") then
    for modifier_name,modifier_data in pairs(v["FortifyModifiers"]) do
      local str = modifier_name
      _G[str] = class({})
      _G[str].IsHidden = (function ()
        return true
      end)
      LinkLuaModifier(str, "modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    end
  end
end
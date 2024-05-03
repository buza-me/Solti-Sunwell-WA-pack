function Init()
  aura_env.SELF_NAME = UnitName("player")
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_GAS_NOVA"

  function aura_env:GetRaidUnitIDFromName(name)
    for i = 1, GetNumRaidMembers() do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == name then
        return raidUnitID
      end
    end
  end
end

-- CHAT_MSG_ADDON
function Trigger1(allStates, event, prefix, text)
  if prefix ~= aura_env.CHAT_MSG_ADDON_PREFIX then
    return allStates
  end

  local unitName, isDebuffed, isSafe = text:match("(%S+)%s+(%S+)%s+(%S+)")

  if unitName == aura_env.SELF_NAME then
    return allStates
  end

  local unitID = aura_env:GetRaidUnitIDFromName(unitName)

  allStates[unitID] = allStates[unitID] or { progressType = "static" }
  allStates[unitID]["unit"] = unitID
  allStates[unitID]["show"] = isDebuffed == 'true'
  allStates[unitID]["isSafe"] = isSafe == 'true'
  allStates[unitID]["changed"] = true

  return allStates
end

function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_GAS_NOVA"
end

-- CHAT_MSG_ADDON
function Trigger1(allStates, event, prefix, text)
  if prefix ~= aura_env.CHAT_MSG_ADDON_PREFIX then
    return allStates
  end

  local unitName, isDebuffed, isSafe = text:match("(%S+)%s+(%S+)%s+(%S+)")
  local stacks = text:match("%s+(%d+)") -- run separately for safety because older versions of the WA did not have stacks

  local unitID = aura_env.CONTEXT.roster[unitName]

  if not UnitExists(unitID) then
    return false
  end

  local state = allStates[unitID] or { progressType = "static" }

  state.unit = unitID
  state.stacks = stacks
  state.show = isDebuffed == 'true'
  state.isSafe = isSafe == 'true'
  state.changed = true
  state.index = GetTime()

  allStates[unitID] = state

  return allStates
end

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

  if not unitID or not UnitExists(unitID) then
    return false
  end

  local state = allStates[unitID] or { progressType = "static" }

  state.unit = unitID
  state.show = isDebuffed == 'true'
  state.isSafe = isSafe == 'true'
  state.changed = true
  state.stacks = tonumber(stacks or -1)
  state.stacksText = stacks or "unknown"
  state.index = GetTime()

  allStates[unitID] = state

  return allStates
end

local trigger1CustomVariables =
{ stacks = "number", isSafe = "bool", stacksText = "string" }

-- SOLTI_GAS_NOVA_DURATION_TRIGGER
function Trigger2(allStates, event, unitName, duration)
  if not aura_env.CONTEXT.isInitialized then
    return allStates
  end

  return aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithUnitID(
    allStates,
    event,
    unitName,
    duration
  )
end

function TriggerFn(t)
  return t[2]
end

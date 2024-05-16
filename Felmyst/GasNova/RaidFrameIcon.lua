function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_GAS_NOVA"
end

-- GAS_NOVA_RANGE_MESSAGES_UPDATE
function Trigger1(allStates, event, messages)
  if event == "OPTIONS" or not messages then
    return allStates
  end

  for name, message in pairs(messages) do
    -- parse the name from the message because the older versions of the WA included it into the message, and some people still use the older versions
    local unitName, isDebuffed, isSafe = message:match("(%S+)%s+(%S+)%s+(%S+)")
    -- run separately for safety because older versions of the WA did not have stacks
    local stacks = message:match("%s+(%d+)")

    local unitID = aura_env.CONTEXT.roster[unitName]

    if unitID and UnitExists(unitID) then
      local state = allStates[unitID] or { progressType = "static" }

      state.unit = unitID
      state.show = isDebuffed == 'true'
      state.isSafe = isSafe == 'true'
      state.changed = true
      state.stacks = tonumber(stacks or -1)
      state.stacksText = stacks or "unknown"
      state.index = GetTime()

      allStates[unitID] = state
    end
  end

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

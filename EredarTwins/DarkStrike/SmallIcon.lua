function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_DARK_STRIKE_TRIGGER
function Trigger1(allStates, event, unitName, duration, isTargetSelf, stacks)
  if not aura_env.CONTEXT.isInitialized then
    return allStates
  end
  local _, state = aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithSelfTargetCheck(
    allStates,
    event,
    unitName,
    duration,
    isTargetSelf
  )

  if state then
    state.stacks = stacks
  end

  return allStates
end

local trigger1CustomVariables =
{ duration = "number", expirationTime = "number", stacks = "number" }

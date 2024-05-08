function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_CORRUPTING_STRIKE_TRIGGER
function Trigger1(allStates, event, unitName, duration, isTargetSelf)
  return aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithSelfTargetCheck(
    allStates,
    event,
    unitName,
    duration,
    isTargetSelf
  )
end

local trigger1CustomVariables =
{ duration = "number", expirationTime = "number" }

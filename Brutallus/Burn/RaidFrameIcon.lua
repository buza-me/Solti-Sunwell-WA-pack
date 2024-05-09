function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_BURN_TRIGGER
function Trigger1(allStates, event, unitName, duration)
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

local trigger1CustomVariables =
{ duration = "number", expirationTime = "number" }

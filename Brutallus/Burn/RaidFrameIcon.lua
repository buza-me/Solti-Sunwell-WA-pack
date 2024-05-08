local LIB_NAME = "SoltiSunwellPackContext"
LibStub:NewLibrary(LIB_NAME, 1)
aura_env.CONTEXT = LibStub(LIB_NAME)

-- SOLTI_BURN_TRIGGER
function Trigger1(allStates, event, unitName, duration)
  return aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithUnitID(
    allStates,
    event,
    unitName,
    duration
  )
end

local trigger1CustomVariables =
{ duration = "number", expirationTime = "number" }

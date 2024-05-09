function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_BEAM_TRIGGER
function Trigger1(allStates, event, unitName, duration, isTargetSelf)
  if not aura_env.CONTEXT.isInitialized then
    return allStates
  end
  return aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithSelfTargetCheck(
    allStates,
    event,
    unitName,
    duration,
    isTargetSelf
  )
end

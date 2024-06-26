function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

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

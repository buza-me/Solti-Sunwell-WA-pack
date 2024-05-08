function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_ENCAPSULATE_TRIGGER
function Trigger1(allStates, event, unitName, isSelfTarget, isSelfClose, duration, expirationTime)
  local allStates, state = aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithUnitID(
    allStates,
    event,
    unitName,
    duration
  )

  if not state then
    return allStates
  end

  state.expirationTime = expirationTime

  return allStates
end

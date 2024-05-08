function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_ARCANE_BOLT_TRIGGER
function Trigger1(allStates, event, unitName, isSelfTarget, isSelfClose, duration)
  return aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithUnitID(allStates, event, unitName, duration)
end

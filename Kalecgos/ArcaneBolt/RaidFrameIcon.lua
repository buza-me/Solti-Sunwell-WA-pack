function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_ARCANE_BOLT_TRIGGER
function Trigger1(allStates, event, unitName, isSelfTarget, isSelfClose, duration)
  if not aura_env.CONTEXT.isInitialized then
    return allStates
  end

  local _, state = aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithUnitID(
    allStates,
    event,
    unitName,
    duration
  )

  if state then
    state.isSelfTarget = not not isSelfTarget
    state.isSelfClose = not not isSelfClose
  end

  return allStates
end

local trigger1CustomVariables =
{ isSelfTarget = "bool", isSelfClose = "bool" }

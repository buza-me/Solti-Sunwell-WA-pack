function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_ARMAGEDDON_TRIGGER
function Trigger1(allStates, event, unitName, isSelfTarget, isSelfClose, duration)
  if not aura_env.CONTEXT.isInitialized then
    return allStates
  end

  local allStates, state = aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithUnitID(
    allStates,
    event,
    unitName,
    duration
  )

  if not state then
    return allStates
  end

  state.isSelfTarget = not not isSelfTarget
  state.isSelfClose = not not isSelfClose

  return allStates
end

local trigger1CustomVariables =
{ isSelfTarget = "bool", isSelfClose = "bool" }

-- SOLTI_DELAYED_ARMAGEDDON_TRIGGER
function Trigger2(allStates, event, unitName, isSelfTarget, isSelfClose, duration)
  if not aura_env.CONTEXT.isInitialized then
    return allStates
  end

  local allStates, state = aura_env.CONTEXT:GenericTimedTriggerStateUpdaterLogicWithUnitID(
    allStates,
    event,
    unitName,
    duration
  )

  if not state then
    return allStates
  end

  state.isSelfTarget = not not isSelfTarget
  state.isSelfClose = not not isSelfClose

  return allStates
end

local trigger1CustomVariables =
{ isSelfTarget = "bool", isSelfClose = "bool" }

function TriggerFN(t)
  return t[1]
end

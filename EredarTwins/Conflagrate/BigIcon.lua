function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
  aura_env.ICONS = {
    CAST = "Interface\\Icons\\Spell_Fire_FireBolt02",
    DEBUFF = "Interface\\Icons\\Spell_Fire_Immolation"
  }
end

-- SOLTI_CONFLAG_CAST_TRIGGER
function Trigger1(allStates, event, unitName, duration, isTargetSelf)
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
    state.icon = aura_env.ICONS.CAST
  end

  return allStates
end

local trigger1CustomVariables =
{ duration = "number", expirationTime = "number" }

-- SOLTI_CONFLAG_DEBUFF_TRIGGER
function Trigger2(allStates, event, unitName, duration, isTargetSelf)
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
    state.icon = aura_env.ICONS.DEBUFF
  end

  return allStates
end

local trigger1CustomVariables =
{ duration = "number", expirationTime = "number" }


function TriggerFN(t)
  return t[2] or t[1]
end

function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_PYROGENICS_TRIGGER
function Trigger1(allStates, event, duration)
  if not aura_env.CONTEXT.isInitialized then
    return allStates
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.changed = true
  state.show = duration > 0
  state.duration = duration
  state.expirationTime = GetTime() + duration

  allStates[""] = state

  return allStates
end

local trigger1CustomVariables =
{ duration = "number", expirationTime = "number" }

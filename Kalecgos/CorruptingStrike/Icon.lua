function Init()
  aura_env.SELF_NAME = UnitName("player")
end

-- SOLTI_CORRUPTING_STRIKE_TRIGGER
function Trigger1(allStates, event, unitID, duration)
  if event == "OPTIONS" or unitID ~= aura_env.SELF_NAME then
    return false
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.changed = true
  state.show = duration > 0
  state.duration = duration
  state.expirationTime = GetTime() + duration

  allStates[""] = state

  return true
end

function Trigger1CustomVariables()
  return { duration = "number", expirationTime = "number" }
end

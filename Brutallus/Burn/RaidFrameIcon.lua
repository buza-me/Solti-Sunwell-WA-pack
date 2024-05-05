-- SOLTI_BURN_TRIGGER
function Trigger1(allStates, event, unitID, duration)
  if event == "OPTIONS" or not UnitExists(unitID) then
    return false
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.unit = unitID
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

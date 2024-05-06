-- SOLTI_BURN_TRIGGER
function Trigger1(allStates, event, unitName, duration)
  if event == "OPTIONS" or not UnitExists(unitName) then
    return false
  end

  duration = duration or 0

  local state = allStates[unitName] or { autoHide = true, progressType = "timed" }

  state.unit = unitName
  state.changed = true
  state.show = duration > 0
  state.duration = duration
  state.expirationTime = GetTime() + duration
  state.index = GetTime()

  allStates[unitName] = state

  return true
end

function Trigger1CustomVariables()
  return { duration = "number", expirationTime = "number" }
end

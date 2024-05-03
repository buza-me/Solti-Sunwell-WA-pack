-- SOLTI_DOOMFIRE_TRIGGER
function Trigger1(allStates, event, linkedUnitName, duration)
  if event == "OPTIONS" then
    return false
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.show = duration > 0
  state.changed = true
  state.duration = duration
  state.expirationTime = GetTime() + duration

  allStates[""] = state

  return true
end

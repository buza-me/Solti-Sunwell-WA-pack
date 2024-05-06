-- SOLTI_ENCAPSULATE_TRIGGER
function Trigger1(allStates, event, unitID, isSelfTarget, isSelfClose, duration, expirationTime)
  if event == "OPTIONS" or not unitID then
    return false
  end

  duration = duration or 0

  local state = allStates[unitID] or { autoHide = true, progressType = "timed" }

  state.show = duration > 0
  state.unit = unitID
  state.changed = true
  state.duration = duration
  state.expirationTime = expirationTime
  state.index = GetTime()

  allStates[unitID] = state

  return true
end

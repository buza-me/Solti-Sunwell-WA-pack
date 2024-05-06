-- SOLTI_ARCANE_BOLT_TRIGGER
function Trigger1(allStates, event, unitID, isSelfTarget, isSelfClose, duration)
  if event == "OPTIONS" or not unitID then
    return false
  end

  duration = duration or 0

  local state = allStates[unitID] or { autoHide = true, progressType = "timed" }

  state.show = true
  state.unit = unitID
  state.changed = true
  state.duration = duration
  state.expirationTime = GetTime() + duration
  state.index = GetTime()

  allStates[unitID] = state

  return true
end

-- SOLTI_ENCAPSULATE_TRIGGER
function Trigger1(allStates, event, unitID, isSelfTarget, isSelfClose, duration, expirationTime)
  if event == "OPTIONS" then
    return false
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.show = duration > 0
  state.changed = true
  state.duration = duration
  state.expirationTime = expirationTime
  state.isSelfTarget = not not isSelfTarget
  state.isSelfClose = not not isSelfClose

  allStates[""] = state

  return true
end

function Trigger1CustomVariables()
  return { isSelfTarget = "bool", isSelfClose = "bool" }
end

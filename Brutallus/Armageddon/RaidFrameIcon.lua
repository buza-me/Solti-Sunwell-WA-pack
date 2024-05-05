-- SOLTI_ARMAGEDDON_TRIGGER
function Trigger1(allStates, event, unitID, isSelfTarget, isSelfClose, duration)
  if event == "OPTIONS" then
    return false
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.show = duration > 0
  state.unit = unitID
  state.changed = true
  state.duration = duration
  state.expirationTime = GetTime() + duration
  state.isSelfTarget = not not isSelfTarget
  state.isSelfClose = not not isSelfClose

  allStates[""] = state

  return true
end

function Trigger1CustomVariables()
  return { isSelfTarget = "bool", isSelfClose = "bool" }
end

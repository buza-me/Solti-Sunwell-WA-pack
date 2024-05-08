-- SOLTI_ARMAGEDDON_TRIGGER
function Trigger1(allStates, event, unitName, isSelfTarget, isSelfClose, duration)
  if event == "OPTIONS" or (not isSelfTarget and not isSelfClose) then
    return false
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.show = duration > 0
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

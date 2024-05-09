-- SOLTI_ENCAPSULATE_TRIGGER
function Trigger1(allStates, event, unitName, isSelfTarget, isSelfClose, duration, expirationTime)
  if event == "OPTIONS" then
    return false
  end

  duration = duration or 0

  local text = aura_env.config.selfTargetText

  if isSelfClose and not isSelfTarget then
    text = aura_env.config.selfCloseText
  end

  if not isSelfClose and not isSelfTarget then
    text = aura_env.config.selfAwayText
  end

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.message = text
  state.show = duration > 0
  state.changed = true
  state.isSelfTarget = isSelfTarget
  state.isSelfClose = isSelfClose
  state.duration = duration
  state.expirationTime = expirationTime

  allStates[""] = state

  return true
end

local trigger1CustomVariables =
{ isSelfTarget = "bool", isSelfClose = "bool", message = "string" }

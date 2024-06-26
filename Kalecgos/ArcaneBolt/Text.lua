-- SOLTI_ARCANE_BOLT_TRIGGER
function Trigger1(allStates, event, unitName, isSelfTarget, isSelfClose, duration)
  if event == "OPTIONS" or (not isSelfTarget and not isSelfClose) then
    return false
  end

  duration = duration or 0

  local text = aura_env.config.selfTargetText

  if isSelfClose and not isSelfTarget then
    text = aura_env.config.selfCloseText
  end

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.message = text
  state.show = true
  state.changed = true
  state.duration = duration
  state.expirationTime = GetTime() + duration

  allStates[""] = state

  return true
end

local trigger1CustomVariables =
{ message = "string" }

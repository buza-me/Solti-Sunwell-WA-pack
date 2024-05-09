-- SOLTI_DOOMFIRE_TRIGGER
function Trigger1(allStates, event, linkedUnitName, duration)
  if event == "OPTIONS" or not linkedUnitName then
    return false
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  local text = string.format(aura_env.config.text, linkedUnitName)

  state.show = duration > 0
  state.message = text
  state.changed = true
  state.duration = duration
  state.expirationTime = GetTime() + duration

  allStates[""] = state

  return true
end

local trigger1CustomVariables =
{ message = "string" }

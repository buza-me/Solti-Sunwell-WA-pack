-- SOLTI_GAS_NOVA_TRIGGER
function Trigger1(allStates, event, isDebuffed, isSafe)
  if event == "OPTIONS" then
    return false
  end

  local state = allStates[""] or { progressType = "static" }

  local text = aura_env.config.unsafeMessage

  if isSafe then
    text = aura_env.config.safeMessage
  end

  state.name = text
  state.show = not not isDebuffed
  state.changed = true
  state.isSafe = not not isSafe

  allStates[""] = state

  return true
end

local trigger1CustomVariables =
{ isSafe = "bool" }

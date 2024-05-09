-- SOLTI_GAS_NOVA_TRIGGER
function Trigger1(allStates, event, isDebuffed, isSafe, numberOfPlayersNear)
  if event == "OPTIONS" then
    return false
  end

  local state = allStates[""] or { progressType = "static" }

  state.show = not not isDebuffed
  state.changed = true
  state.isSafe = not not isSafe
  state.stacks = numberOfPlayersNear
  state.stacksText = tostring(numberOfPlayersNear)

  allStates[""] = state

  return true
end

local trigger1CustomVariables =
{ isSafe = "bool", stacksText = "string" }

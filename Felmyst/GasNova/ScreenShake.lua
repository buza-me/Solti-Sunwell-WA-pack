-- SOLTI_GAS_NOVA_TRIGGER
function Trigger1(allStates, event, isDebuffed, isSafe)
  if event == "OPTIONS" then
    return false
  end

  local state = allStates[""] or { progressType = "static" }

  state.show = not not isDebuffed
  state.changed = true
  state.isSafe = not not isSafe

  allStates[""] = state

  return true
end

local trigger1CustomVariables =
{ isSafe = "bool" }

function CustomCodeCondition()
  if DBM then
    DBM.AddSpecialWarning("", true, true)
  end
end

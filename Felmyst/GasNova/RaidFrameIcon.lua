function Init()
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_GAS_NOVA"
end

-- CHAT_MSG_ADDON
function Trigger1(allStates, event, prefix, text)
  if prefix ~= aura_env.CHAT_MSG_ADDON_PREFIX then
    return allStates
  end

  local unitName, isDebuffed, isSafe, stacks = text:match("(%S+)%s+(%S+)%s+(%S+)%s+(%d+)")

  local state = allStates[unitName] or { progressType = "static" }

  state.unit = unitName
  state.show = isDebuffed == 'true'
  state.isSafe = isSafe == 'true'
  state.changed = true
  state.stacks = tonumber(stacks)
  state.stacksText = stacks
  state.index = GetTime()

  allStates[unitName] = state

  return allStates
end

function Trigger1CustomVariables()
  return { stacks = "number", stacksText = "string" }
end

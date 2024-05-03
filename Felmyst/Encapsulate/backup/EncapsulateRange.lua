function Init()
  aura_env.TEXT_SAFE = "Safe!"
  aura_env.TEXT_UNSAFE = "Run away!"
end

-- SOLTI_ENCAPSULATE_RANGE_TRIGGER,SOLTI_ENCAPSULATE_RESET_TRIGGER
function Trigger1(allStates, event, isUnsafe, duration, endTime)
  if event == "OPTIONS" then
    return allStates
  end

  allStates[""] = allStates[""] or {
    autoHide = true,
    progressType = "timed",
  }

  if event == "SOLTI_ENCAPSULATE_RESET_TRIGGER" then
    allStates[""]["expirationTime"] = GetTime()
    allStates[""]["isUnsafe"] = false
    allStates[""]["changed"] = true
    allStates[""]["show"] = false

    return allStates
  end

  local text = aura_env.TEXT_SAFE

  if isUnsafe then
    text = aura_env.TEXT_UNSAFE
  end

  allStates[""]["expirationTime"] = endTime
  allStates[""]["duration"] = duration or 0
  allStates[""]["isUnsafe"] = isUnsafe
  allStates[""]["name"] = text
  allStates[""]["changed"] = true
  allStates[""]["show"] = true

  return allStates
end

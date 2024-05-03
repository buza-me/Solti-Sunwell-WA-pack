-- SOLTI_ENCAPSULATE_SELF_TRIGGER,SOLTI_ENCAPSULATE_RESET_TRIGGER
function Trigger1(allStates, event, duration, endTime)
  if event == "OPTIONS" then
    return allStates
  end

  allStates[""] = allStates[""] or {
    autoHide = true,
    progressType = "timed",
  }

  allStates[""]["duration"] = duration or 0

  if event == "SOLTI_ENCAPSULATE_RESET_TRIGGER" then
    allStates[""]["expirationTime"] = GetTime()
    allStates[""]["changed"] = true
    allStates[""]["show"] = false

    return allStates
  end

  allStates[""]["expirationTime"] = endTime
  allStates[""]["changed"] = true
  allStates[""]["show"] = true

  return allStates
end

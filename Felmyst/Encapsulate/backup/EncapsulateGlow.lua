-- SOLTI_ENCAPSULATE_GLOW_TRIGGER,SOLTI_ENCAPSULATE_RESET_TRIGGER
function Trigger1(allStates, event, unitID, duration, endTime)
  if event == "OPTIONS" then
    return allStates
  end

  if event == "SOLTI_ENCAPSULATE_RESET_TRIGGER" then
    for _, state in pairs(allStates) do
      state.expirationTime = GetTime()
      state.show = false;
      state.changed = true;
    end

    return allStates
  end

  allStates[unitID] = allStates[unitID] or {
    autoHide = true,
    progressType = "timed"
  }
  allStates[unitID]["unit"] = unitID
  allStates[unitID]["duration"] = duration or 0
  allStates[unitID]["expirationTime"] = endTime
  allStates[unitID]["changed"] = true
  allStates[unitID]["show"] = true

  return allStates
end

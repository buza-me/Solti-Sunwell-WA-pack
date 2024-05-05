function Init()
  aura_env.TRACKED_SPELL_ID = 45032
  --aura_env.TRACKED_SPELL_ID = 25222 --Renew
  aura_env.TRIGGER_EVENT = "SOLTI_COA_TRIGGER"
  aura_env.DURATION = 30
  aura_env.SELF_NAME = UnitName("player")
end

-- CLEU:SPELL_AURA_APPLIED
function Trigger1(
    event,
    timeStamp,
    subEvent,
    sourceGUID,
    sourceName,
    sourceFlags,
    destGUID,
    destName,
    destFlags,
    spellID,
    spellName,
    spellSchool,
    amount
)
  if event == "OPTIONS" or spellID ~= aura_env.TRACKED_SPELL_ID then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    aura_env.DURATION
  )

  return false
end

--CLEU:SPELL_AURA_REMOVED,CLEU:UNIT_DIED
function Trigger2(
    event,
    timeStamp,
    subEvent,
    sourceGUID,
    sourceName,
    sourceFlags,
    destGUID,
    destName,
    destFlags,
    spellID,
    spellName,
    spellSchool,
    amount
)
  if event == "OPTIONS" or (subEvent == "SPELL_AURA_REMOVED" and spellID ~= aura_env.TRACKED_SPELL_ID) then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    0
  )

  return false
end

-- SOLTI_COA_TRIGGER
function Trigger3(allStates, event, unitID, duration)
  if event == "OPTIONS" or unitID ~= aura_env.SELF_NAME then
    return false
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.changed = true
  state.show = duration > 0
  state.duration = duration
  state.expirationTime = GetTime() + duration

  allStates[""] = state

  return true
end

function Trigger1CustomVariables()
  return { duration = "number", expirationTime = "number" }
end

function Init()
  aura_env.TRACKED_SPELL_NAME = "Doomfire"
end

-- SOLTI_DOOMFIRE_RAID_FRAME_ICONS_TRIGGER
function Trigger1(allStates, event, firstUnitID, secondUnitID, duration)
  if event == "OPTIONS" or (not UnitExists(firstUnitID) and not UnitExists(secondUnitID)) then
    return false
  end

  duration = duration or 0

  if UnitExists(firstUnitID) then
    local now = GetTime()
    local state = allStates[firstUnitID] or { autoHide = true, progressType = "timed" }

    state.unit = firstUnitID
    state.changed = true
    state.show = duration > 0
    state.duration = duration
    state.expirationTime = GetTime() + duration
    state.index = now

    allStates[firstUnitID] = state
  end

  if UnitExists(secondUnitID) then
    local now = GetTime()
    local state = allStates[secondUnitID] or { autoHide = true, progressType = "timed" }

    state.unit = secondUnitID
    state.changed = true
    state.show = duration > 0
    state.duration = duration
    state.expirationTime = GetTime() + duration
    state.index = now

    allStates[secondUnitID] = state
  end

  return true
end

--CLEU:SPELL_AURA_REMOVED,CLEU:UNIT_DIED
function Trigger2(
    allStates,
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
  if event == "OPTIONS" or (subEvent == "SPELL_AURA_REMOVED" and spellName ~= aura_env.TRACKED_SPELL_NAME) then
    return false
  end


  if not UnitExists(destName) then
    return false
  end

  local now = GetTime()
  local state = allStates[destName] or { autoHide = true, progressType = "timed" }

  state.unit = destName
  state.changed = true
  state.show = false
  state.duration = 0
  state.expirationTime = now
  state.index = now

  allStates[destName] = state

  return false
end

function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_NAME = "Doomfire"

  function aura_env:UpdateTriggerUnitState(allStates, name, duration, isReset)
    if not UnitExists(name) then
      return
    end

    local unitID = aura_env.CONTEXT.roster[name]

    if not unitID then
      return
    end

    duration = duration or 0

    local state = allStates[unitID] or { autoHide = true, progressType = "timed" }
    allStates[unitID] = state

    local now = GetTime()
    local expirationTime = now

    if not isReset then
      expirationTime = now + duration
    end

    state.unit = unitID
    state.changed = true
    state.show = duration > 0
    state.duration = duration
    state.expirationTime = expirationTime
    state.index = now
  end
end

-- SOLTI_DOOMFIRE_RAID_FRAME_ICONS_TRIGGER
function Trigger1(allStates, event, firstUnitName, secondUnitName, duration)
  if event == "OPTIONS" then
    return false
  end

  aura_env:UpdateTriggerUnitState(allStates, firstUnitName, duration)
  aura_env:UpdateTriggerUnitState(allStates, secondUnitName, duration)

  return allStates
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

  aura_env:UpdateTriggerUnitState(allStates, destName, 0, true)

  return allStates
end

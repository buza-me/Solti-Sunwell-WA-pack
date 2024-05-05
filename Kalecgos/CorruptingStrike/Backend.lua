function Init()
  aura_env.TRACKED_SPELL_ID = 45029
  --aura_env.TRACKED_SPELL_ID = 25222 --Renew
  aura_env.TRIGGER_EVENT = "SOLTI_CORRUPTING_STRIKE_TRIGGER"
  aura_env.DURATION = 3
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

  if destName == aura_env.SELF_NAME then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
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

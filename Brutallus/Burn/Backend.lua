function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_NAME = "Burn"
  --aura_env.TRACKED_SPELL_NAME = "Renew"
  aura_env.TRIGGER_EVENT = "SOLTI_BURN_TRIGGER"
  aura_env.DURATION = 60
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
  if event == "OPTIONS" or spellName ~= aura_env.TRACKED_SPELL_NAME then
    return false
  end

  if not UnitExists(destName) then
    return false
  end

  local isTargetSelf = aura_env.CONTEXT:IsMyName(destName)

  if isTargetSelf then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    aura_env.DURATION,
    isTargetSelf
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
  if event == "OPTIONS" or (subEvent == "SPELL_AURA_REMOVED" and spellName ~= aura_env.TRACKED_SPELL_NAME) then
    return false
  end

  if not UnitExists(destName) then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    0,
    aura_env.CONTEXT:IsMyName(destName)
  )

  return false
end

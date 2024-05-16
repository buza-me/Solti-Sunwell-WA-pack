function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_NAME = "Curse of Boundless Agony"
  --aura_env.TRACKED_SPELL_NAME = "Renew"
  aura_env.TRIGGER_EVENT = "SOLTI_COA_TRIGGER"
  aura_env.DURATION = 30
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
  local shouldAbort =
      event == "OPTIONS"
      or spellName ~= aura_env.TRACKED_SPELL_NAME
      or not UnitExists(destName)

  if shouldAbort then
    return false
  end

  -- a little trick, isMyName == false will turn off personal "run out" notifications in normal raid difficulty
  local isMyName = false

  if aura_env.CONTEXT:IsHeroic() then
    isMyName = aura_env.CONTEXT:IsMyName(destName)
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    aura_env.DURATION,
    isMyName
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
  local shouldAbort =
      event == "OPTIONS"
      or (subEvent == "SPELL_AURA_REMOVED" and spellName ~= aura_env.TRACKED_SPELL_NAME)
      or not UnitExists(destName)

  if shouldAbort then
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

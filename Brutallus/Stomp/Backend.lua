function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_ID = 45185
  --aura_env.TRACKED_SPELL_ID = 25222 -- Renew test
  aura_env.BUFF_DURATION = 10
  aura_env.TRIGGER_EVENT = "SOLTI_STOMP_TRIGGER"
end

-- CLEU:SPELL_AURA_APPLIED,CLEU:SPELL_AURA_REMOVED
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
      or spellID ~= aura_env.TRACKED_SPELL_ID
      or not UnitExists(destName)

  if shouldAbort then
    return false
  end

  local duration = 0

  if subEvent == "SPELL_AURA_APPLIED" then
    duration = aura_env.BUFF_DURATION
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    duration,
    aura_env.CONTEXT:IsMyName(destName)
  )

  return false
end

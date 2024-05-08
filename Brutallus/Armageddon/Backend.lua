function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_ID = 20478
  --aura_env.TRACKED_SPELL_ID = 25222 -- Renew test
  aura_env.DURATION = 10
  aura_env.TRIGGER_EVENT = "SOLTI_ARMAGEDDON_TRIGGER"
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

  local isSelfTarget = aura_env.CONTEXT:IsMyName(destName)
  local isTargetClose = WeakAuras.CheckRange(destName, 15, "<=")

  if isSelfTarget then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    isSelfTarget,
    isTargetClose,
    aura_env.DURATION
  )

  return false
end

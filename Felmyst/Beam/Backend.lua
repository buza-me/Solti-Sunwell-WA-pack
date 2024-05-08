function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_ID = 45392
  aura_env.DURATION = 10
  aura_env.TRIGGER_EVENT = "SOLTI_BEAM_TRIGGER"
end

-- CLEU:SPELL_SUMMON
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

  local isSourceSelf = aura_env.CONTEXT:IsMyName(destName)

  if isSourceSelf then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
  end

  if aura_env.CONTEXT:IsSelfRaidLead() then
    SendChatMessage(
      string.format(
        aura_env.config.raidWarningMessage,
        aura_env.CONTEXT:GetClassColorName(destName)
      ),
      "RAID_WARNING"
    )

    WeakAuras.ScanEvents(
      aura_env.TRIGGER_EVENT,
      sourceName,
      aura_env.DURATION,
      isSourceSelf
    )
  end

  return false
end

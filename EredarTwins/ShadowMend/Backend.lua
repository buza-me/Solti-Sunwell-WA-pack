function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_ID = 38899
  --aura_env.TRACKED_SPELL_ID = 25213 -- Greater Heal test
  aura_env.TRIGGER_EVENT = "SOLTI_SHADOW_MEND_TRIGGER"
end

-- CLEU:SPELL_HEAL
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

  if shouldAbort then
    return false
  end

  if aura_env.CONTEXT:IsSelfRaidLead() then
    local message = string.format(
      aura_env.config.raidWarningMessage,
      destName
    )

    SendChatMessage(message, "RAID_WARNING")
  end

  return false
end

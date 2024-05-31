function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_ID = 45256
  --aura_env.TRACKED_SPELL_ID = 25222 -- Renew test
  aura_env.BUFF_DURATION = 6
  aura_env.phase = 1
  aura_env.AFFINITY_DEBUFFS = {
    [22442] = true, -- fire affinity
    [9657] = true,  -- shadow affinity
  }
  aura_env.BOSS_PHASE_MESSAGE = "Magic Affinity has been disrupted!"
  aura_env.TRIGGER_EVENT = "SOLTI_CONFOUNDING_BLOW_TRIGGER"
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
      or not UnitExists(destName)
      or (
        spellID ~= aura_env.TRACKED_SPELL_ID
        and not aura_env.AFFINITY_DEBUFFS[spellID]
      )

  if shouldAbort then
    return false
  end

  if subEvent == "SPELL_AURA_APPLIED" and aura_env.AFFINITY_DEBUFFS[spellID] then
    aura_env.phase = 1
    return false
  end

  local duration = 0
  local shouldDisplay =
      subEvent == "SPELL_AURA_APPLIED"
      and (aura_env.phase == 2 or not aura_env.CONTEXT.IsHeroic())

  if shouldDisplay then
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

-- CHAT_MSG_MONSTER_EMOTE,CHAT_MSG_RAID_BOSS_EMOTE
function Trigger2(event, message, sourceName, languageName, channelName, targetName)
  local shouldAbort =
      event == "OPTIONS"
      or message ~= aura_env.BOSS_PHASE_MESSAGE

  if shouldAbort then
    return false
  end

  aura_env.phase = 2

  return false
end

function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.BOSS_MESSAGE_TEMPLATE = "Alythess directs Conflagration at %s."
  aura_env.TRACKED_SPELL_ID = 45342
  --aura_env.TRACKED_SPELL_ID = 25222 -- Renew test
  local _, _, _, _, _, _, TRACKED_SPELL_CASTING_TIME, _, _ = GetSpellInfo(aura_env.TRACKED_SPELL_ID)
  local PROJECTILE_TRAVEL_TIME = 0.5
  aura_env.CAST_DURATION = (TRACKED_SPELL_CASTING_TIME / 1000) + PROJECTILE_TRAVEL_TIME
  aura_env.DEBUFF_DURATION = 10
  aura_env.CAST_TRIGGER_EVENT = "SOLTI_CONFLAG_CAST_TRIGGER"
  aura_env.DEBUFF_TRIGGER_EVENT = "SOLTI_CONFLAG_DEBUFF_TRIGGER"
end

-- CHAT_MSG_MONSTER_EMOTE
function Trigger1(event, message, sourceName, languageName, channelName, targetName)
  local shouldAbort =
      event == "OPTIONS"
      or not UnitExists(targetName)
      or string.format(aura_env.BOSS_MESSAGE_TEMPLATE, targetName) ~= message

  if shouldAbort then
    return false
  end

  local isMyName = aura_env.CONTEXT:IsMyName(targetName)

  if isMyName then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
  end

  WeakAuras.ScanEvents(
    aura_env.CAST_TRIGGER_EVENT,
    targetName,
    aura_env.CAST_DURATION,
    isMyName
  )

  return false
end

-- CLEU:SPELL_AURA_APPLIED,CLEU:SPELL_AURA_REMOVED
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
      or spellID ~= aura_env.TRACKED_SPELL_ID
      or not UnitExists(destName)

  if shouldAbort then
    return false
  end

  local duration = 0

  if subEvent == "SPELL_AURA_APPLIED" then
    duration = aura_env.DEBUFF_DURATION
  end

  WeakAuras.ScanEvents(
    aura_env.DEBUFF_TRIGGER_EVENT,
    destName,
    duration,
    aura_env.CONTEXT:IsMyName(destName)
  )

  return false
end

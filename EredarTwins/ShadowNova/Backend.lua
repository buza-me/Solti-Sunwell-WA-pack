function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.BOSS_MESSAGE_TEMPLATE = "Sacrolash directs Shadow Nova at %s."
  aura_env.TRACKED_SPELL_ID = 45329
  local _, _, _, _, _, _, TRACKED_SPELL_CASTING_TIME, _, _ = GetSpellInfo(aura_env.TRACKED_SPELL_ID)
  local PROJECTILE_TRAVEL_TIME = 0.5
  aura_env.DURATION = (TRACKED_SPELL_CASTING_TIME / 1000) + PROJECTILE_TRAVEL_TIME
  aura_env.TRIGGER_EVENT = "SOLTI_SHADOW_NOVA_TRIGGER"
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
    aura_env.TRIGGER_EVENT,
    targetName,
    aura_env.DURATION,
    isMyName
  )

  return false
end

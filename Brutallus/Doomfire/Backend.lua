function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.BOSS_NAME = "Brutallus"
  aura_env.TRACKED_SPELL_NAME = "Doomfire"
  aura_env.MONSTER_EMOTE_TEMPLATE = "%s is afflicted by Doomfire!"
  aura_env.TRIGGER_EVENT = "SOLTI_DOOMFIRE_TRIGGER"
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_DOOMFIRE_MARK_TRIGGER"
  aura_env.RAID_FRAME_ICONS_TRIGGER_EVENT = "SOLTI_DOOMFIRE_RAID_FRAME_ICONS_TRIGGER"
  aura_env.DURATION = 20
  aura_env.isSelfLinked = false
  aura_env.firstDoomfireTargetName = nil
  aura_env.secondDoomfireTargetName = nil
  aura_env.lastPlayerLinkedWithSelf = nil
end

-- CHAT_MSG_MONSTER_EMOTE
function Trigger1(event, message, sourceName, languageName, channelName, targetName)
  local shouldAbort =
      event == "OPTIONS"
      or sourceName ~= aura_env.BOSS_NAME
      or #message <= #aura_env.MONSTER_EMOTE_TEMPLATE
      or not UnitExists(targetName)

  if shouldAbort then
    return false
  end

  local isDoomfireMessage = message == string.format(aura_env.MONSTER_EMOTE_TEMPLATE, targetName)

  if not isDoomfireMessage then
    return false
  end

  if not aura_env.firstDoomfireTargetName then
    aura_env.firstDoomfireTargetName = targetName
    return false
  end

  local firstTarget = aura_env.firstDoomfireTargetName
  local secondTarget = targetName

  aura_env.firstDoomfireTargetName = nil
  aura_env.lastPlayerLinkedWithSelf = nil

  if aura_env.CONTEXT:IsMyName(firstTarget) then
    WeakAuras.ScanEvents(
      aura_env.TRIGGER_EVENT,
      aura_env.CONTEXT:GetClassColorName(secondTarget),
      aura_env.DURATION
    )
    aura_env.lastPlayerLinkedWithSelf = secondTarget
  end

  if aura_env.CONTEXT:IsMyName(secondTarget) then
    WeakAuras.ScanEvents(
      aura_env.TRIGGER_EVENT,
      aura_env.CONTEXT:GetClassColorName(firstTarget),
      aura_env.DURATION
    )
    aura_env.lastPlayerLinkedWithSelf = firstTarget
  end

  WeakAuras.ScanEvents(
    aura_env.RAID_FRAME_ICONS_TRIGGER_EVENT,
    firstTarget,
    secondTarget,
    aura_env.DURATION
  )

  if not aura_env.CONTEXT:IsSelfRaidLead() then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.MARK_TRIGGER_EVENT,
    firstTarget,
    secondTarget
  )

  local message = string.format(
    aura_env.config.raidWarningMessage,
    aura_env.CONTEXT:GetClassColorName(firstTarget),
    aura_env.CONTEXT:GetClassColorName(secondTarget)
  )

  SendChatMessage(message, "RAID_WARNING")

  return false
end

--CLEU:SPELL_AURA_REMOVED, CLEU:UNIT_DIED
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

  if destName == aura_env.firstDoomfireTargetName then
    aura_env.firstDoomfireTargetName = nil
  end

  if destName ~= aura_env.CONTEXT.SELF_NAME and destName ~= aura_env.lastPlayerLinkedWithSelf then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    "",
    0
  )

  return false
end

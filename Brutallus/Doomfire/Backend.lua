function Init()
  aura_env.BOSS_NAME = "Brutallus"
  aura_env.TRACKED_SPELL_NAME = "Doomfire"
  aura_env.MONSTER_EMOTE_TEMPLATE = " is afflicted by Doomfire!"
  aura_env.TRIGGER_EVENT = "SOLTI_DOOMFIRE_TRIGGER"
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_DOOMFIRE_MARK_TRIGGER"
  aura_env.RAID_FRAME_ICONS_TRIGGER_EVENT = "SOLTI_DOOMFIRE_RAID_FRAME_ICONS_TRIGGER"
  aura_env.DURATION = 20
  aura_env.SELF_NAME = UnitName("player")
  aura_env.isSelfLinked = false
  aura_env.firstDoomfireTargetName = nil
  aura_env.secondDoomfireTargetName = nil

  local CLASS_COLORS = {
    DRUID = "FF7C0A",
    HUNTER = "AAD372",
    MAGE = "3FC7EB",
    PALADIN = "F48CBA",
    PRIEST = "FFFFFF",
    ROGUE = "FFF468",
    SHAMAN = "0070DD",
    WARLOCK = "8788EE",
    WARRIOR = "C69B6D"
  }

  local paintedNamesCache = {}

  function aura_env:IsSelfRaidLead()
    for i = 1, GetNumRaidMembers() do
      local name, rank = GetRaidRosterInfo(i)
      if name == aura_env.SELF_NAME then
        return rank == 2 -- raid lead
      end
    end
  end

  function aura_env:PaintNameByClass(unitName)
    if paintedNamesCache[unitName] then
      return paintedNamesCache[unitName]
    end

    for i = 1, GetNumRaidMembers() do
      local name, _, _, _, _, fileName = GetRaidRosterInfo(i)
      if name == unitName then
        local paintedName = "|cff" .. CLASS_COLORS[fileName] .. unitName .. "|r"
        paintedNamesCache[unitName] = paintedName
        return paintedName
      end
    end
  end
end

-- CHAT_MSG_MONSTER_EMOTE
function Trigger1(event, message, sourceName, languageName, channelName, targetName)
  if event == "OPTIONS" or sourceName ~= aura_env.BOSS_NAME or #message <= #aura_env.MONSTER_EMOTE_TEMPLATE then
    return false
  end

  local isDoomfireMessage =
      string.sub(message, #message - #aura_env.MONSTER_EMOTE_TEMPLATE + 1) == aura_env.MONSTER_EMOTE_TEMPLATE

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

  if firstTarget == aura_env.SELF_NAME then
    WeakAuras.ScanEvents(
      aura_env.TRIGGER_EVENT,
      aura_env:PaintNameByClass(secondTarget),
      aura_env.DURATION
    )
  end

  if secondTarget == aura_env.SELF_NAME then
    WeakAuras.ScanEvents(
      aura_env.TRIGGER_EVENT,
      aura_env:PaintNameByClass(firstTarget),
      aura_env.DURATION
    )
  end

  WeakAuras.ScanEvents(
    aura_env.RAID_FRAME_ICONS_TRIGGER_EVENT,
    firstTarget,
    secondTarget,
    aura_env.DURATION
  )

  if not aura_env:IsSelfRaidLead() then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.MARK_TRIGGER_EVENT,
    firstTarget,
    secondTarget
  )

  local message = string.format(
    aura_env.config.raidWarningMessage,
    aura_env:PaintNameByClass(firstTarget),
    aura_env:PaintNameByClass(secondTarget)
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

  if destName ~= aura_env.SELF_NAME then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    "",
    0
  )

  return false
end

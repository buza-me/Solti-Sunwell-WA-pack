function Init()
  aura_env.TRACKED_SPELL_ID = 45392
  aura_env.SELF_NAME = UnitName("player")

  function aura_env:IsSelfRaidLead()
    for i = 1, GetNumRaidMembers() do
      local name, rank = GetRaidRosterInfo(i)
      if name == aura_env.SELF_NAME then
        return rank == 2 -- raid lead
      end
    end
  end

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

  if destName == aura_env.SELF_NAME then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
  end

  if aura_env:IsSelfRaidLead() then
    SendChatMessage(
      string.format(
        aura_env.config.raidWarningMessage,
        aura_env:PaintNameByClass(destName)
      ),
      "RAID_WARNING"
    )
  end

  return false
end

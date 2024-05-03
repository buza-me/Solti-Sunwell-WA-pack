function Init()
  aura_env.SUNWELL_PACK_SYNC_CHAT_MSG_ADDON_PREFIX = "SOLTI_SUNWELL_PACK_SYNC"
  aura_env.LIB_NAME = "SoltiSunwellPackContext"
  aura_env.SELF_NAME = UnitName("player")

  LibStub:NewLibrary(aura_env.LIB_NAME, 1)

  local Context = LibStub(aura_env.LIB_NAME)

  function Context:UseFallback(arg, fallback)
    if arg == nil then
      arg = fallback
    end

    return arg
  end

  Context.playersWithSunwellPack = Context:UseFallback(Context.playersWithSunwellPack, {})
  Context.playersWithSunwellPack[aura_env.SELF_NAME] = true
  Context.CLASS_COLORS = {
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

  function Context:IsSelfRaidLead()
    for i = 1, GetNumRaidMembers() do
      local name, rank = GetRaidRosterInfo(i)
      if name == aura_env.SELF_NAME then
        return rank == 2 -- raid lead
      end
    end
  end

  function Context:GetRaidUnitIDFromName(name)
    for i = 1, GetNumRaidMembers() do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == name then
        return raidUnitID
      end
    end
  end

  function Context:PaintNameByClass(unitName)
    if self.paintedNamesCache[unitName] then
      return self.paintedNamesCache[unitName]
    end

    for i = 1, GetNumRaidMembers() do
      local name, _, _, _, _, fileName = GetRaidRosterInfo(i)
      if name == unitName then
        local paintedName = "|cff" .. self.CLASS_COLORS[fileName] .. unitName .. "|r"
        self.paintedNamesCache[unitName] = paintedName
        return paintedName
      end
    end
  end
end

-- CHAT_MSG_ADDON
function Trigger1(event, prefix, text)
  if event == "OPTIONS" or prefix ~= aura_env.SUNWELL_PACK_SYNC_CHAT_MSG_ADDON_PREFIX then
    return false
  end

  local Context = LibStub(aura_env.LIB_NAME)

  Context.playersWithSunwellPack[text] = true

  return false
end

-- PLAYER_REGEN_DISABLED
function Trigger2(event)
  if event == "OPTIONS" then
    return false
  end

  local Context = LibStub(aura_env.LIB_NAME)

  Context.playersWithSunwellPack = {}

  SendAddonMessage(
    aura_env.SUNWELL_PACK_SYNC_CHAT_MSG_ADDON_PREFIX,
    aura_env.SELF_NAME,
    "RAID"
  )

  return false
end

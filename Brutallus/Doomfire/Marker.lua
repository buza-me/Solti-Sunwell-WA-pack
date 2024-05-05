function Init()
  aura_env.TRACKED_SPELL_NAME = "Doomfire"
  local SELF_NAME = UnitName("player")

  function aura_env:GetRaidUnitIDFromName(name)
    for i = 1, GetNumRaidMembers() do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == name then
        return raidUnitID
      end
    end
  end

  function aura_env:CanSelfMark()
    for i = 1, GetNumRaidMembers() do
      local name, rank = GetRaidRosterInfo(i)
      if name == SELF_NAME then
        return rank == 2 -- raid lead
      end
    end
  end
end

-- SOLTI_DOOMFIRE_MARK_TRIGGER
function Trigger1(event, firstUnitID, secondUnitID)
  if event == "OPTIONS" or not firstUnitID or not secondUnitID then
    return false
  end

  if not aura_env:CanSelfMark() then
    return false
  end

  SetRaidTarget(firstUnitID, aura_env.config.firstMarkID)
  SetRaidTarget(secondUnitID, aura_env.config.secondMarkID)

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

  if not aura_env:CanSelfMark() then
    return false
  end

  local unitID = aura_env:GetRaidUnitIDFromName(destName)

  if not unitID then
    return false
  end

  local raidTargetIndex = GetRaidTargetIndex(unitID)

  if raidTargetIndex ~= aura_env.config.firstMarkID and raidTargetIndex ~= aura_env.config.secondMarkID then
    return false
  end

  SetRaidTarget(unitID, 0)

  return false
end

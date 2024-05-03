function Init()
  aura_env.TRACKED_SPELL_ID = 45855
  aura_env.nextMarkID = aura_env.config.firstMarkID
  local SELF_NAME = UnitName("player")

  function aura_env:GetRaidUnitIDFromName(name)
    if name == SELF_NAME then
      return "player"
    end
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

-- CLEU:SPELL_AURA_APPLIED
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

  if not aura_env:CanSelfMark() then
    return false
  end

  local unitID = aura_env:GetRaidUnitIDFromName(destName)

  if not unitID then
    return false
  end

  if GetRaidTargetIndex(unitID) ~= aura_env.nextMarkID then
    SetRaidTarget(unitID, aura_env.nextMarkID)
  end

  if aura_env.nextMarkID == aura_env.config.firstMarkID then
    aura_env.nextMarkID = aura_env.config.secondMarkID
  elseif aura_env.nextMarkID == aura_env.config.secondMarkID then
    aura_env.nextMarkID = aura_env.config.thirdMarkID
  else
    aura_env.nextMarkID = aura_env.config.firstMarkID
  end

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
  if event == "OPTIONS" or (subEvent == "SPELL_AURA_REMOVED" and spellID ~= aura_env.TRACKED_SPELL_ID) then
    return false
  end

  if not aura_env:CanSelfMark() then
    return false
  end

  local unitID = aura_env:GetRaidUnitIDFromName(destName)
  local raidTargetIndex = GetRaidTargetIndex(unitID)

  if raidTargetIndex ~= aura_env.config.firstMarkID and raidTargetIndex ~= aura_env.config.secondMarkID and raidTargetIndex ~= aura_env.config.thirdMarkID then
    return false
  end

  SetRaidTarget(unitID, 0)

  return false
end

function Init()
  aura_env.TRACKED_SPELL_ID = 45855
  aura_env.firstMarkPlayer = nil
  aura_env.secondMarkPlayer = nil
  aura_env.thirdMarkPlayer = nil
  local selfName = UnitName("player")

  function aura_env:GetRaidUnitIDFromName(name)
    if name == selfName then
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
      if name == selfName then
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
    aura_env.firstMarkPlayer = nil
    aura_env.secondMarkPlayer = nil
    aura_env.thirdMarkPlayer = nil
    return false
  end

  local unitID = aura_env:GetRaidUnitIDFromName(destName)

  if not unitID then
    return false
  end

  local player

  if not aura_env.firstMarkPlayer then
    aura_env.firstMarkPlayer = { unitID = unitID, name = destName, markID = aura_env.config.firstMarkID }
  elseif not aura_env.secondMarkPlayer then
    aura_env.secondMarkPlayer = { unitID = unitID, name = destName, markID = aura_env.config.secondMarkID }
  elseif not aura_env.thirdMarkPlayer then
    aura_env.thirdMarkPlayer = { unitID = unitID, name = destName, markID = aura_env.config.thirdMarkID }
  end

  if aura_env.firstMarkPlayer and aura_env.firstMarkPlayer.name == destName then
    player = aura_env.firstMarkPlayer
  elseif aura_env.secondMarkPlayer and aura_env.secondMarkPlayer.name == destName then
    player = aura_env.secondMarkPlayer
  elseif aura_env.thirdMarkPlayer and aura_env.thirdMarkPlayer.name == destName then
    player = aura_env.thirdMarkPlayer
  end

  if not player then
    return false
  end

  if GetRaidTargetIndex(player.unitID) ~= player.markID then
    SetRaidTarget(player.unitID, player.markID)
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
  if event == "OPTIONS" then
    return false
  end

  if subEvent == "SPELL_AURA_REMOVED" and spellID ~= aura_env.TRACKED_SPELL_ID then
    return false
  end

  if not aura_env:CanSelfMark() then
    aura_env.firstMarkPlayer = nil
    aura_env.secondMarkPlayer = nil
    aura_env.thirdMarkPlayer = nil
    return false
  end

  local player

  if aura_env.firstMarkPlayer and aura_env.firstMarkPlayer.name == destName then
    player = aura_env.firstMarkPlayer
    aura_env.firstMarkPlayer = nil
  elseif aura_env.secondMarkPlayer and aura_env.secondMarkPlayer.name == destName then
    player = aura_env.secondMarkPlayer
    aura_env.secondMarkPlayer = nil
  elseif aura_env.thirdMarkPlayer and aura_env.thirdMarkPlayer.name == destName then
    player = aura_env.thirdMarkPlayer
    aura_env.thirdMarkPlayer = nil
  end

  if not player then
    return false
  end

  if GetRaidTargetIndex(player.unitID) == player.markID then
    SetRaidTarget(player.unitID, 0)
  end

  return false
end

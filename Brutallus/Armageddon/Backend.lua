function Init()
  aura_env.TRACKED_SPELL_ID = 20478
  --aura_env.TRACKED_SPELL_ID = 25222
  aura_env.DURATION = 10
  aura_env.TRIGGER_EVENT = "SOLTI_ARMAGEDDON_TRIGGER"
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_ARMAGEDDON_MARK_TRIGGER"
  aura_env.SELF_NAME = UnitName("player")

  function aura_env:GetRaidUnitIDFromName(name)
    for i = 1, GetNumRaidMembers() do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == name then
        return raidUnitID
      end
    end
  end
end

-- CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REFRESH
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


  local unitID = aura_env:GetRaidUnitIDFromName(destName)
  local isTargetSelf = destName == aura_env.SELF_NAME
  local isTargetClose = WeakAuras.CheckRange(unitID, 15, "<=")

  if isTargetSelf then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
  end

  WeakAuras.ScanEvents(
    aura_env.MARK_TRIGGER_EVENT,
    unitID,
    aura_env.DURATION
  )

  if not isTargetSelf and not isTargetClose then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    unitID,
    isTargetSelf,
    isTargetClose,
    aura_env.DURATION
  )

  return false
end

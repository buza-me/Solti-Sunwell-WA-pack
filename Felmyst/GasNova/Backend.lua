function Init()
  aura_env.TRACKED_SPELL_ID = 45855
  --aura_env.TRACKED_SPELL_ID = 25222
  aura_env.SELF_NAME = UnitName("player")
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_GAS_NOVA"
  aura_env.TRIGGER_EVENT = "SOLTI_GAS_NOVA_TRIGGER"
  aura_env.isDebuffed = false
  aura_env.isBroadcasting = false
  aura_env.numberOfPlayersNear = 0
  aura_env.lastTriggerExecutionTime = GetTime()

  function aura_env:NotifyUpdateSubscribers(isDebuffed, isSafe, numPlayersNear)
    SendAddonMessage(
      aura_env.CHAT_MSG_ADDON_PREFIX,
      aura_env.SELF_NAME .. " " .. tostring(isDebuffed) .. " " .. tostring(isSafe) .. " " .. tostring(numPlayersNear),
      "RAID"
    )
    WeakAuras.ScanEvents(
      aura_env.TRIGGER_EVENT,
      isDebuffed,
      isSafe,
      aura_env.numberOfPlayersNear
    )
  end
end

-- every frame
function Trigger1()
  local shouldAbort = GetTime() - aura_env.lastTriggerExecutionTime < aura_env.config.throttleThreshold

  if shouldAbort then
    return false
  else
    aura_env.lastTriggerExecutionTime = GetTime();
  end

  if not aura_env.isDebuffed and aura_env.isBroadcasting then
    aura_env.isBroadcasting = false
    aura_env.numberOfPlayersNear = 0
    aura_env:NotifyUpdateSubscribers(false, true, 0)
    return false
  elseif not aura_env.isDebuffed then
    return false
  end


  local numberOfPlayersNear = 0

  for i = 1, GetNumRaidMembers() do
    local raidUnitID = "raid" .. i

    if UnitName(raidUnitID) ~= aura_env.SELF_NAME and WeakAuras.CheckRange(raidUnitID, 15, "<=") then
      numberOfPlayersNear = numberOfPlayersNear + 1
    end
  end

  local isSafe = numberOfPlayersNear == 0

  aura_env.isBroadcasting = true
  aura_env.numberOfPlayersNear = numberOfPlayersNear
  aura_env:NotifyUpdateSubscribers(true, isSafe, aura_env.numberOfPlayersNear)

  return false
end

-- CLEU:SPELL_AURA_APPLIED,CLEU:SPELL_AURA_REMOVED,CLEU:UNIT_DIED
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

  local isSpellAuraEvent = subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REMOVED"

  if isSpellAuraEvent and spellID ~= aura_env.TRACKED_SPELL_ID then
    return false
  end

  if destName ~= aura_env.SELF_NAME then
    return
  end

  local isDebuffed = false

  if subEvent == "SPELL_AURA_APPLIED" then
    isDebuffed = true
  end

  aura_env.isDebuffed = isDebuffed
  aura_env.numberOfPlayersNear = 0

  return false
end

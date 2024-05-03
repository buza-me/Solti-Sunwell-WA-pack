function Init()
  aura_env.TRACKED_SPELL_ID = 45855
  --aura_env.TRACKED_SPELL_ID = 25222
  aura_env.isDebuffed = false
  aura_env.isNotificationActive = false
  aura_env.lastTriggerExecutionTime = GetTime()
  aura_env.SELF_NAME = UnitName("player")
  aura_env.TEXT_DANGER = "Run out!"
  aura_env.TEXT_SAFE = "Safe!"
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_GAS_NOVA"

  function aura_env:NotifyRaid(isDebuffed, isSafe)
    SendAddonMessage(
      aura_env.CHAT_MSG_ADDON_PREFIX,
      aura_env.SELF_NAME .. " " .. tostring(isDebuffed) .. " " .. tostring(isSafe), "RAID"
    )
  end
end

function TriggerFN(t)
  return t[1]
end

-- every frame
function Trigger1(allStates)
  local shouldAbort = GetTime() - aura_env.lastTriggerExecutionTime < aura_env.config.throttleThreshold

  if shouldAbort then
    return allStates
  else
    aura_env.lastTriggerExecutionTime = GetTime();
  end

  allStates[""] = allStates[""] or { progressType = "static" }
  allStates[""]["show"] = false
  allStates[""]["changed"] = true

  if not aura_env.isDebuffed and aura_env.isNotificationActive then
    aura_env:NotifyRaid(false, true)
    aura_env.isNotificationActive = false
    return allStates
  elseif not aura_env.isDebuffed then
    return allStates
  end


  local numberOfPlayersNear = 0

  for i = 1, GetNumRaidMembers() do
    local raidUnitID = "raid" .. i

    if UnitName(raidUnitID) ~= aura_env.SELF_NAME and WeakAuras.CheckRange(raidUnitID, 15, "<=") then
      numberOfPlayersNear = numberOfPlayersNear + 1
    end
  end

  local isSafe = numberOfPlayersNear == 0

  aura_env:NotifyRaid(true, isSafe)
  aura_env.isNotificationActive = true

  allStates[""]["show"] = true
  allStates[""]["stacks"] = numberOfPlayersNear
  allStates[""]["name"] = aura_env.TEXT_DANGER

  if isSafe then
    allStates[""]["name"] = aura_env.TEXT_SAFE
  end

  return allStates
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

  return false
end

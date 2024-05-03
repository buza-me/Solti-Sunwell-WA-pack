-- load only in combat
function Init()
  aura_env.DRAGON_NAME = "Kalecgos"
  aura_env.DEMON_NAME = "Sathrovarr the Corruptor"
  -- aura_env.DRAGON_NAME = "Solti"
  -- aura_env.DEMON_NAME = "Shmoly"
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_KALECGOS_HEALTH"
  aura_env.DRAGON_BAR_UPDATE_EVENT = "SOLTI_WA_KALECGOS_HEALTH__DRAGON_BAR_UPDATE"
  aura_env.DEMON_BAR_UPDATE_EVENT = "SOLTI_WA_KALECGOS_HEALTH__DEMON_BAR_UPDATE"
  aura_env.SELF_NAME = UnitName("player")
  aura_env.SCAN_FREQUENCY_SEC = 1
  aura_env.lastScanTime = GetTime()
  aura_env.lastSyncTime = GetTime()

  aura_env.CompareStrings = function(a, b)
    return a < b
  end

  function aura_env:Notify(event, currentHealth, maxHealth)
    WeakAuras.ScanEvents(
      event,
      currentHealth,
      maxHealth
    )
    SendAddonMessage(
      aura_env.CHAT_MSG_ADDON_PREFIX,
      event .. " " .. currentHealth .. " " .. maxHealth,
      "RAID"
    )
  end
end

-- CHAT_MSG_ADDON
function Trigger1(event, prefix, text)
  local shouldAbort =
      event == "OPTIONS"
      or prefix ~= aura_env.CHAT_MSG_ADDON_PREFIX
      or GetTime() - aura_env.lastSyncTime < aura_env.config.throttleThreshold

  if shouldAbort then
    return false
  else
    aura_env.lastSyncTime = GetTime()
  end

  local updateEvent, currentHealth, maxHealth = text:match("(%S+)%s+(%S+)%s+(%S+)")

  WeakAuras.ScanEvents(updateEvent, currentHealth, maxHealth)

  return false
end

-- every frame
function Trigger2()
  local now = GetTime()

  if now - aura_env.lastScanTime < aura_env.SCAN_FREQUENCY_SEC then
    return false
  else
    aura_env.lastScanTime = now
  end

  local numberOfRaidMembers = GetNumRaidMembers()
  local firstPlayerWithDragonTarget = nil
  local firstPlayerWithDemonTarget = nil
  local raidUnitNames = {}
  local raidUnitIDsByNames = {}
  local playersWithWALib = LibStub("PlayersWithSoltiSunwellWA")
  local playersWithWA = playersWithWALib.names or {}

  playersWithWA[aura_env.SELF_NAME] = true

  for i = 1, numberOfRaidMembers do
    local unitID = "raid" .. i
    local unitName = UnitName(unitID)
    raidUnitIDsByNames[unitName] = unitID
    table.insert(raidUnitNames, unitName)
  end

  table.sort(raidUnitNames, aura_env.CompareStrings)

  for i = 1, #raidUnitNames do
    local raidUnitName = raidUnitNames[i]

    if playersWithWA[raidUnitName] then
      local raidUnitID = raidUnitIDsByNames[raidUnitName]

      local targetID = raidUnitID .. "target"
      local targetName = UnitName(targetID)

      local isTargetDragon = targetName == aura_env.DRAGON_NAME
      local isTargetDemon = targetName == aura_env.DEMON_NAME

      if isTargetDragon and not firstPlayerWithDragonTarget then
        firstPlayerWithDragonTarget = raidUnitName
      end

      if isTargetDemon and not firstPlayerWithDemonTarget then
        firstPlayerWithDemonTarget = raidUnitName
      end
    end
  end

  if firstPlayerWithDragonTarget == aura_env.SELF_NAME then
    aura_env:Notify(
      aura_env.DRAGON_BAR_UPDATE_EVENT,
      UnitHealth("target"),
      UnitHealthMax("target")
    )
  end

  if firstPlayerWithDemonTarget == aura_env.SELF_NAME then
    aura_env:Notify(
      aura_env.DEMON_BAR_UPDATE_EVENT,
      UnitHealth("target"),
      UnitHealthMax("target")
    )
  end

  return false
end

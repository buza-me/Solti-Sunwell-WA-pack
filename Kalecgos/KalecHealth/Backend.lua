-- load only in combat
function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.DRAGON_NAME = "Kalecgos"
  aura_env.DEMON_NAME = "Sathrovarr the Corruptor"
  -- aura_env.DRAGON_NAME = "Solti"
  -- aura_env.DEMON_NAME = "Shmoly"
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_KALECGOS_HEALTH"
  aura_env.DRAGON_BAR_UPDATE_EVENT = "SOLTI_WA_KALECGOS_HEALTH__DRAGON_BAR_UPDATE"
  aura_env.DEMON_BAR_UPDATE_EVENT = "SOLTI_WA_KALECGOS_HEALTH__DEMON_BAR_UPDATE"
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

  local firstPlayerWithDragonTarget = nil
  local firstPlayerWithDemonTarget = nil

  local playersWithSunwellPack = aura_env.CONTEXT.playersWithSunwellPack

  playersWithSunwellPack[aura_env.CONTEXT.SELF_NAME] = true

  local sortedPlayersWithSunwellPack = {}

  for unitName, _ in pairs(playersWithSunwellPack) do
    table.insert(sortedPlayersWithSunwellPack, unitName)
  end

  table.sort(sortedPlayersWithSunwellPack, aura_env.CompareStrings)

  for i = 1, #sortedPlayersWithSunwellPack do
    local raidUnitName = sortedPlayersWithSunwellPack[i]
    local raidUnitID = aura_env.CONTEXT.roster[raidUnitName]

    local raidUnitTargetID = raidUnitID .. "target"
    local raidUnitTargetName = UnitName(raidUnitTargetID)

    local isTargetDragon = raidUnitTargetName == aura_env.DRAGON_NAME
    local isTargetDemon = raidUnitTargetName == aura_env.DEMON_NAME

    if isTargetDragon and not firstPlayerWithDragonTarget then
      firstPlayerWithDragonTarget = raidUnitName
    end

    if isTargetDemon and not firstPlayerWithDemonTarget then
      firstPlayerWithDemonTarget = raidUnitName
    end
  end

  if aura_env.CONTEXT:IsMyName(firstPlayerWithDragonTarget) then
    aura_env:Notify(
      aura_env.DRAGON_BAR_UPDATE_EVENT,
      UnitHealth("target"),
      UnitHealthMax("target")
    )
  end

  if aura_env.CONTEXT:IsMyName(firstPlayerWithDemonTarget) then
    aura_env:Notify(
      aura_env.DEMON_BAR_UPDATE_EVENT,
      UnitHealth("target"),
      UnitHealthMax("target")
    )
  end

  return false
end

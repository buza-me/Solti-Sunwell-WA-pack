-- load only in combat
function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.FIRST_BOSS_NAME = "Grand Warlock Alythess"
  aura_env.SECOND_BOSS_NAME = "Lady Sacrolash"
  -- aura_env.FIRST_BOSS_NAME = "Solti"
  -- aura_env.SECOND_BOSS_NAME = "Shmoly"
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_EREDAR_TWINS_HEALTH"
  aura_env.FIRST_BOSS_BAR_UPDATE_EVENT = "SOLTI_WA_EREDAR_TWINS_HEALTH__FIRST_BOSS_BAR_UPDATE"
  aura_env.SECOND_BOSS_BAR_UPDATE_EVENT = "SOLTI_WA_EREDAR_TWINS_HEALTH__SECOND_BOSS_BAR_UPDATE"
  aura_env.SCAN_FREQUENCY_SEC = 1
  aura_env.lastScanTime = GetTime()
  aura_env.lastSyncTime = GetTime()

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

  local firstPlayerWithFirstBossTarget = nil
  local firstPlayerWithSecondBossTarget = nil

  local sortedNamesOfPlayersWithSunwellPack =
      aura_env.CONTEXT.sortedNamesOfPlayersWithSunwellPack

  for i = 1, #sortedNamesOfPlayersWithSunwellPack do
    local raidUnitName = sortedNamesOfPlayersWithSunwellPack[i]
    local raidUnitID = aura_env.CONTEXT.roster[raidUnitName]

    local raidUnitTargetID = raidUnitID .. "target"
    local raidUnitTargetName = UnitName(raidUnitTargetID)

    local isTargetFirstBoss = raidUnitTargetName == aura_env.FIRST_BOSS_NAME
    local isTargetSecondBoss = raidUnitTargetName == aura_env.SECOND_BOSS_NAME

    if isTargetFirstBoss and not firstPlayerWithFirstBossTarget then
      firstPlayerWithFirstBossTarget = raidUnitName
    end

    if isTargetSecondBoss and not firstPlayerWithSecondBossTarget then
      firstPlayerWithSecondBossTarget = raidUnitName
    end

    if firstPlayerWithFirstBossTarget and firstPlayerWithSecondBossTarget then
      break
    end
  end

  if aura_env.CONTEXT:IsMyName(firstPlayerWithFirstBossTarget) then
    aura_env:Notify(
      aura_env.FIRST_BOSS_BAR_UPDATE_EVENT,
      UnitHealth("target"),
      UnitHealthMax("target")
    )
  end

  if aura_env.CONTEXT:IsMyName(firstPlayerWithSecondBossTarget) then
    aura_env:Notify(
      aura_env.SECOND_BOSS_BAR_UPDATE_EVENT,
      UnitHealth("target"),
      UnitHealthMax("target")
    )
  end

  return false
end

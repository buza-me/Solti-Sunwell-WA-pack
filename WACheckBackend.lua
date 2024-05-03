function Init()
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_SUNWELL_WA_CHECK"
  aura_env.LIB_NAME = "PlayersWithSoltiSunwellWA"
  aura_env.SELF_NAME = UnitName("player")
  aura_env.COMBAT_START_SYNC_DELAY = 3
  aura_env.scheduledSyncTime = nil

  LibStub:NewLibrary(aura_env.LIB_NAME, 1)

  local playersWithWA = LibStub(aura_env.LIB_NAME)

  playersWithWA.names = playersWithWA.names or {}

  playersWithWA.names[aura_env.SELF_NAME] = true
end

-- CHAT_MSG_ADDON
function Trigger1(event, prefix, text)
  if event == "OPTIONS" or prefix ~= aura_env.CHAT_MSG_ADDON_PREFIX then
    return false
  end

  local playersWithWA = LibStub(aura_env.LIB_NAME)

  playersWithWA.names[text] = true

  return false
end

-- PLAYER_REGEN_DISABLED
function Trigger2(event)
  if event == "OPTIONS" then
    return false
  end

  local playersWithWA = LibStub(aura_env.LIB_NAME)

  playersWithWA.names = {}

  aura_env.scheduledSyncTime = GetTime() + aura_env.COMBAT_START_SYNC_DELAY

  return false
end

-- every frame
function Trigger3()
  if not aura_env.scheduledSyncTime or GetTime() < aura_env.scheduledSyncTime then
    return false
  end

  SendAddonMessage(
    aura_env.CHAT_MSG_ADDON_PREFIX,
    aura_env.SELF_NAME,
    "RAID"
  )

  aura_env.scheduledSyncTime = nil

  return false
end

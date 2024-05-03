aura_env.Init = function()
  local KalecgosDBM = DBM:GetMod("Kal")

  if not KalecgosDBM or KalecgosDBM.isAugmentedBySolti then
    return
  else
    KalecgosDBM.isAugmentedBySolti = true
  end

  local HEROIC_DIFFICULTY_ID = 2

  local IsHeroic = function()
    local name, instanceType, difficultyID, difficultyName, maxPlayers = GetInstanceInfo()
    return difficultyID == HEROIC_DIFFICULTY_ID
  end

  local function startsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
  end

  local NO_BROADCAST = not aura_env.config.shouldBroadcast
  local PORTAL_DURATION = 15
  local PORTAL_COOLDOWN = 20
  local lastPortalSpawnTime = 0
  local portalCounter = 0

  local SPELL_IDS = {
    SPECTRAL_REALM = 46021,
  }
  local SYNC_EVENTS = {
    [SPELL_IDS.SPECTRAL_REALM] = "Port"
  }

  local ANNOUNCE_DBM = {
    [SPELL_IDS.SPECTRAL_REALM] = {
      WARN = {
        GERMAN = "Portal #%d bald",
        ENGLISH = "Portal #%d soon",
        RUSSIAN = "скоро Портал #%d",
        CHINESE_SIMPLIFIED = "传送 #%d - 即将施放",
        CHINESE_TRADITIONAL = "第 %s 個傳送門 即將發動"
      },
      STATUS = "Next Portal #"
    },
  }

  local OnSync = KalecgosDBM.OnSync
  function KalecgosDBM:OnSync(msg)
    OnSync(self, msg)

    if not self.Options.UseSoltiMod or not IsHeroic() or not startsWith(msg, SYNC_EVENTS[SPELL_IDS.SPECTRAL_REALM]) then
      return
    end

    if (GetTime() - lastPortalSpawnTime) <= PORTAL_DURATION then
      return
    end

    lastPortalSpawnTime = GetTime()
    portalCounter = portalCounter + 1
    local nextPortalNumber = portalCounter + 1
    local statusBarUpdateID = ANNOUNCE_DBM[SPELL_IDS.SPECTRAL_REALM].STATUS .. nextPortalNumber
    local englishAnnounceID = ANNOUNCE_DBM[SPELL_IDS.SPECTRAL_REALM].WARN.ENGLISH:format(nextPortalNumber)

    self:UnScheduleAnnounce(
      englishAnnounceID,
      NO_BROADCAST
    )
    self:UnScheduleAnnounce(
      ANNOUNCE_DBM[SPELL_IDS.SPECTRAL_REALM].WARN.GERMAN:format(nextPortalNumber),
      NO_BROADCAST
    )
    self:UnScheduleAnnounce(
      ANNOUNCE_DBM[SPELL_IDS.SPECTRAL_REALM].WARN.RUSSIAN:format(nextPortalNumber),
      NO_BROADCAST
    )
    self:UnScheduleAnnounce(
      ANNOUNCE_DBM[SPELL_IDS.SPECTRAL_REALM].WARN.CHINESE_SIMPLIFIED:format(nextPortalNumber),
      NO_BROADCAST
    )
    self:UnScheduleAnnounce(
      ANNOUNCE_DBM[SPELL_IDS.SPECTRAL_REALM].WARN.CHINESE_TRADITIONAL:format(nextPortalNumber),
      NO_BROADCAST
    )
    self:EndStatusBarTimer(statusBarUpdateID, NO_BROADCAST)

    if self.Options.PreWarnPort then
      self:ScheduleAnnounce(
        PORTAL_COOLDOWN - 3,
        englishAnnounceID,
        1,
        NO_BROADCAST
      )
    end
    self:StartStatusBarTimer(
      PORTAL_COOLDOWN,
      statusBarUpdateID,
      "Interface\\Icons\\Spell_Arcane_PortalUnderCity"
    )
  end
end

aura_env.Init = function()
  local BrutallusDBM = DBM:GetMod("Brutallus")

  if not BrutallusDBM or BrutallusDBM.isAugmentedBySolti then
    return
  else
    BrutallusDBM.isAugmentedBySolti = true
  end

  local HEROIC_DIFFICULTY_ID = 2

  local IsHeroic = function()
    local name, instanceType, difficultyID, difficultyName, maxPlayers = GetInstanceInfo()
    return difficultyID == 2
  end

  local function startsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
  end

  local function omitPrefix(str, prefix)
    return string.sub(str, #prefix + 1)
  end

  local lastDoomfireSync = 0
  local DOOMFIRE_SYNC_THROTTLE = 1
  local SPELL_IDS = {
    BURN = 46394,
    STOMP = 45185,
    METEOR_SLASH = 45150,
    ARMAGEDDON = 20478,
    DOOMFIRE = 31944
  }
  local SYNC_EVENTS = {
    -- [SPELL_IDS.BURN] = "Burn",
    -- [SPELL_IDS.STOMP] = "Stomp",
    -- [SPELL_IDS.METEOR_SLASH] = "Meteor Slash",
    [SPELL_IDS.ARMAGEDDON] = "Armageddon",
    [SPELL_IDS.DOOMFIRE] = "Doomfire"
  }

  local ANNOUNCE = {
    [SPELL_IDS.BURN] = "Next Burn",
    -- [SPELL_IDS.STOMP] = "Next Stomp",
    -- [SPELL_IDS.METEOR_SLASH] = "Next Meteor Slash",
    [SPELL_IDS.ARMAGEDDON] = "Next Armageddon",
    [SPELL_IDS.DOOMFIRE] = "Next Doomfire"
  }

  local ANNOUNCE_TARGET = {
    [SPELL_IDS.ARMAGEDDON] = "Armageddon builds on "
  }

  local OnCombatStart = BrutallusDBM.OnCombatStart
  function BrutallusDBM:OnCombatStart(delay)
    OnCombatStart(self, delay)

    if not IsHeroic() then
      return
    end

    self:StartStatusBarTimer(20 - delay, ANNOUNCE[SPELL_IDS.BURN], SPELL_IDS.BURN)
    self:StartStatusBarTimer(20 - delay, ANNOUNCE[SPELL_IDS.DOOMFIRE], SPELL_IDS.DOOMFIRE)
    self:StartStatusBarTimer(40 - delay, ANNOUNCE[SPELL_IDS.ARMAGEDDON], SPELL_IDS.ARMAGEDDON)
  end

  local OnEvent = BrutallusDBM.OnEvent
  function BrutallusDBM:OnEvent(event, args)
    OnEvent(self, event, args)

    if not IsHeroic() then
      return
    end

    local syncEvent = SYNC_EVENTS[args.spellId]

    if not syncEvent or event ~= "SPELL_AURA_APPLIED" then
      return
    end

    self:SendSync(syncEvent .. tostring(args.destName))
  end

  local OnSync = BrutallusDBM.OnSync
  function BrutallusDBM:OnSync(msg)
    OnSync(self, msg)

    if not IsHeroic() then
      return
    end

    if startsWith(msg, SYNC_EVENTS[SPELL_IDS.ARMAGEDDON]) then
      local name = omitPrefix(msg, SYNC_EVENTS[SPELL_IDS.ARMAGEDDON])
      self:Announce(ANNOUNCE_TARGET[SPELL_IDS.ARMAGEDDON] .. name, 1)
      self:StartStatusBarTimer(10, ANNOUNCE_TARGET[SPELL_IDS.ARMAGEDDON] .. name, SPELL_IDS.ARMAGEDDON)
      self:StartStatusBarTimer(40, ANNOUNCE[SPELL_IDS.ARMAGEDDON], SPELL_IDS.ARMAGEDDON)
    elseif startsWith(msg, SYNC_EVENTS[SPELL_IDS.DOOMFIRE]) and GetTime() - lastDoomfireSync > DOOMFIRE_SYNC_THROTTLE then
      lastDoomfireSync = GetTime()
      self:StartStatusBarTimer(40, ANNOUNCE[SPELL_IDS.DOOMFIRE], SPELL_IDS.DOOMFIRE)
    end
  end
end

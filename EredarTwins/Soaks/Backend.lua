function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.FIRST_BOSS_NAME = "Grand Warlock Alythess"
  aura_env.SECOND_BOSS_NAME = "Lady Sacrolash"
  aura_env.BOSS_PHASE_MESSAGE = "Magic Affinity has been disrupted!"
  aura_env.PHASE_TWO_SOAK_MESSAGE = "The twins begin to unleash powerful spells!"
  aura_env.PHASE_ONE_SOAK_MESSAGES = {
    ["%s begins to cast Blast Nova!"] = true,
    ["%s begins to summon Shadow Clones!"] = true,
  }
  aura_env.TRIGGER_EVENT = "SOLTI_SUNWELL_TWINS_SOAK_TRIGGER"
  aura_env.SELF_TRIGGER_EVENT = "SOLTI_SUNWELL_TWINS_SOAK_TRIGGER_SELF"
  aura_env.phase = 1
  aura_env.totalSoakNumber = 1
  aura_env.secondPhaseSoakNumber = 1
  aura_env.lastAppliedDebuffUpdateTime = GetTime()
  aura_env.lastRemovedDebuffUpdateTime = GetTime()
  aura_env.DEBUFF_UPDATE_COOLDOWN = 0.5
  aura_env.nextSoakTimerDuration = nil
  aura_env.nextSoakExpirationTime = nil
  aura_env.isInBossFight = false
  aura_env.debuffedPlayers = {}
  aura_env.currentSoakers = {}
  aura_env.DEBUFFS = {
    [22442] = "fire affinity",
    [9657] = "shadow affinity",
    ["fire affinity"] = 22442,
    ["shadow affinity"] = 9657,
    [38637] = "fire soak",
    [38639] = "shadow soak",
    ["fire soak"] = 38637,
    ["shadow soak"] = 38639,
  }
  aura_env.DURATIONS = {
    ["fire affinity"] = 75,
    ["shadow affinity"] = 75,
    ["fire soak"] = 90,
    ["shadow soak"] = 90,
  }
  aura_env.CIRCLE_TIMERS = {
    SHORT = 14,
    MEDIUM = 25, -- after cast ends
    LONG = 40,   -- after cast ends
  }
  aura_env.CIRCLE_CAST_TIME = 5

  function aura_env:FilterSoakers(
      soakZoneCount,
      assignmentsTable,
      updateTable,
      affinity,
      soakDebuff,
      ownAssignment,
      typeIndex,
      soakersList
  )
    for zone = 1, soakZoneCount do
      updateTable[zone] = {}

      for playerIndex = 1, #assignmentsTable[zone] do
        local playerName                 = assignmentsTable[zone][playerIndex]
        local playerDebuffs              = self.debuffedPlayers[playerName] or {}
        self.debuffedPlayers[playerName] = playerDebuffs
        local affinityDebuffEndTime      = self.debuffedPlayers[playerName][self.DEBUFFS[affinity]] or 0
        local soakDebuffEndTime          = self.debuffedPlayers[playerName][self.DEBUFFS[soakDebuff]] or 0

        if affinityDebuffEndTime <= GetTime() then
          self.debuffedPlayers[playerName][self.DEBUFFS[affinity]] = nil
        end
        if soakDebuffEndTime <= GetTime() then
          self.debuffedPlayers[playerName][self.DEBUFFS[soakDebuff]] = nil
        end

        local isUnableToSoak =
            not UnitExists(playerName)
            or UnitIsDeadOrGhost(playerName)
            or not UnitIsConnected(playerName)
            or soakersList[playerName]
            or self.debuffedPlayers[playerName][self.DEBUFFS[affinity]]
            or self.debuffedPlayers[playerName][self.DEBUFFS[soakDebuff]]

        if not isUnableToSoak then
          table.insert(updateTable[zone], playerName)
          soakersList[playerName] = true

          if updateTable[zone][1] == playerName and self.CONTEXT:IsMyName(playerName) then
            ownAssignment.type = typeIndex
            ownAssignment.zone = zone
          end
        end
      end
    end
  end

  function aura_env:UpdateSoakers()
    if not self.CONTEXT.isInitialized then
      return
    end

    local state = self.CONTEXT.states.twins

    if not state then
      return
    end

    local currentPhase = state.assignments[self.phase]
    local soakTypes = 2
    local soakZones = 5
    local backupZone = soakZones + 1
    local types = { fire = 1, shadow = 2 }
    local soakersUpdate = { {}, {} }
    local ownAssignments = {}
    local soakersList = {}

    self:FilterSoakers(
      soakZones + 1,
      currentPhase[types.fire],
      soakersUpdate[types.fire],
      "shadow affinity",
      "fire soak",
      ownAssignments,
      types.fire,
      soakersList
    )
    self:FilterSoakers(
      soakZones + 1,
      currentPhase[types.shadow],
      soakersUpdate[types.shadow],
      "fire affinity",
      "shadow soak",
      ownAssignments,
      types.shadow,
      soakersList
    )

    for soakType = 1, soakTypes do
      for soakZone = 1, soakZones do
        if #soakersUpdate[soakType][soakZone] == 0 and #soakersUpdate[soakType][backupZone] ~= 0 then
          table.insert(soakersUpdate[soakType][soakZone], soakersUpdate[soakType][backupZone][1])
          table.remove(soakersUpdate[soakType][backupZone], 1)
        end
      end
    end

    self.currentSoakers = soakersUpdate

    WeakAuras.ScanEvents(
      self.TRIGGER_EVENT,
      self.currentSoakers,
      self.phase,
      self.totalSoakNumber,
      self.secondPhaseSoakNumber,
      self.nextSoakTimerDuration,
      self.nextSoakExpirationTime
    )

    if ownAssignments.type and ownAssignments.zone then
      WeakAuras.ScanEvents(
        self.SELF_TRIGGER_EVENT,
        ownAssignments.type,
        ownAssignments.zone,
        self.phase,
        self.totalSoakNumber,
        self.secondPhaseSoakNumber,
        self.nextSoakTimerDuration,
        self.nextSoakExpirationTime
      )
    end
  end

  function aura_env:IsBossInCombat()
    for unitID in WA_IterateGroupMembers() do
      local targetID = unitID .. "target"
      local targetName = UnitName(targetID)
      if targetName == self.FIRST_BOSS_NAME or targetName == self.SECOND_BOSS_NAME then
        return UnitAffectingCombat(targetID)
      end
    end

    return nil
  end

  function aura_env:SetTimerValues(timer)
    self.nextSoakTimerDuration = timer
    self.nextSoakExpirationTime = GetTime() + timer
  end

  function aura_env:OnAuraApplied(spellID)
    if GetTime() - self.lastAppliedDebuffUpdateTime < self.DEBUFF_UPDATE_COOLDOWN then
      return
    end

    if not self:IsBossInCombat() then
      self:Reset()
      return
    end

    if spellID == self.DEBUFFS["fire affinity"] or spellID == self.DEBUFFS["shadow affinity"] then
      self.phase = 1
      self:SetTimerValues(self.CIRCLE_TIMERS.SHORT)
    end

    self:UpdateSoakers()
  end

  function aura_env:OnAuraRemoved()
    if GetTime() - self.lastRemovedDebuffUpdateTime < self.DEBUFF_UPDATE_COOLDOWN then
      return
    end

    if not self:IsBossInCombat() then
      self:Reset()
      return
    end

    self:UpdateSoakers()
  end

  function aura_env:StartTimerOnCircleCastEnd(timer)
    local env = aura_env
    env.CONTEXT:SetTimeout(
      function()
        if not env:IsBossInCombat() then
          env:Reset()
          return
        end
        env:SetTimerValues(timer)
        env:UpdateSoakers()
      end,
      env.CIRCLE_CAST_TIME
    )
  end

  function aura_env:Reset()
    self.phase                  = 1
    self.totalSoakNumber        = 1
    self.secondPhaseSoakNumber  = 1
    self.isInBossFight          = false
    self.debuffedPlayers        = {}
    self.nextSoakTimerDuration  = nil
    self.nextSoakExpirationTime = nil
  end
end

-- CHAT_MSG_MONSTER_EMOTE,CHAT_MSG_RAID_BOSS_EMOTE
function Trigger1(event, message, sourceName, languageName, channelName, targetName)
  local shouldAbort =
      event == "OPTIONS"
      or (
        message ~= aura_env.BOSS_PHASE_MESSAGE
        and message ~= aura_env.PHASE_TWO_SOAK_MESSAGE
        and not aura_env.PHASE_ONE_SOAK_MESSAGES[message]
      )

  if shouldAbort then
    return false
  end

  if message == aura_env.BOSS_PHASE_MESSAGE then
    aura_env.phase = 2
    aura_env:SetTimerValues(aura_env.CIRCLE_TIMERS.SHORT)
    aura_env:UpdateSoakers()
  end

  if message == aura_env.PHASE_TWO_SOAK_MESSAGE then
    aura_env.secondPhaseSoakNumber = aura_env.secondPhaseSoakNumber + 1
    aura_env.totalSoakNumber = aura_env.totalSoakNumber + 1

    if aura_env.secondPhaseSoakNumber % 2 == 0 then
      aura_env:StartTimerOnCircleCastEnd(aura_env.CIRCLE_TIMERS.MEDIUM)
    else
      aura_env:StartTimerOnCircleCastEnd(aura_env.CIRCLE_TIMERS.LONG)
    end
  end

  if aura_env.PHASE_ONE_SOAK_MESSAGES[message] then
    aura_env.totalSoakNumber = aura_env.totalSoakNumber + 1

    if aura_env.totalSoakNumber % 2 == 0 then
      aura_env:StartTimerOnCircleCastEnd(aura_env.CIRCLE_TIMERS.MEDIUM)
    end
  end

  aura_env:UpdateSoakers()

  return false
end

-- CLEU:SPELL_AURA_APPLIED,CLEU:SPELL_AURA_REMOVED
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
  local shouldAbort =
      event == "OPTIONS"
      or not UnitExists(destName)
      or (
        spellID ~= aura_env.DEBUFFS["fire affinity"]
        and spellID ~= aura_env.DEBUFFS["shadow affinity"]
        and spellID ~= aura_env.DEBUFFS["fire soak"]
        and spellID ~= aura_env.DEBUFFS["shadow soak"]
      )

  if shouldAbort then
    return false
  end

  local now = GetTime()

  aura_env.debuffedPlayers[destName] = aura_env.debuffedPlayers[destName] or {}

  if subEvent == "SPELL_AURA_REMOVED" then
    aura_env.debuffedPlayers[destName][spellID] = nil
    aura_env:OnAuraRemoved()
  else
    aura_env.debuffedPlayers[destName][spellID] = now + aura_env.DURATIONS[aura_env.DEBUFFS[spellID]]
    aura_env:OnAuraApplied(spellID)
  end

  return false
end

-- PLAYER_TARGET_CHANGED,PLAYER_ALIVE,PLAYER_UNGHOST,PLAYER_REGEN_ENABLED
function Trigger3(event)
  if event == "OPTIONS" or (event == "PLAYER_TARGET_CHANGED" and UnitAffectingCombat("player")) then
    return false
  end

  local env = aura_env

  env.CONTEXT:SetTimeout(
    function()
      if not env:IsBossInCombat() then
        env:Reset()
        env:UpdateSoakers()
      end
    end,
    1
  )

  return false
end

-- PLAYER_REGEN_DISABLED
function Trigger4(event)
  if event == "OPTIONS" then
    return false
  end

  local env = aura_env

  env.CONTEXT:SetTimeout(
    function()
      if env:IsBossInCombat() and not env.isInBossFight then
        env:Reset()
        env.isInBossFight = true
        env:UpdateSoakers()
      end
    end,
    1
  )

  return false
end

-- CLEU:UNIT_DIED
function Trigger5(
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
  if event == "OPTIONS" or not UnitExists(destName) then
    return false
  end

  aura_env:UpdateSoakers()
end

-- SOLTI_SUNWELL_TWINS_ASSIGNMENTS_UPDATE
function Trigger6(event)
  if event == "OPTIONS" then
    return false
  end

  aura_env:UpdateSoakers()
end

function Init()
  aura_env.THREAT_ADDON = LibStub("Threat-2.0")
  aura_env.BOSS_NAME = "Felmyst"
  aura_env.AIR_PHASE_DURATION = 99
  aura_env.TRACKED_SPELL_ID = 45665
  aura_env.ENCAPSULATE_CAST_DURATION = 1.2
  aura_env.ENCAPSULATE_DEBUFF_DURATION = 6
  aura_env.ENCAPSULATE_TOTAL_DURATION =
      aura_env.ENCAPSULATE_CAST_DURATION +
      aura_env.ENCAPSULATE_DEBUFF_DURATION
  aura_env.AIR_PHASE_EMOTE = "I am stronger than ever before!"
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_MARK_TRIGGER"
  aura_env.ENCAPSULATE_SELF_TRIGGER_EVENT = "SOLTI_ENCAPSULATE_SELF_TRIGGER"
  aura_env.ENCAPSULATE_RANGE_TRIGGER_EVENT = "SOLTI_ENCAPSULATE_RANGE_TRIGGER"
  aura_env.ENCAPSULATE_GLOW_TRIGGER_EVENT = "SOLTI_ENCAPSULATE_GLOW_TRIGGER"
  aura_env.ENCAPSULATE_RESET_TRIGGER_EVENT = "SOLTI_ENCAPSULATE_RESET_TRIGGER"
  aura_env.SELF_NAME = UnitName("player")
  aura_env.currentBossTargetUnitName = nil
  aura_env.currentBossTargetUnitID = nil
  aura_env.previousBossTargetUnitName = nil
  aura_env.previousBossTargetUnitID = nil
  aura_env.encapsulateEndTime = nil
  aura_env.encapsulateDuration = nil
  aura_env.encapsulatedUnitID = nil
  aura_env.encapsulatedUnitName = nil
  aura_env.airPhaseEndTime = GetTime()
  aura_env.lastTriggerExecutionTime = GetTime()

  function aura_env:GetBossTargetAndGUID()
    local numberOfRaidMembers = GetNumRaidMembers()

    for i = 1, numberOfRaidMembers do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == aura_env.SELF_NAME then
        raidUnitID = "player"
      end

      local raidUnitTargetName = UnitName(raidUnitID .. "target")

      if raidUnitTargetName == aura_env.BOSS_NAME then
        local bossGUID = UnitGUID(raidUnitID .. "target")

        for j = 1, numberOfRaidMembers do
          local name = GetRaidRosterInfo(j)
          if name == UnitName(raidUnitID .. "targettarget") then
            return "raid" .. j, name, bossGUID
          end
        end

        return nil, nil
      end
    end
  end

  function aura_env:GetRaidUnitID(playerName)
    for i = 1, GetNumRaidMembers() do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == playerName then
        return raidUnitID
      end
    end
    return nil
  end

  function aura_env:IsUnitTankingTheBoss(unitGUID, bossGUID)
    local maxThreat, tankingUnitGUID = aura_env.THREAT_ADDON:GetMaxThreatOnTarget(bossGUID)

    if not maxThreat or maxThreat == 0 or not tankingUnitGUID then
      return true
    end

    return unitGUID == tankingUnitGUID
  end

  function aura_env:Mark(unitID)
    WeakAuras.ScanEvents(
      aura_env.MARK_TRIGGER_EVENT,
      unitID,
      aura_env.config.markID,
      aura_env.encapsulateDuration or aura_env.ENCAPSULATE_TOTAL_DURATION,
      aura_env.config.withMark,
      false
    )
  end

  function aura_env:IsSelfEncapsulated()
    return aura_env.encapsulatedUnitName == aura_env.SELF_NAME
  end

  function aura_env:RegisterAirPhase()
    aura_env.airPhaseEndTime = GetTime() + aura_env.AIR_PHASE_DURATION
  end

  function aura_env:NotifyResetTriggers()
    WeakAuras.ScanEvents(aura_env.ENCAPSULATE_RESET_TRIGGER_EVENT)
  end

  function aura_env:NotifyEncapsulateSelfAura()
    WeakAuras.ScanEvents(
      aura_env.ENCAPSULATE_SELF_TRIGGER_EVENT,
      aura_env.encapsulateDuration or aura_env.ENCAPSULATE_TOTAL_DURATION,
      aura_env.encapsulateEndTime or GetTime()
    )
  end

  function aura_env:NotifyEncapsulateGlowAura(unitID)
    WeakAuras.ScanEvents(
      aura_env.ENCAPSULATE_GLOW_TRIGGER_EVENT,
      unitID,
      aura_env.encapsulateDuration or aura_env.ENCAPSULATE_TOTAL_DURATION,
      aura_env.encapsulateEndTime or GetTime()
    )
  end

  function aura_env:NotifyEncapsulateRangeAura(isUnsafe)
    WeakAuras.ScanEvents(
      aura_env.ENCAPSULATE_RANGE_TRIGGER_EVENT,
      isUnsafe,
      aura_env.encapsulateDuration or aura_env.ENCAPSULATE_TOTAL_DURATION,
      aura_env.encapsulateEndTime or GetTime()
    )
  end

  function aura_env:RegisterEncapsulateCast(unitID, unitName)
    aura_env.encapsulateDuration = aura_env.ENCAPSULATE_TOTAL_DURATION
    aura_env.encapsulateEndTime = GetTime() + aura_env.ENCAPSULATE_TOTAL_DURATION
    aura_env.encapsulatedUnitID = unitID
    aura_env.encapsulatedUnitName = unitName
  end

  function aura_env:RegisterEncapsulateDebuff(unitID, unitName)
    aura_env.encapsulateDuration = aura_env.ENCAPSULATE_DEBUFF_DURATION
    aura_env.encapsulateEndTime = GetTime() + aura_env.ENCAPSULATE_DEBUFF_DURATION
    aura_env.encapsulatedUnitID = unitID
    aura_env.encapsulatedUnitName = unitName
  end

  function aura_env:ResetEncapsulate()
    aura_env.encapsulateEndTime = nil
    aura_env.encapsulateDuration = nil
    aura_env.encapsulatedUnitID = nil
    aura_env.encapsulatedUnitName = nil
    aura_env:NotifyResetTriggers()
  end
end

-- Every frame
function Trigger1()
  if not aura_env.THREAT_ADDON then
    return false
  end

  local hasTriggerExecutedRecently =
      GetTime() - aura_env.lastTriggerExecutionTime < aura_env.config.throttleThreshold
  local isBossAirPhase =
      GetTime() < aura_env.airPhaseEndTime

  if hasTriggerExecutedRecently or (isBossAirPhase and not aura_env.encapsulateEndTime) then
    return false
  else
    aura_env.lastTriggerExecutionTime = GetTime()
  end

  if aura_env.encapsulateEndTime and GetTime() > aura_env.encapsulateEndTime then
    aura_env:ResetEncapsulate()
  end

  if aura_env:IsSelfEncapsulated() then
    return false
  end

  if aura_env.encapsulateEndTime and GetTime() < aura_env.encapsulateEndTime then
    local isUnsafe = WeakAuras.CheckRange(aura_env.encapsulatedUnitID, 20, "<=")

    aura_env:NotifyEncapsulateRangeAura(isUnsafe)

    return false
  end

  -- At this point if there is an encapsulated player the fuction had early return.
  -- Code below looks for boss target swap and registers encapsulate cast if the new boss target is not top on threat.

  local bossTargetUnitID, bossTargetUnitName, bossGUID = aura_env:GetBossTargetAndGUID()

  aura_env.previousBossTargetUnitID = aura_env.currentBossTargetUnitID
  aura_env.previousBossTargetUnitName = aura_env.currentBossTargetUnitName
  aura_env.currentBossTargetUnitID = bossTargetUnitID
  aura_env.currentBossTargetUnitName = bossTargetUnitName

  local hasTargetRecordsForSwapCheck =
      aura_env.previousBossTargetUnitName and aura_env.currentBossTargetUnitName
  local isNewTargetPreviousTarget =
      aura_env.previousBossTargetUnitName == aura_env.currentBossTargetUnitName

  if isNewTargetPreviousTarget or not hasTargetRecordsForSwapCheck or not bossGUID then
    return false
  end

  if UnitIsDeadOrGhost(aura_env.previousBossTargetUnitID) == 1 then
    aura_env.previousBossTargetUnitID = nil
    return false
  end

  local isCurrentBossTargetTanking = aura_env:IsUnitTankingTheBoss(
    UnitGUID(bossTargetUnitID),
    bossGUID
  )

  if isCurrentBossTargetTanking then
    return false
  end

  aura_env:ResetEncapsulate()
  aura_env:RegisterEncapsulateCast(
    aura_env.currentBossTargetUnitID,
    aura_env.currentBossTargetUnitName
  )
  aura_env:Mark(bossTargetUnitID)
  aura_env:NotifyEncapsulateGlowAura(bossTargetUnitID)

  if aura_env:IsSelfEncapsulated() then
    aura_env:NotifyEncapsulateSelfAura()
  end

  return false
end

-- CHAT_MSG_MONSTER_YELL
function Trigger2(event, message)
  if event == "OPTIONS" then
    return false
  end

  if message == aura_env.AIR_PHASE_EMOTE or message:find(aura_env.AIR_PHASE_EMOTE) then
    aura_env:RegisterAirPhase()
  end

  return false
end

-- CLEU:SPELL_AURA_APPLIED,CLEU:SPELL_AURA_REMOVED,CLEU:UNIT_DIED
function Trigger3(
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

  local isAuraApplied = subEvent == "SPELL_AURA_APPLIED"
  local isAuraRemoved = subEvent == "SPELL_AURA_REMOVED"
  local isSpellAuraEvent = isAuraApplied or isAuraRemoved
  local hasEncapsulateTargetDied =
      subEvent == "UNIT_DIED" and destName == aura_env.encapsulatedUnitName

  if isSpellAuraEvent and spellID ~= aura_env.TRACKED_SPELL_ID then
    return false
  end

  if isAuraRemoved or hasEncapsulateTargetDied then
    aura_env:ResetEncapsulate()
    return false
  end

  if not isAuraApplied then
    return false
  end

  local targetUnitID = aura_env:GetRaidUnitID(destName)

  if not targetUnitID then
    return false
  end

  aura_env:ResetEncapsulate()
  aura_env:RegisterEncapsulateDebuff(targetUnitID, destName)
  aura_env:Mark(targetUnitID)

  if aura_env:IsSelfEncapsulated() then
    aura_env:NotifyEncapsulateSelfAura()
  end
end

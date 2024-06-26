function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
  aura_env.THREAT_ADDON = LibStub("Threat-2.0")
  aura_env.BOSS_NAME = "Felmyst"
  aura_env.AIR_PHASE_DURATION = 99
  aura_env.TRACKED_SPELL_ID = 45665
  --aura_env.TRACKED_SPELL_ID = 6788 -- weakened soul
  aura_env.TRACKED_SPELL_NAME = GetSpellInfo(aura_env.TRACKED_SPELL_ID)
  aura_env.GAS_NOVA_SPELL_ID = 45855
  --aura_env.GAS_NOVA_SPELL_ID = 25235 -- flash heal
  aura_env.GAS_NOVA_COOLDOWN = 20
  -----------------------------------------------------------------------------------------------
  -- A bit increased timers than it is in the actual game.
  -- Done to decrease a chance to catch a couple millisecond offset, which causes a double trigger.
  -- And to hold people running back in too early by showing the notification for a second longer.
  aura_env.ENCAPSULATE_CAST_DURATION = 2.5
  aura_env.ENCAPSULATE_DEBUFF_DURATION = 6.5
  -----------------------------------------------------------------------------------------------
  aura_env.ENCAPSULATE_TOTAL_DURATION =
      aura_env.ENCAPSULATE_CAST_DURATION +
      aura_env.ENCAPSULATE_DEBUFF_DURATION
  aura_env.AIR_PHASE_EMOTE = "I am stronger than ever before!"
  aura_env.ENCAPSULATE_TRIGGER_EVENT = "SOLTI_ENCAPSULATE_TRIGGER"
  aura_env.ENCAPSULATE_MARK_TRIGGER_EVENT = "SOLTI_ENCAPSULATE_MARK_TRIGGER"
  aura_env.airPhaseEndTime = GetTime()
  aura_env.lastTriggerExecutionTime = GetTime()
  aura_env.lastGasNovaCastTime = GetTime()
  aura_env.lastEncapsulateTargetSwapTime = GetTime()
  aura_env.firstGasNovaCastTime = nil
  aura_env.shouldCheckBossTargetSwap = false
  aura_env.currentBossTargetName = nil
  aura_env.encapsulateEndTime = nil
  aura_env.encapsulateDuration = nil
  aura_env.encapsulatedUnitName = nil

  function aura_env:IsUnitTankingTheBoss(unitGUID, bossGUID)
    local maxThreat, tankingUnitGUID = aura_env.THREAT_ADDON:GetMaxThreatOnTarget(bossGUID)

    if not maxThreat or maxThreat == 0 or not tankingUnitGUID then
      return true
    end

    return unitGUID == tankingUnitGUID
  end

  function aura_env:HasEncapsulateDebuff(unitName)
    if not UnitExists(unitName) then
      return false
    end

    local hasEncapsDebuff = false
    local debuffIndex = 1

    while true do
      local debuffName = UnitDebuff(unitName, debuffIndex)

      if not debuffName then
        break
      end

      debuffIndex = debuffIndex + 1

      if debuffName == aura_env.TRACKED_SPELL_NAME then
        hasEncapsDebuff = true
        break
      end
    end

    return hasEncapsDebuff
  end

  function aura_env:IsSelfEncapsulated()
    return aura_env.CONTEXT:IsMyName(aura_env.encapsulatedUnitName)
  end

  function aura_env:NotifyUpdateSubscribers()
    local isSelfClose = WeakAuras.CheckRange(aura_env.encapsulatedUnitName, 25, "<=")
    local isSelfTarget = aura_env:IsSelfEncapsulated()

    WeakAuras.ScanEvents(
      aura_env.ENCAPSULATE_TRIGGER_EVENT,
      aura_env.encapsulatedUnitName,
      isSelfTarget,
      isSelfClose,
      aura_env.encapsulateDuration,
      aura_env.encapsulateEndTime
    )
  end

  function aura_env:MarkEncapsulateTarget()
    WeakAuras.ScanEvents(
      aura_env.ENCAPSULATE_MARK_TRIGGER_EVENT,
      aura_env.encapsulatedUnitName,
      aura_env.encapsulateDuration
    )
  end

  function aura_env:RegisterEncapsulate(
      duration,
      unitName,
      isDebuffTrigger
  )
    aura_env.encapsulateDuration = duration
    aura_env.encapsulateEndTime = GetTime() + duration
    aura_env.encapsulatedUnitName = unitName

    if isDebuffTrigger then
      aura_env.shouldCheckBossTargetSwap = false
    end

    if aura_env:IsSelfEncapsulated() then
      SendChatMessage(aura_env.config.chatMessage, "SAY")
    end

    aura_env:MarkEncapsulateTarget()
    aura_env:NotifyUpdateSubscribers()
  end

  function aura_env:ResetEncapsulate()
    aura_env.encapsulateEndTime = nil
    aura_env.encapsulateDuration = nil
    aura_env.encapsulatedUnitName = nil
    aura_env:NotifyUpdateSubscribers()
  end
end

-- Every frame
function Trigger1()
  -- if Gas Nova was not cast even once consider that it is Brutallus fight
  if not aura_env.firstGasNovaCastTime then
    return false
  end

  local now = GetTime()
  local hasTriggerExecutedRecently =
      now - aura_env.lastTriggerExecutionTime < aura_env.config.throttleThreshold
  local isBossAirPhase =
      now < aura_env.airPhaseEndTime

  if hasTriggerExecutedRecently or (isBossAirPhase and not aura_env.encapsulateEndTime) then
    return false
  else
    aura_env.lastTriggerExecutionTime = now
  end

  if aura_env.encapsulateEndTime and now > aura_env.encapsulateEndTime then
    aura_env:ResetEncapsulate()
  end

  if aura_env.encapsulatedUnitName then
    local hasEncapsDebuff = aura_env:HasEncapsulateDebuff(aura_env.encapsulatedUnitName)
    local isProbablyCasting = now - aura_env.lastEncapsulateTargetSwapTime < aura_env.ENCAPSULATE_CAST_DURATION

    if not hasEncapsDebuff and not isProbablyCasting then
      aura_env:ResetEncapsulate()
    end
  end

  if aura_env:IsSelfEncapsulated() then
    return false
  end

  if aura_env.encapsulateEndTime and now < aura_env.encapsulateEndTime then
    aura_env:NotifyUpdateSubscribers()
    return false
  end

  for unitID in WA_IterateGroupMembers() do
    local unitName = UnitName(unitID)
    local hasEncapsDebuff = aura_env:HasEncapsulateDebuff(unitName)

    if hasEncapsDebuff then
      aura_env:RegisterEncapsulate(
        aura_env.ENCAPSULATE_DEBUFF_DURATION,
        unitName,
        true
      )
      return false
    end
  end

  -- Air phase going, or wipe
  if now - aura_env.lastGasNovaCastTime >= aura_env.GAS_NOVA_COOLDOWN then
    aura_env.shouldCheckBossTargetSwap = false
  end

  -- At this point if there is an encapsulated player the fuction had early return.
  -- Code below looks for boss target swap and registers encapsulate cast if the new boss target is not top on threat.

  if not aura_env.shouldCheckBossTargetSwap or not aura_env.THREAT_ADDON then
    if aura_env.currentBossTargetName then
      aura_env.currentBossTargetName = nil
    end
    return false
  end

  local bossTargetName, bossGUID = aura_env.CONTEXT:GetUnitTargetAndGUID(aura_env.BOSS_NAME)
  local previousBossTargetName = aura_env.currentBossTargetName
  aura_env.currentBossTargetName = bossTargetName

  local hasEnoughTargetRecords =
      previousBossTargetName and aura_env.currentBossTargetName

  local isSameTarget =
      previousBossTargetName == aura_env.currentBossTargetName

  local shouldAbortTargetSwapCheck =
      isSameTarget
      or not hasEnoughTargetRecords
      or not bossGUID
      or UnitIsDeadOrGhost(previousBossTargetName) == 1

  if shouldAbortTargetSwapCheck then
    return false
  end

  local isTargetTank = aura_env:IsUnitTankingTheBoss(
    UnitGUID(bossTargetName),
    bossGUID
  )

  if isTargetTank then
    return false
  end

  aura_env:RegisterEncapsulate(
    aura_env.ENCAPSULATE_TOTAL_DURATION,
    aura_env.currentBossTargetName,
    false
  )

  aura_env.lastEncapsulateTargetSwapTime = GetTime()

  return false
end

-- CHAT_MSG_MONSTER_YELL
function Trigger2(event, message)
  if event == "OPTIONS" then
    return false
  end

  if message == aura_env.AIR_PHASE_EMOTE or message:find(aura_env.AIR_PHASE_EMOTE) then
    aura_env.airPhaseEndTime = GetTime() + aura_env.AIR_PHASE_DURATION
    aura_env.shouldCheckBossTargetSwap = false
  end

  return false
end

-- CLEU:UNIT_DIED
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
  if event == "OPTIONS" or destName ~= aura_env.encapsulatedUnitName then
    return false
  end

  aura_env:ResetEncapsulate()
end

-- CLEU:SPELL_CAST_START
function Trigger4(
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
  if event == "OPTIONS" or spellID ~= aura_env.GAS_NOVA_SPELL_ID then
    return false
  end

  if not aura_env.firstGasNovaCastTime then
    aura_env.firstGasNovaCastTime = GetTime()
  end

  aura_env.lastGasNovaCastTime = GetTime()
  aura_env.shouldCheckBossTargetSwap = true

  return false
end

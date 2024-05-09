function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.BOSS_NAME = "Kalecgos"
  aura_env.TRACKED_SPELL_ID = 41483
  --aura_env.BOSS_NAME = "Solti"
  --aura_env.TRACKED_SPELL_ID = 25213
  aura_env.BOSS_TARGET_SWAP_DELAY = 0.5
  local PROJECTILE_TRAVEL_TIME = 1.5
  local TRACKED_SPELL_NAME, _, _, _, _, _, TRACKED_SPELL_CASTING_TIME, _, _ = GetSpellInfo(aura_env.TRACKED_SPELL_ID)
  aura_env.TRACKED_SPELL_NAME = TRACKED_SPELL_NAME
  aura_env.DURATION = (TRACKED_SPELL_CASTING_TIME / 1000) + PROJECTILE_TRAVEL_TIME
  aura_env.TRIGGER_EVENT = "SOLTI_ARCANE_BOLT_TRIGGER"
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_ARCANE_BOLT_MARK_TRIGGER"
  aura_env.lastTriggerExecutionTime = GetTime()
  aura_env.trackedSpellCastStartTime = nil
  aura_env.initialBossTargetName = nil

  function aura_env:IsTooClose(unitName)
    return CheckInteractDistance(unitName, 3) == 1
  end

  function aura_env:Reset()
    aura_env.initialBossTargetName = nil
    aura_env.trackedSpellCastStartTime = nil
  end
end

--CLEU:SPELL_CAST_START
function Trigger1(
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
  if event == "OPTIONS" or spellID ~= aura_env.TRACKED_SPELL_ID then
    return false
  end

  local bossTargetName = aura_env.CONTEXT:GetUnitTargetAndGUID(aura_env.BOSS_NAME)
  aura_env.initialBossTargetName = bossTargetName
  aura_env.trackedSpellCastStartTime = GetTime()

  return false
end

-- every frame
function Trigger2()
  local now = GetTime()

  local shouldAbort =
      not aura_env.trackedSpellCastStartTime
      or now - aura_env.lastTriggerExecutionTime < aura_env.config.throttleThreshold

  if shouldAbort then
    return false
  else
    aura_env.lastTriggerExecutionTime = now
  end

  local bossTargetName = aura_env.CONTEXT:GetUnitTargetAndGUID(aura_env.BOSS_NAME)
  local isNotTargetSwap = bossTargetName == aura_env.initialBossTargetName
  local isNotTimeForTargetSwap = now < (aura_env.trackedSpellCastStartTime + aura_env.BOSS_TARGET_SWAP_DELAY)

  -- Boss targets the real target around half a second after he starts casting
  if isNotTargetSwap and isNotTimeForTargetSwap then
    return false
  end

  if not bossTargetName then
    aura_env:Reset()
    return false
  end

  local isSelfTooCloseToBossTarget = false
  local isSelfBossTarget = aura_env.CONTEXT:IsMyName(bossTargetName)

  if isSelfBossTarget then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
  else
    isSelfTooCloseToBossTarget = aura_env:IsTooClose(bossTargetName)
  end

  WeakAuras.ScanEvents(
    aura_env.MARK_TRIGGER_EVENT,
    bossTargetName,
    aura_env.DURATION
  )

  if not isSelfBossTarget and not isSelfTooCloseToBossTarget then
    aura_env:Reset()
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    bossTargetName,
    isSelfBossTarget,
    isSelfTooCloseToBossTarget,
    aura_env.DURATION
  )

  aura_env:Reset()

  return false
end

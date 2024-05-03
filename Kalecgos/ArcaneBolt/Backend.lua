function Init()
  local BOSS_NAME = "Kalecgos"
  aura_env.TRACKED_SPELL_ID = 41483
  --local BOSS_NAME = "Solti"
  --aura_env.TRACKED_SPELL_ID = 25213
  aura_env.BOSS_TARGET_SWAP_DELAY = 0.5
  local PROJECTILE_TRAVEL_TIME = 1.5
  aura_env.SELF_NAME = UnitName("player")
  local TRACKED_SPELL_NAME, _, _, _, _, _, TRACKED_SPELL_CASTING_TIME, _, _ = GetSpellInfo(aura_env.TRACKED_SPELL_ID)
  aura_env.TRACKED_SPELL_NAME = TRACKED_SPELL_NAME
  aura_env.DURATION = (TRACKED_SPELL_CASTING_TIME / 1000) + PROJECTILE_TRAVEL_TIME
  aura_env.TRIGGER_EVENT = "SOLTI_ARCANE_BOLT_TRIGGER"
  aura_env.trackedSpellCastStartTime = nil
  aura_env.initialBossTargetUnitName = nil
  aura_env.lastTriggerExecutionTime = nil

  function aura_env:GetBossTarget()
    local numberOfRaidMembers = GetNumRaidMembers()

    for i = 1, numberOfRaidMembers do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == aura_env.SELF_NAME then
        raidUnitID = "player"
      end

      local raidUnitTargetName = UnitName(raidUnitID .. "target")

      if raidUnitTargetName == BOSS_NAME then
        for j = 1, numberOfRaidMembers do
          local name = GetRaidRosterInfo(j)
          if name == UnitName(raidUnitID .. "targettarget") then
            return "raid" .. j, name
          end
        end

        return nil, nil
      end
    end
  end

  function aura_env:IsTooClose(unitID)
    return CheckInteractDistance(unitID, 3) == 1
  end

  function aura_env:IsSelfUnitID(unitID)
    return UnitName(unitID) == aura_env.SELF_NAME
  end

  function aura_env:Reset()
    aura_env.initialBossTargetUnitName = nil
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

  local _, bossTargetUnitName = aura_env:GetBossTarget()
  aura_env.initialBossTargetUnitName = bossTargetUnitName
  aura_env.trackedSpellCastStartTime = GetTime()

  return false
end

-- every frame
function Trigger2()
  local shouldAbort =
      not aura_env.trackedSpellCastStartTime or
      (aura_env.lastTriggerExecutionTime and
        (GetTime() - aura_env.lastTriggerExecutionTime < aura_env.config.throttleThreshold))

  if shouldAbort then
    return false
  else
    aura_env.lastTriggerExecutionTime = GetTime()
  end

  local bossTargetUnitID, bossTargetUnitName = aura_env:GetBossTarget()
  local isNotTargetSwap = bossTargetUnitName == aura_env.initialBossTargetUnitName
  local isNotTimeForTargetSwap = GetTime() < aura_env.trackedSpellCastStartTime + aura_env.BOSS_TARGET_SWAP_DELAY

  -- Boss targets the real target around half a second after he starts casting
  if isNotTargetSwap and isNotTimeForTargetSwap then
    return false
  end

  if not bossTargetUnitName then
    aura_env:Reset()
    return false
  end

  local isSelfTooCloseToBossTarget = false
  local isSelfBossTarget = aura_env:IsSelfUnitID(bossTargetUnitID)

  if isSelfBossTarget then
    SendChatMessage(aura_env.config.chatMessage, "SAY")
  else
    isSelfTooCloseToBossTarget = aura_env:IsTooClose(bossTargetUnitID)
  end

  if not isSelfBossTarget and not isSelfTooCloseToBossTarget then
    aura_env:Reset()
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    bossTargetUnitID,
    isSelfBossTarget,
    isSelfTooCloseToBossTarget,
    aura_env.DURATION
  )

  aura_env:Reset()

  return false
end

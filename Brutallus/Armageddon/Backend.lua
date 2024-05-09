function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_ID = 20478
  --aura_env.TRACKED_SPELL_ID = 25222 -- Renew test
  aura_env.DURATION = 10
  aura_env.TRIGGER_EVENT = "SOLTI_ARMAGEDDON_TRIGGER"
  aura_env.DELAYED_TRIGGER_EVENT = "SOLTI_DELAYED_ARMAGEDDON_TRIGGER"
end

-- CLEU:SPELL_AURA_APPLIED
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
  local env = aura_env
  local isSelfTarget = env.CONTEXT:IsMyName(destName)
  local isTargetClose = WeakAuras.CheckRange(destName, 15, "<=")

  WeakAuras.ScanEvents(
    env.TRIGGER_EVENT,
    destName,
    isSelfTarget,
    isTargetClose,
    env.DURATION
  )

  if isSelfTarget then
    SendChatMessage(env.config.chatMessage, "SAY")

    WeakAuras.ScanEvents(
      env.DELAYED_TRIGGER_EVENT,
      destName,
      isSelfTarget,
      isTargetClose,
      env.DURATION
    )

    return false
  end

  -- Delay to wait for Burn projectile animation,
  -- so aura will not call to stack and then player will get Burn when stacking.
  env.CONTEXT:SetTimeout(
    function()
      WeakAuras.ScanEvents(
        env.DELAYED_TRIGGER_EVENT,
        destName,
        isSelfTarget,
        isTargetClose,
        env.DURATION - env.config.notificationDelay
      )
    end,
    env.config.notificationDelay
  )

  return false
end

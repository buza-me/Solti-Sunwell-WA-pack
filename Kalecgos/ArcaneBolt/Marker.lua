function Init()
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_MARK_TRIGGER"
end

-- SOLTI_ARCANE_BOLT_TRIGGER
function Trigger1(event, unitName, isSelfTarget, isSelfClose, duration)
  if event == "OPTIONS" or not UnitExists(unitName) then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.MARK_TRIGGER_EVENT,
    unitName,
    aura_env.config.markID,
    duration
  )

  return false
end

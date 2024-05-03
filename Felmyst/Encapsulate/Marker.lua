function Init()
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_MARK_TRIGGER"
end

-- SOLTI_ENCAPSULATE_MARK_TRIGGER
function Trigger1(event, unitID, duration)
  if event == "OPTIONS" or not unitID then
    return false
  end

  WeakAuras.ScanEvents(
    aura_env.MARK_TRIGGER_EVENT,
    unitID,
    aura_env.config.markID,
    duration
  )

  return false
end

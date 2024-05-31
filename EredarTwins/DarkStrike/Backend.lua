function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_ID = 45271
  aura_env.DURATION = 10
  aura_env.TRIGGER_EVENT = "SOLTI_DARK_STRIKE_TRIGGER"
end

-- CLEU:SPELL_AURA_APPLIED_DOSE,CLEU:SPELL_AURA_REMOVED_DOSE
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
    debuffType,
    stacks
)
  local shouldAbort =
      event == "OPTIONS"
      or spellID ~= aura_env.TRACKED_SPELL_ID
      or not UnitExists(destName)

  if shouldAbort then
    return false
  end

  local duration = 0

  if subEvent == "SPELL_AURA_APPLIED_DOSE" then
    duration = aura_env.DURATION
  end

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    duration,
    aura_env.CONTEXT:IsMyName(destName),
    stacks
  )

  return false
end

-- CLEU:SPELL_AURA_REMOVED
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
    debuffType,
    stacks
)
  local shouldAbort =
      event == "OPTIONS"
      or spellID ~= aura_env.TRACKED_SPELL_ID
      or not UnitExists(destName)

  if shouldAbort then
    return false
  end

  local duration = 0
  local stacks = 0

  WeakAuras.ScanEvents(
    aura_env.TRIGGER_EVENT,
    destName,
    duration,
    aura_env.CONTEXT:IsMyName(destName),
    stacks
  )

  return false
end

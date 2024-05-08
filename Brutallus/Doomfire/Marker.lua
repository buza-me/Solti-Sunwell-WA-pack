function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.TRACKED_SPELL_NAME = "Doomfire"
end

-- SOLTI_DOOMFIRE_MARK_TRIGGER
function Trigger1(event, firstUnitName, secondUnitName)
  if event == "OPTIONS" or not UnitExists(firstUnitName) or not UnitExists(secondUnitName) then
    return false
  end

  aura_env.CONTEXT:SetRaidMark(firstUnitName, aura_env.config.firstMarkID)
  aura_env.CONTEXT:SetRaidMark(secondUnitName, aura_env.config.secondMarkID)

  return false
end

--CLEU:SPELL_AURA_REMOVED, CLEU:UNIT_DIED
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
  if event == "OPTIONS" or (subEvent == "SPELL_AURA_REMOVED" and spellName ~= aura_env.TRACKED_SPELL_NAME) then
    return false
  end

  if not UnitExists(destName) then
    return false
  end

  aura_env.CONTEXT:UnsetRaidMark(destName, aura_env.config.firstMarkID)
  aura_env.CONTEXT:UnsetRaidMark(destName, aura_env.config.secondMarkID)

  return false
end

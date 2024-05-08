function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.markIDs = {
    aura_env.config.firstMarkID,
    aura_env.config.secondMarkID,
    aura_env.config.thirdMarkID
  }
  aura_env.nextMarkIndex = 1

  function aura_env:UpdateNextMarkIndex()
    if aura_env.nextMarkIndex == #aura_env.markIDs then
      aura_env.nextMarkIndex = 1
    else
      aura_env.nextMarkIndex = aura_env.nextMarkIndex + 1
    end
  end
end

-- SOLTI_GAS_NOVA_DURATION_TRIGGER
function Trigger1(event, unitName, duration)
  local shouldAbort =
      event == "OPTIONS"
      or not UnitExists(unitName)
      or not aura_env.CONTEXT:IsSelfRaidLead()

  if shouldAbort then
    return false
  end

  duration = duration or 0
  local unitRaidTargetIndex = GetRaidTargetIndex(unitName)
  local nextMarkID = aura_env.markIDs[aura_env.nextMarkIndex]

  if duration > 0 then
    if unitRaidTargetIndex ~= nextMarkID then
      SetRaidTarget(unitName, nextMarkID)
    end

    aura_env:UpdateNextMarkIndex()

    return false
  end

  local shouldUnmark =
      unitRaidTargetIndex == aura_env.markIDs[1]
      or unitRaidTargetIndex == aura_env.markIDs[2]
      or unitRaidTargetIndex == aura_env.markIDs[3]

  if shouldUnmark then
    SetRaidTarget(unitName, 0)
  end

  return false
end

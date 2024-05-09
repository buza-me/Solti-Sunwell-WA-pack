function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
end

-- SOLTI_MARK_TRIGGER
function Trigger1(event, unitID, markID, duration)
  if event == "OPTIONS" or not unitID or not markID then
    return false
  end

  duration = duration or 0
  local CONTEXT = aura_env.CONTEXT

  CONTEXT:SetRaidMark(unitID, markID)

  CONTEXT:SetTimeout(
    function()
      CONTEXT:UnsetRaidMark(unitID, markID)
    end,
    duration
  )

  return false
end

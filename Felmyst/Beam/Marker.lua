function Init()
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_MARK_TRIGGER"
  aura_env.TRACKED_SPELL_ID = 45392
  aura_env.DURATION = 10

  function aura_env:Mark(unitID)
    WeakAuras.ScanEvents(
      aura_env.MARK_TRIGGER_EVENT,
      unitID,
      aura_env.config.markID,
      aura_env.DURATION
    )
  end

  function aura_env:GetRaidUnitID(playerName)
    for i = 1, GetNumRaidMembers() do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == playerName then
        return raidUnitID
      end
    end
    return nil
  end
end

-- CLEU:SPELL_SUMMON
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

  local unitID = aura_env:GetRaidUnitID(sourceName)

  aura_env:Mark(unitID)

  return false
end

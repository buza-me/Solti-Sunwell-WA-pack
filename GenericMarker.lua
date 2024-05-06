function Init()
  aura_env.unitID = nil
  aura_env.markID = 0

  local playerName = UnitName("player")

  function aura_env:CanSelfMark()
    for i = 1, GetNumRaidMembers() do
      local name, rank = GetRaidRosterInfo(i)
      if name == playerName then
        return rank == 2 -- raid lead
      end
    end
  end
end

function OnShow()
  local markID = aura_env.markID
  local unitID = aura_env.unitID
  local raidTargetIndex = -1

  if unitID and #unitID > 0 then
    raidTargetIndex = GetRaidTargetIndex(unitID)
  end

  if raidTargetIndex ~= -1 and raidTargetIndex ~= markID and aura_env:CanSelfMark() then
    SetRaidTarget(unitID, markID)
  end
end

function OnHide()
  local markID = aura_env.markID
  local unitID = aura_env.unitID
  local raidTargetIndex = -1

  if unitID and #unitID > 0 then
    raidTargetIndex = GetRaidTargetIndex(unitID)
  end

  if raidTargetIndex == markID and aura_env:CanSelfMark() then
    SetRaidTarget(unitID, 0)
  end

  aura_env.unitID = nil
  aura_env.markID = 0
end

-- SOLTI_MARK_TRIGGER
function Trigger1(allStates, event, unitID, markID, duration)
  if event == "OPTIONS" or not unitID or not markID then
    return false
  end


  aura_env.unitID = unitID
  aura_env.markID = markID or 0
  duration = duration or 0

  local state = allStates[unitID] or { autoHide = true, progressType = "timed" }

  state.show = true
  state.unit = unitID
  state.changed = true
  state.duration = duration
  state.expirationTime = GetTime() + duration
  state.index = GetTime()

  allStates[unitID] = state

  return true
end

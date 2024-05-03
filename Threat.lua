local function GetThreat()
  local Threat = LibStub("Threat-2.0")

  local playerGUID, targetGUID = UnitGUID("player"), UnitGUID("target")

  local selfThreat = Threat:GetThreat(playerGUID, targetGUID)
  local maxThreat = Threat:GetMaxThreatOnTarget(playerGUID)
  local threatPercent = selfThreat / maxThreat

  if selfThreat == 0 then
    return {
      r = 0,
      g = 255,
      b = 0,
    }
  end

  return {
    r = 255 * selfThreat,
    g = 255 * (1 - selfThreat),
    b = 0,
  }
end

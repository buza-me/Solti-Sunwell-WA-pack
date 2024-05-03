local aura_env = {}
local WeakAuras = { ScanEvents = function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end }
local UnitName = function(unitID) end
local GetSpellInfo = function(spellID) end
local GetNumRaidMembers = function() end
local GetRaidRosterInfo = function(index) end
local CheckInteractDistance = function(unitID, distanceID) end
local GetTime = function() end
local SendChatMessage = function(ms, channel) end
local GetRaidTargetIndex = function(unitID) end
local SetRaidTarget = function(unitID, markID) end
local SendAddonMessage = function(prefix, msg, channel) end
local UnitDetailedThreatSituation = function(raidUnitID, raidUnitTargetID) end
local LibStub = function(addonName)
  return {
    GetThreat = function(teammateGUID, hostileGUID)
      return 0
    end,
    GetMaxThreatOnTarget = function(hostileGUID)
      return 0, "id"
    end
  }
end
local UnitDebuff = function(raidUnitID, index) end
--===================================================
--===================================================

-- CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REFRESH
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
  if event == "OPTIONS" or destName ~= UnitName("player") or (spellID ~= 20478 and spellID ~= 31944) then
    return false
  end

  for i = 1, 255 do
    local name, rank, icon, count, debuffType, duration, expirationTime = UnitDebuff("player", i)

    if not name then
      return false
    end

    SendChatMessage("Please save the values", "RAID")

    local nameStr = "Debuff Name: " .. (name or "nil") .. ", "
    local durationStr = "Duration: " .. (duration or "nil") .. ", "
    local expirationStr = "Expires in: " .. (expirationTime or "nil")

    SendChatMessage(nameStr .. durationStr .. expirationStr, "RAID")
  end

  return false
end

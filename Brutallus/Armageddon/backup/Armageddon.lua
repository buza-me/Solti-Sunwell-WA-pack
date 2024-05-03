local aura_env = {}
local WeakAuras = { ScanEvents = function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end }
local UnitName = function(unitID) end
local GetSpellInfo = function(spellID) end
local GetNumRaidMembers = function() end
local GetRaidRosterInfo = function(index) end
local CheckInteractDistance = function(unitID, distanceID) end
local GetTime = function() end
local SendChatMessage = function(ms, channel) end
--=====================================================

function Init()
  aura_env.TRACKED_SPELL_ID = 20478
  aura_env.TRACKED_SPELL_NAME = GetSpellInfo(aura_env.TRACKED_SPELL_ID)
  aura_env.DURATION = 10
  aura_env.DISPLAY_TEXT = "Stack!"
  aura_env.DISPLAY_TEXT_SELF = string.gsub("%s on You!", "%%s", aura_env.TRACKED_SPELL_NAME)
  aura_env.CHAT_MESSAGE_SELF = string.gsub("%s on me!", "%%s", aura_env.TRACKED_SPELL_NAME)
  aura_env.MARK_TRIGGER_EVENT = "SOLTI_MARK_TRIGGER"
  aura_env.SELF_NAME = UnitName("player")

  function aura_env:GetRaidUnitIDFromName(name)
    for i = 1, GetNumRaidMembers() do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == name then
        return raidUnitID
      end
    end
  end

  function aura_env:Mark(unitID)
    WeakAuras.ScanEvents(
      aura_env.MARK_TRIGGER_EVENT,
      unitID,
      aura_env.config.markID,
      aura_env.DURATION,
      true, -- withMark
      false -- withGlow
    )
  end
end

-- CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REFRESH
function Trigger1(
    allStates,
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


  local text, unitID = aura_env.DISPLAY_TEXT_SELF, "player"
  local isTargetSelf = destName == aura_env.SELF_NAME

  if isTargetSelf then
    SendChatMessage(aura_env.CHAT_MESSAGE_SELF, "SAY")
  else
    text = aura_env.DISPLAY_TEXT
    unitID = aura_env:GetRaidUnitIDFromName(destName)
  end

  aura_env:Mark(unitID)

  allStates[""] = allStates[""] or { autoHide = true, progressType = "timed", duration = aura_env.DURATION }
  allStates[""]["name"] = text
  allStates[""]["changed"] = true
  allStates[""]["expirationTime"] = GetTime() + aura_env.DURATION
  allStates[""]["show"] = isTargetSelf or CheckInteractDistance(unitID, 4) == 1

  return allStates
end

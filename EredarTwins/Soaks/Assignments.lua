function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
  aura_env.MESSAGE_TEMPLATE = "assignments"
  aura_env.SECOND_MESSAGE_TEMPLATE = "soakers"
  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_SUNWELL_TWINS_ASSIGNMENTS"
  aura_env.UPDATE_TRIGGER_EVENT = "SOLTI_SUNWELL_TWINS_ASSIGNMENTS_UPDATE"
  aura_env.SOAKERS = {}
  aura_env.updateTimeoutID = nil

  aura_env.CONTEXT.states = aura_env.CONTEXT.states or {}
  local state = aura_env.CONTEXT.states.twins or {}
  aura_env.CONTEXT.states.twins = state
  state.assignments = state.assignments or {}

  if #state.assignments == 0 then
    local phases = 2
    local types = 2 -- 1: fire, 2: shadow
    local zones = 6 -- 1 - 5 zones, 6 backup
    local assignments = state.assignments

    for phase = 1, phases do
      assignments[phase] = {}

      for type = 1, types do
        assignments[phase][type] = {}

        for zone = 1, zones do
          assignments[phase][type][zone] = {}
        end
      end
    end
  end

  local CONFIG_KEYS = {
    PHASES = {
      "firstPhase",
      "secondPhase",
    },
    TYPES = {
      "fire",
      "shadow",
    },
    ZONES = {
      "zoneOne",
      "zoneTwo",
      "zoneThree",
      "zoneFour",
      "zoneFive",
      "backup",
    }
  }

  local TEXT = {
    ZONES = {
      "1",
      "2",
      "3",
      "4",
      "5",
      "Backup",
    },
    PHASES = {
      "Phase 1",
      "Phase 2",
    },
    TYPES = {
      "Fire",
      "Shadow"
    }
  }

  state.TEXT = TEXT

  function aura_env:SendAssignments(withChatMessages)
    if not aura_env.CONTEXT.isInitialized then
      return
    end

    if #aura_env.SOAKERS == 0 then
      local SOAKERS = {}
      local assignedPlayers = { { {}, {} }, { {}, {} } }
      local messages = { typos = {}, duplicates = {} }

      for phase = 1, #CONFIG_KEYS.PHASES do
        local phaseKey = CONFIG_KEYS.PHASES[phase]
        SOAKERS[phase] = {}

        for type = 1, #CONFIG_KEYS.TYPES do
          local typeKey = CONFIG_KEYS.TYPES[type]
          SOAKERS[phase][type] = {}

          for zone = 1, #CONFIG_KEYS.ZONES do
            local zoneKey = CONFIG_KEYS.ZONES[zone]
            local fixedNames = aura_env.CONTEXT:SplitUserInput(aura_env.config[phaseKey][typeKey][zoneKey])
            local filteredNames = {}

            for nameIndex = 1, #fixedNames do
              local playerName = fixedNames[nameIndex]

              if not UnitExists(playerName) then
                table.insert(
                  messages.typos,
                  string.format(
                    "%s (%s %s %s)",
                    playerName,
                    TEXT.PHASES[phase],
                    TEXT.TYPES[type],
                    TEXT.ZONES[zone]
                  )
                )
              elseif assignedPlayers[phase][type][playerName] then
                table.insert(
                  messages.duplicates,
                  string.format(
                    "%s (%s %s %s)",
                    playerName,
                    TEXT.PHASES[phase],
                    TEXT.TYPES[type],
                    TEXT.ZONES[zone]
                  )
                )
              else
                table.insert(filteredNames, playerName)
                assignedPlayers[phase][type][playerName] = true
              end
            end

            SOAKERS[phase][type][zone] = table.concat(filteredNames, " ")
          end
        end
      end

      if withChatMessages then
        SendChatMessage("Removed players that don't exist:", "RAID")
        SendChatMessage(table.concat(messages.typos, ", "), "RAID")
        SendChatMessage("Removed duplicates:", "RAID")
        SendChatMessage(table.concat(messages.duplicates, ", "), "RAID")
      end

      aura_env.SOAKERS = SOAKERS
    end

    local SOAKERS = aura_env.SOAKERS
    local addonMessages = {}
    local chatMessages = {}

    for phase = 1, #SOAKERS do
      table.insert(chatMessages, "--------------------------")

      for type = 1, #SOAKERS[phase] do
        table.insert(chatMessages, string.format("%s, %s:", TEXT.PHASES[phase], TEXT.TYPES[type]))

        for zone = 1, #SOAKERS[phase][type] do
          local addonMessage = string.format("%d,%d,%d,%s", phase, type, zone, SOAKERS[phase][type][zone])
          table.insert(addonMessages, addonMessage)

          local chatMessage = TEXT.ZONES[zone] .. " - " .. SOAKERS[phase][type][zone]
          table.insert(chatMessages, chatMessage)
        end
      end
    end

    if withChatMessages then
      for i = 1, #chatMessages do
        SendChatMessage(chatMessages[i], "RAID")
      end
    end

    for i = 1, #addonMessages do
      SendAddonMessage(
        aura_env.CHAT_MSG_ADDON_PREFIX,
        addonMessages[i],
        "RAID"
      )
    end
  end

  function aura_env:ParseAddonMessage(message)
    if not message then
      return
    end

    local messageParts = aura_env.CONTEXT:StringSplit(message, ",")
    local phase = tonumber(messageParts[1])
    local type = tonumber(messageParts[2])
    local zone = tonumber(messageParts[3])
    local names = aura_env.CONTEXT:StringSplit(messageParts[4] or "", " ")

    ---@diagnostic disable-next-line: need-check-nil
    state.assignments[phase][type][zone] = names
  end
end

-- CHAT_MSG_RAID,CHAT_MSG_RAID_LEADER,CHAT_MSG_RAID_WARNING,CHAT_MSG_SAY,CHAT_MSG_YELL
function Trigger1(event, message, author)
  local shouldAbort =
      event == "OPTIONS"
      or not message
      or not UnitExists(author)
      or not aura_env.CONTEXT:IsSelfRaidLead()
      or (
        string.lower(message) ~= aura_env.MESSAGE_TEMPLATE
        and string.lower(message) ~= aura_env.SECOND_MESSAGE_TEMPLATE
      )

  if shouldAbort then
    return false
  end

  aura_env:SendAssignments(true)
end

-- CHAT_MSG_ADDON
function Trigger2(event, prefix, text)
  if event == "OPTIONS" or prefix ~= aura_env.CHAT_MSG_ADDON_PREFIX then
    return false
  end

  aura_env:ParseAddonMessage(text)

  local env = aura_env

  if not env.updateTimeoutID then
    local timeoutID = env.CONTEXT:SetTimeout(
      function()
        env.updateTimeoutID = nil
        WeakAuras.ScanEvents(env.UPDATE_TRIGGER_EVENT)
      end,
      0.016
    )

    env.updateTimeoutID = timeoutID
  end

  return false
end

-- PLAYER_REGEN_DISABLED
function Trigger3(event)
  if event == "OPTIONS" or not aura_env.CONTEXT:IsSelfRaidLead() then
    return false
  end

  aura_env:SendAssignments()

  return false
end

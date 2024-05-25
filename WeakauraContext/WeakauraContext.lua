function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)

  local Context = LibStub(LIB_NAME)

  function Context:UseFallback(arg, fallback)
    if arg == nil then
      arg = fallback
    end

    return arg
  end

  Context.SUNWELL_PACK_SYNC_MSG_PREFIX = "SOLTI_SUNWELL_WA_CHECK"
  Context.SELF_NAME = UnitName("player")
  Context.playersWithSunwellPackSortTimeoutID = nil

  Context.playersWithSunwellPack = Context:UseFallback(
    Context.playersWithSunwellPack,
    { [Context.SELF_NAME] = true }
  )
  Context.sortedNamesOfPlayersWithSunwellPack = Context:UseFallback(
    Context.sortedNamesOfPlayersWithSunwellPack,
    { Context.SELF_NAME }
  )
  Context.onInit = Context:UseFallback(
    Context.onInit,
    {}
  )
  Context.roster = Context:UseFallback(
    Context.roster,
    {}
  )
  Context.states = Context:UseFallback(
    Context.states,
    {}
  )
  Context.pendingAugmentDBM = Context:UseFallback(
    Context.pendingAugmentDBM,
    {}
  )
  Context._paintedNamesCache = Context:UseFallback(
    Context._paintedNamesCache,
    {}
  )
  Context._timeouts = Context:UseFallback(
    Context._timeouts,
    { counter = 0, instances = {} }
  )
  Context._intervals = Context:UseFallback(
    Context._intervals,
    { counter = 0, instances = {} }
  )

  function Context:UpdateRoster()
    self.roster = {}
    for unitID in WA_IterateGroupMembers() do
      local unitName = UnitName(unitID)
      self.roster[unitID] = unitName
      self.roster[unitName] = unitID
    end
  end

  function Context:IsMyName(name)
    return name == Context.SELF_NAME
  end

  function Context:IsHeroic()
    local name, instanceType, difficultyID, difficultyName, maxPlayers = GetInstanceInfo()
    return difficultyID == 2
  end

  function Context:StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
  end

  function Context:EndsWith(str, suffix)
    return string.sub(str, #str - #suffix + 1) == suffix
  end

  function Context:OmitPrefix(str, prefix)
    return string.sub(str, #prefix + 1)
  end

  function Context:OmitSuffix(str, suffix)
    return string.sub(str, 1, #str - #suffix)
  end

  function Context:StringCapitalize(str)
    return (str:gsub("^%l", string.upper))
  end

  function Context:StringTrim(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
  end

  function Context:StringSplit(inputString, separator)
    if not inputString or not separator then
      return inputString
    end

    local result = {}
    for str in string.gmatch(inputString, "([^" .. separator .. "]+)") do
      table.insert(result, str)
    end

    return result
  end

  function Context:SplitUserInput(inputString)
    local result = {}

    if not inputString or #inputString == 0 then
      return result
    end

    for word in string.gmatch(inputString, '[^%s,]+') do
      table.insert(
        result,
        self:StringCapitalize(string.lower(word))
      )
    end

    return result
  end

  function Context:DeepCopy(source)
    local sourceType = type(source)
    local copy
    if sourceType == 'table' then
      copy = {}
      for sourceKey, sourceValue in next, source, nil do
        copy[self:DeepCopy(sourceKey)] = self:DeepCopy(sourceValue)
      end
      setmetatable(copy, self:DeepCopy(getmetatable(source)))
    else -- number, string, boolean, etc
      copy = source
    end
    return copy
  end

  function Context:IsSelfRaidLead()
    return IsRaidLeader() == 1
  end

  function Context:IsSelfRaidAssist()
    return IsRaidOfficer() == 1
  end

  function Context:IsTalentLearned(tab, talentId)
    local _, _, _, _, pointsSpent = GetTalentInfo(tab, talentId)
    if pointsSpent > 0 then
      return true
    end
    return false
  end

  function Context:IsSelfTank()
    local playerClass = UnitClass("player")

    return (playerClass == "Druid" and GetShapeshiftForm() == 1 and self:IsTalentLearned(2, 5))
        or (playerClass == "Warrior" and self:IsTalentLearned(3, 19))
        or (playerClass == "Paladin" and self:IsTalentLearned(2, 19))
  end

  function Context:GetUnitTargetAndGUID(unitName)
    local unitTargetName = nil
    local unitGUID = nil

    for groupUnitID in WA_IterateGroupMembers() do
      local groupUnitTargetID = groupUnitID .. "target"
      local groupUnitTargetName = UnitName(groupUnitTargetID)

      if groupUnitTargetName == unitName then
        unitTargetName = UnitName(groupUnitTargetID .. "target")
        unitGUID = UnitGUID(groupUnitTargetID)
        break
      end
    end

    return unitTargetName, unitGUID
  end

  function Context:GetClassColorName(unitName)
    if self._paintedNamesCache[unitName] then
      return self._paintedNamesCache[unitName]
    end

    local classColoredName = WeakAuras.WA_ClassColorName(unitName)

    if #classColoredName == 0 then
      classColoredName = unitName
    end

    self._paintedNamesCache[unitName] = classColoredName

    return classColoredName
  end

  function Context:GetRaidMarkID(unit)
    local raidMarkID = -1

    if unit and UnitExists(unit) then
      raidMarkID = GetRaidTargetIndex(unit)
    end

    return raidMarkID
  end

  function Context:SetRaidMark(unit, markID)
    if not self:IsSelfRaidLead() then
      return
    end

    local unitRaidMarkID = self:GetRaidMarkID(unit)

    if unitRaidMarkID ~= -1 and unitRaidMarkID ~= markID then
      SetRaidTarget(unit, markID)
    end
  end

  function Context:UnsetRaidMark(unit, markID, shouldForce)
    if not self:IsSelfRaidLead() then
      return
    end

    local unitRaidMarkID = self:GetRaidMarkID(unit)

    if shouldForce or unitRaidMarkID == markID then
      SetRaidTarget(unit, 0)
    end
  end

  function Context:UseSpecialWarning(withShake, withGlow)
    if DBM then
      DBM.AddSpecialWarning("", withShake, withGlow)
    end
  end

  function Context:AddTimerInstance(timerTable, func, delay, ...)
    if type(func) ~= "function" or type(delay) ~= "number" then
      return nil
    end

    timerTable.counter = timerTable.counter + 1

    local instance = {
      id = timerTable.counter,
      delay = delay,
      executeAt = GetTime() + delay,
      func = func,
      arguments = { ... },
    }

    table.insert(timerTable.instances, instance)

    return instance.id
  end

  function Context:RemoveTimerInstance(timerTable, id)
    if type(id) ~= "number" then
      return
    end
    for index, instance in pairs(timerTable.instances) do
      if instance.id == id then
        table.remove(timerTable.instances, index)
      end
    end
  end

  function Context:SetTimeout(func, delay, ...)
    return self:AddTimerInstance(self._timeouts, func, delay, ...)
  end

  function Context:ClearTimeout(id)
    return self:RemoveTimerInstance(self._timeouts, id)
  end

  function Context:SetInterval(func, delay, ...)
    return self:AddTimerInstance(self._intervals, func, delay, ...)
  end

  function Context:ClearInterval(id)
    return self:RemoveTimerInstance(self._intervals, id)
  end

  function Context:AugmentDBM(modName, augmentFunction)
    if not DBM then
      return
    end

    local mod = DBM:GetMod(modName)

    if not mod then
      return
    end

    if mod.isAugmentedBySolti then
      self.pendingAugmentDBM[modName] = nil
      return
    else
      mod.isAugmentedBySolti = true
    end

    self.pendingAugmentDBM[modName] = nil

    augmentFunction(mod, DBM_SavedVars.AddOns[modName])
  end

  function Context:GenericTimedTriggerStateUpdaterLogicWithUnitID(allStates, event, unitName, duration)
    if event == "OPTIONS" or not UnitExists(unitName) then
      return allStates, nil
    end

    local unitID = Context.roster[unitName]

    if not unitID then
      return allStates, nil
    end

    duration = duration or 0

    local state = allStates[unitID] or { autoHide = true, progressType = "timed" }

    state.show = duration > 0
    state.unit = unitID
    state.changed = true
    state.duration = duration
    state.expirationTime = GetTime() + duration
    state.index = GetTime()

    allStates[unitID] = state

    return allStates, state
  end

  function Context:GenericTimedTriggerStateUpdaterLogicWithSelfTargetCheck(
      allStates,
      event,
      unitName,
      duration,
      isTargetSelf
  )
    if event == "OPTIONS" then
      return allStates, nil
    end

    if isTargetSelf == nil then
      isTargetSelf = Context:IsMyName(unitName)
    end

    if not isTargetSelf then
      return allStates, nil
    end

    duration = duration or 0

    local state = allStates[""] or { autoHide = true, progressType = "timed" }

    state.changed = true
    state.show = duration > 0
    state.duration = duration
    state.expirationTime = GetTime() + duration

    allStates[""] = state

    return allStates, state
  end

  function Context:SendPlayersWithSunwellPackSync()
    SendAddonMessage(
      Context.SUNWELL_PACK_SYNC_MSG_PREFIX,
      Context.SELF_NAME,
      "RAID"
    )
  end

  Context:UpdateRoster()
  Context:SendPlayersWithSunwellPackSync()
  Context.isInitialized = true

  local function onInitErrorHandler(error)

  end

  for i = 1, #Context.onInit do
    local initObj = Context.onInit[i]
    local func, tag = nil, ""
    if type(initObj) == "function" then
      func = initObj
    end
    if type(initObj) == "table" then
      func = initObj.func
      tag = initObj.tag
    end
    if type(func) == "function" then
      xpcall(
        func,
        function(error)
          print(string.format("|cffFF0000%s tag: %s|r", error, tag))
        end
      )
    end
  end

  -----------------------------------------------------------------------------------
  --------------------------   INIT TRIGGER LOGIC   ---------------------------------
  -----------------------------------------------------------------------------------

  aura_env.lastGameLoopTime = GetTime()

  function aura_env.CompareStrings(a, b)
    return a < b
  end

  function aura_env.CHAT_MSG_ADDON(prefix, name)
    if prefix ~= Context.SUNWELL_PACK_SYNC_MSG_PREFIX then
      return false
    end

    if Context.playersWithSunwellPack[name] then
      return false
    end

    Context.playersWithSunwellPack[name] = true

    if Context.playersWithSunwellPackSortTimeoutID then
      return false
    end

    local env = aura_env

    local timeoutID = Context:SetTimeout(
      function()
        Context.playersWithSunwellPackSortTimeoutID = nil
        Context.sortedNamesOfPlayersWithSunwellPack = {}

        for unitName, _ in pairs(Context.playersWithSunwellPack) do
          table.insert(Context.sortedNamesOfPlayersWithSunwellPack, unitName)
        end

        table.sort(
          Context.sortedNamesOfPlayersWithSunwellPack,
          env.CompareStrings
        )
      end,
      1
    )

    Context.playersWithSunwellPackSortTimeoutID = timeoutID

    return false
  end

  function aura_env.PLAYER_REGEN_DISABLED()
    Context.playersWithSunwellPack = { [Context.SELF_NAME] = true }
    Context.sortedNamesOfPlayersWithSunwellPack = { Context.SELF_NAME }

    Context:SetTimeout(
      Context.SendPlayersWithSunwellPackSync,
      1
    )

    return false
  end

  function aura_env.RAID_ROSTER_UPDATE()
    Context:UpdateRoster()
  end

  function aura_env.OnUpdate()
    local now = GetTime()

    if now - aura_env.lastGameLoopTime < aura_env.config.timerThrottleThreshold then
      return false
    end

    aura_env.lastGameLoopTime = now

    for index, timeout in pairs(Context._timeouts.instances) do
      if now >= timeout.executeAt then
        table.remove(Context._timeouts.instances, index)

        timeout.func(unpack(timeout.arguments))
      end
    end

    for _, interval in pairs(Context._intervals.instances) do
      if now >= interval.executeAt then
        interval.executeAt = now + interval.delay

        interval.func(unpack(interval.arguments))
      end
    end

    if DBM then
      for name, func in pairs(Context.pendingAugmentDBM) do
        Context:AugmentDBM(name, func)
      end
    end
  end
end

-----------------------------------------------------------------------------------
-------------------------------   TRIGGERS   --------------------------------------
-----------------------------------------------------------------------------------

-- CHAT_MSG_ADDON,PLAYER_REGEN_DISABLED,RAID_ROSTER_UPDATE
function Trigger1(event, ...)
  if event == "OPTIONS" then
    return false
  end

  return aura_env[event](...)
end

-- every frame
function Trigger2()
  aura_env.OnUpdate()
end

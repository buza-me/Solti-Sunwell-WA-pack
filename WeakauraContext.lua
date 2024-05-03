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
  Context.playersWithSunwellPack = Context:UseFallback(Context.playersWithSunwellPack, { [Context.SELF_NAME] = true })
  Context._paintedNamesCache = Context:UseFallback(Context._paintedNamesCache, {})
  Context._timeouts = Context:UseFallback(Context._timeouts, { counter = 0, instances = {} })
  Context._intervals = Context:UseFallback(Context._intervals, { counter = 0, instances = {} })

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

  function Context:IsSelfRaidLead()
    return IsRaidLeader() == 1
  end

  function Context:IsSelfRaidAssist()
    return IsRaidOfficer() == 1
  end

  function Context:GetRaidUnitIDFromName(name)
    for i = 1, GetNumRaidMembers() do
      local raidUnitID = "raid" .. i

      if UnitName(raidUnitID) == name then
        return raidUnitID
      end
    end
  end

  function Context:GetClassColorName(unitName)
    if self._paintedNamesCache[unitName] then
      return self._paintedNamesCache[unitName]
    end

    local paintedName = WeakAuras.WA_ClassColorName(unitName)

    if #paintedName == 0 then
      paintedName = unitName
    end

    self._paintedNamesCache[unitName] = paintedName

    return unitName
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
    timerTable.counter = timerTable.counter + 1

    local instance = {
      id = timerTable.counter,
      delay = delay,
      executeAt = GetTime() + delay,
      func = func,
      args = { ... },
    }

    table.insert(timerTable.instances, instance)

    return instance.id
  end

  function Context:RemoveTimerInstance(timerTable, id)
    for index, instance in pairs(#timerTable.instances) do
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

  function Context:AugmentDBM(modName, augmentFunction, ...)
    local state = {
      startTime = GetTime(),
      intervalID = nil,
      arguments = { ... }
    }

    state.intervalID = Context:SetInterval(
      function()
        if GetTime() - state.startTime >= 20 then
          Context:ClearInterval(state.intervalID)
        end

        if not DBM then
          return
        end

        local mod = DBM:GetMod(modName)

        if not mod then
          return
        end

        if mod.isAugmentedBySolti then
          Context:ClearInterval(state.intervalID)
          return
        else
          mod.isAugmentedBySolti = true
        end

        augmentFunction(mod, unpack(state.arguments))

        Context:ClearInterval(state.intervalID)
      end,
      0
    )
  end

  -----------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------

  aura_env.lastGameLoopTime = GetTime()

  function aura_env:CHAT_MSG_ADDON(prefix, name)
    if prefix ~= Context.SUNWELL_PACK_SYNC_MSG_PREFIX then
      return false
    end

    Context.playersWithSunwellPack[name] = true

    return false
  end

  function aura_env:PLAYER_REGEN_DISABLED()
    for name, _ in pairs(Context.playersWithSunwellPack) do
      if not UnitExists(name) then
        Context.playersWithSunwellPack[name] = nil
      end
    end

    self:SetTimeout(
      function()
        SendAddonMessage(
          Context.SUNWELL_PACK_SYNC_MSG_PREFIX,
          Context.SELF_NAME,
          "RAID"
        )
      end,
      0.1
    )

    return false
  end

  function aura_env:OnUpdate()
    local now = GetTime()

    if now - aura_env.lastGameLoopTime < aura_env.config.timerThrottleThreshold then
      return false
    end

    for index, timeout in pairs(Context._timeouts) do
      if timeout.executeAt >= now then
        table.remove(Context._timeouts, index)

        timeout.func(unpack(timeout.arguments))
      end
    end

    for _, interval in pairs(Context._intervals) do
      if interval.executeAt >= now then
        interval.executeAt = now + interval.delay

        interval.func(unpack(interval.arguments))
      end
    end
  end
end

-- CHAT_MSG_ADDON,PLAYER_REGEN_DISABLED
function Trigger1(event, ...)
  if event == "OPTIONS" then
    return false
  end

  return aura_env[event](...)
end

-- every frame
function Trigger2()
  aura_env:OnUpdate()
end

function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
  aura_env.timeoutIDs = {}
  aura_env.intervalIDs = {}
end

-- SOLTI_TEST_SET_TIMEOUT
function Trigger1(event, delay)
  if event == "OPTIONS" or not delay then
    return false
  end

  local start = GetTime()
  local index = #aura_env.timeoutIDs + 1
  local timeoutIDs = aura_env.timeoutIDs

  local timeoutID = aura_env.CONTEXT:SetTimeout(
    function()
      print(
        string.format(
          "index: %d, timeout ID: %d, executed after: %d, original delay: %d",
          index,
          timeoutIDs[index],
          GetTime() - start,
          delay
        )
      )
    end,
    delay
  )

  table.insert(
    aura_env.timeoutIDs,
    timeoutID
  )

  return false
end

-- SOLTI_TEST_CLEAR_TIMEOUT
function Trigger2(event, index)
  if event == "OPTIONS" or not index then
    return false
  end

  aura_env.CONTEXT:ClearTimeout(aura_env.timeoutIDs[index])

  local match = false

  for _, timeout in pairs(aura_env.CONTEXT._timeouts.instances) do
    if timeout.id == aura_env.timeoutIDs[index] then
      match = true
    end
  end

  if match then
    print(string.format("Timeout %d was not cleared", aura_env.timeoutIDs[index]))
  else
    print(string.format("Timeout %d was cleared", aura_env.timeoutIDs[index]))
  end

  return false
end

-- SOLTI_TEST_TIMEOUT_WIPE_STATE
function Trigger3(event)
  if event == "OPTIONS" then
    return false
  end

  aura_env.timeoutIDs = {}
end

-- /run local evt,evt_fn="SOLTI_TEST_SET_TIMEOUT",WeakAuras.ScanEvents;evt_fn(evt,3);evt_fn(evt,1);evt_fn(evt,6);evt_fn(evt,-1);evt_fn(evt,0);
-- expect:
-- "index: 4, timeout ID: 4, executed after: 0, original delay: -1"
-- "index: 5, timeout ID: 5, executed after: 0, original delay: 0"
-- "index: 2, timeout ID: 2, executed after: 1, original delay: 1"
-- "index: 1, timeout ID: 1, executed after: 3, original delay: 3"
-- "index: 3, timeout ID: 3, executed after: 6, original delay: 6"


-- /run local evt,evt_wipe,evt_clr,evt_fn="SOLTI_TEST_SET_TIMEOUT","SOLTI_TEST_TIMEOUT_WIPE_STATE","SOLTI_TEST_CLEAR_TIMEOUT",WeakAuras.ScanEvents;evt_fn(evt_wipe);evt_fn(evt,3);evt_fn(evt,1);evt_fn(evt,6);evt_fn(evt,-1);evt_fn(evt,0);evt_fn(evt_clr,3);
-- expect:
-- "Timeout 8 was cleared"
-- "index: 4, timeout ID: 9, executed after: 0, original delay: -1"
-- "index: 5, timeout ID: 10, executed after: 0, original delay: 0"
-- "index: 2, timeout ID: 7, executed after: 1, original delay: 1"
-- "index: 1, timeout ID: 6, executed after: 3, original delay: 3"


-- SOLTI_TEST_SET_INTERVAL
function Trigger4(event, delay, argument)
  if event == "OPTIONS" or not delay then
    return false
  end

  local start = GetTime()
  local index = #aura_env.intervalIDs + 1
  local intervalIDs = aura_env.intervalIDs

  local intervalID = aura_env.CONTEXT:SetInterval(
    function(argument)
      print(
        string.format(
          "index: %d, interval ID: %d, executed after: %d, original delay: %d, argument: %d",
          index,
          intervalIDs[index],
          GetTime() - start,
          delay,
          argument
        )
      )
    end,
    delay,
    argument
  )

  table.insert(
    aura_env.intervalIDs,
    intervalID
  )

  return false
end

-- SOLTI_TEST_CLEAR_INTERVAL
function Trigger5(event, index)
  if event == "OPTIONS" or not index then
    return false
  end

  aura_env.CONTEXT:ClearInterval(aura_env.intervalIDs[index])

  local match = false

  for _, interval in pairs(aura_env.CONTEXT._intervals.instances) do
    if interval.id == aura_env.intervalIDs[index] then
      match = true
    end
  end

  if match then
    print(string.format("Interval %d was not cleared", aura_env.intervalIDs[index]))
  else
    print(string.format("Interval %d was cleared", aura_env.intervalIDs[index]))
  end

  return false
end

-- SOLTI_TEST_INTERVAL_WIPE_STATE
function Trigger6(event)
  if event == "OPTIONS" then
    return false
  end

  for i = 1, #aura_env.intervalIDs do
    aura_env.CONTEXT:ClearInterval(aura_env.intervalIDs[i])
  end

  aura_env.intervalIDs = {}
end

-- /run local evt,evt_fn="SOLTI_TEST_SET_INTERVAL",WeakAuras.ScanEvents;evt_fn(evt,3);evt_fn(evt,1);
-- expect:
-- "index: 2, timeout ID: 2, executed after: 1, original delay: 1"
-- "index: 2, timeout ID: 2, executed after: 2, original delay: 1"
-- "index: 2, timeout ID: 2, executed after: 3, original delay: 1"
-- "index: 1, timeout ID: 1, executed after: 3, original delay: 3"  x
-- "index: 2, timeout ID: 2, executed after: 4, original delay: 1"
-- "index: 2, timeout ID: 2, executed after: 5, original delay: 1"
-- "index: 2, timeout ID: 2, executed after: 6, original delay: 1"
-- "index: 1, timeout ID: 1, executed after: 6, original delay: 3"  x
-- continue like that

-- /run WeakAuras.ScanEvents("SOLTI_TEST_INTERVAL_WIPE_STATE")
--expect:
-- "Interval 1 was cleared"
-- "Interval 2 was cleared"
-- intervals stop printing

-- /run local evt,evt_clr,evt_fn="SOLTI_TEST_SET_INTERVAL","SOLTI_TEST_CLEAR_INTERVAL",WeakAuras.ScanEvents;evt_fn(evt,3)evt_fn(evt,-1);evt_fn(evt,0);evt_fn(evt_clr,1);
-- expect:
-- "Timeout 3 was cleared"
-- "index: 2, timeout ID: 4, executed after: 0, original delay: -1"
-- "index: 3, timeout ID: 5, executed after: 0, original delay: 0"
-- "index: 2, timeout ID: 4, executed after: 0, original delay: -1"
-- "index: 3, timeout ID: 5, executed after: 0, original delay: 0"
-- continue like that

-- /run WeakAuras.ScanEvents("SOLTI_TEST_SET_INTERVAL", 3, 123)
-- expect:
-- "index: 2, timeout ID: 4, executed after: 0, original delay: -1, argument: 123"


-- /run WeakAuras.ScanEvents("SOLTI_TEST_INTERVAL_WIPE_STATE")


-- SOLTI_TEST_AUGMENT_DBM
function Trigger7(event)
  if event == "OPTIONS" then
    return false
  end

  aura_env.CONTEXT.pendingAugmentDBM["Brutallus"] = function(mod)
    print(string.format("%s mod augmented.", mod.Name))
  end
end

-- /run WeakAuras.ScanEvents("SOLTI_TEST_AUGMENT_DBM")
-- expect:
-- "Brutallus mod augmented."
-- once

-- /run print(LibStub("SoltiSunwellPackContext").pendingAugmentDBM["Brutallus"])
-- expect:
-- nil

-- /run print(DBM:GetMod("Brutallus").isAugmentedBySolti)
-- expect:
-- "true"

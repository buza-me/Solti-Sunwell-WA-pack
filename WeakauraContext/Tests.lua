function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.Context = LibStub(LIB_NAME)
  aura_env.timeoutIDs = {}
end

-- SOLTI_TEST_SET_TIMEOUT
function Trigger1(event, delay)
  if event == "OPTIONS" or not delay then
    return false
  end

  local start = GetTime()
  local index = #aura_env.timeoutIDs + 1

  local timeoutID = aura_env.Context:SetTimeout(
    function()
      print(
        string.format(
          "index: %d, timeout ID: %d, executed after: %d, original delay: %d",
          index,
          aura_env.timeoutIDs[index],
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

  aura_env.Context:ClearTimeout(aura_env.timeoutIDs[index])

  local match = false

  for _, timeout in pairs(aura_env.Context._timeouts.instances) do
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
-- "index: 4, timeout ID: 9, executed after: ~0.1, original delay: -1"
-- "index: 5, timeout ID: 10, executed after: ~0.1, original delay: 0"
-- "index: 2, timeout ID: 7, executed after: ~1, original delay: 1"
-- "index: 1, timeout ID: 6, executed after: ~3, original delay: 3"

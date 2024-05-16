function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)

  aura_env.CHAT_MSG_ADDON_PREFIX = "SOLTI_WA_GAS_NOVA"
  aura_env.UPDATE_EVENT_TRIGGER = "GAS_NOVA_RANGE_MESSAGES_UPDATE"
  aura_env.savedState = { messages = {}, debounceTimeoutID = nil }
end

-- CHAT_MSG_ADDON
function Trigger1(event, prefix, text, channel, sender)
  if prefix ~= aura_env.CHAT_MSG_ADDON_PREFIX then
    return false
  end

  local state = aura_env.savedState

  state.messages[sender] = text

  if state.debounceTimeoutID then
    return false
  end

  local event = aura_env.UPDATE_EVENT_TRIGGER

  local timeoutID = aura_env.CONTEXT:SetTimeout(
    function()
      local messages = state.messages
      state.messages = {}
      state.debounceTimeoutID = nil

      WeakAuras.ScanEvents(
        event,
        messages
      )
    end,
    0.020
  )

  state.debounceTimeoutID = timeoutID

  return false
end

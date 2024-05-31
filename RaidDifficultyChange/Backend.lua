function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
  aura_env.CONTEXT.onInit = aura_env.CONTEXT.onInit or {}
  aura_env.CONTEXT.states = aura_env.CONTEXT.states or {}
  aura_env.MESSAGES = {
    ["Dungeon Difficulty set to Normal. (All saved instances have been reset)"] = true,
    ["Dungeon Difficulty set to Heroic. (All saved instances have been reset)"] = true,
  }
  aura_env.TRIGGER_EVENT = "SOLTI_SUNWELL_DIFFICULTY_CHANGE_TRIGGER"

  function aura_env:ScheduleDifficultyCheck()
    local env = aura_env
    table.insert(
      env.CONTEXT.onInit,
      function()
        local isHeroic = env.CONTEXT:IsHeroic()
        local difficulty = env.CONTEXT.states.difficulty or { isHeroic = isHeroic }
        env.CONTEXT.states.difficulty = difficulty

        if difficulty.isHeroic ~= isHeroic then
          WeakAuras.ScanEvents(env.TRIGGER_EVENT, true)
        end
      end
    )
  end

  aura_env:ScheduleDifficultyCheck()
end

-- CHAT_MSG_SYSTEM
function Trigger1(event, message)
  if not aura_env.CONTEXT.isInitialized then
    return false
  end

  if WeakAuras.IsOptionsOpen() then
    aura_env:ScheduleDifficultyCheck()
  end

  if aura_env.MESSAGES[message] then
    WeakAuras.ScanEvents(aura_env.TRIGGER_EVENT, true)
  end

  return false
end

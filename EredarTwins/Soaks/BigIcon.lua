function Init()
  aura_env.TYPES = {
    "Fire",
    "Shadow",
  }
  aura_env.ICONS = {
    "Interface\\Icons\\INV_Misc_Gem_Pearl_04",
    "Interface\\Icons\\INV_Enchant_VoidSphere"
  }
end

-- SOLTI_SUNWELL_TWINS_SOAK_TRIGGER_SELF
function Trigger1(allStates, event, type, zone, phase, soakWave, duration, expirationTime)
  if event == "OPTIONS" then
    return allStates
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.changed = true
  state.show = duration > 0
  state.duration = duration
  state.expirationTime = expirationTime
  state.icon = aura_env.ICONS[type]
  state.type = aura_env.TYPES[type]
  state.zone = zone
  state.phase = phase
  state.soakWave = soakWave

  allStates[""] = state

  return allStates
end

local trigger1CustomVariables =
{
  duration = "number",
  expirationTime = "number",
  type = "string",
  zone = "number",
  phase = "number",
  soakWave = "number",
}

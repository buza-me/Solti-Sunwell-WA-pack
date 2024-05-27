function Init()
  aura_env.TYPES = {
    "Fire",
    "Shadow",
  }
end

-- SOLTI_SUNWELL_TWINS_SOAK_TRIGGER_SELF
function Trigger1(allStates, event, type, zone, phase, totalSoakNumber, secondPhaseSoakNumber, duration, expirationTime)
  if event == "OPTIONS" or not type then
    return allStates
  end

  duration = duration or 0

  local state = allStates[""] or { autoHide = true, progressType = "timed" }

  state.changed = true
  state.show = duration > 0
  state.duration = duration
  state.expirationTime = expirationTime
  state.type = aura_env.TYPES[type]
  state.zone = zone
  state.phase = phase
  state.totalSoakNumber = totalSoakNumber
  state.secondPhaseSoakNumber = secondPhaseSoakNumber

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
  totalSoakNumber = "number",
  secondPhaseSoakNumber = "number",
}

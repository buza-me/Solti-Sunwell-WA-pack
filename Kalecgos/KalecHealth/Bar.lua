-- SOLTI_WA_KALECGOS_HEALTH__DEMON_BAR_UPDATE or SOLTI_WA_KALECGOS_HEALTH__DRAGON_BAR_UPDATE
function Trigger1(allStates, event, currentHealth, maxHealth)
  if not currentHealth or not maxHealth then
    return allStates
  end

  local value

  if currentHealth == 0 then
    value = currentHealth
  else
    value = math.ceil(currentHealth / maxHealth * 1000) / 10
  end

  local state = allStates[""] or {
    progressType = "static",
    total = 100,
    value = 100,
    changed = true,
    show = true
  }

  state.value = value
  state.changed = true
  state.show = true

  allStates[""] = state

  return true
end

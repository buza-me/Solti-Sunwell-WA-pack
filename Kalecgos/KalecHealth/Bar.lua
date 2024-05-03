function Trigger1(allStates, event, currentHealth, maxHealth)
  allStates[""] = allStates[""] or {
    progressType = "static",
    total = 100,
    value = 100,
    changed = true,
    show = true
  }

  if not currentHealth or not maxHealth then
    return allStates
  end

  local value

  if currentHealth == 0 then
    value = currentHealth
  else
    value = math.ceil(currentHealth / maxHealth * 1000) / 10
  end

  local allStatesUpdate = {
    value   = value,
    changed = true,
    show    = true,
  }

  for k, v in pairs(allStatesUpdate) do
    allStates[""][k] = v
  end

  return true
end

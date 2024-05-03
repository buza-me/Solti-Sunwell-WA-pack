function Qq(expirationTime, rawDuration, progress, formattedDuration, name, icon, stacks)
  local shouldThrottle = aura_env.lastUpdateTime and (GetTime() - aura_env.lastUpdateTime < 0.5)
  local shouldUpdate = not shouldThrottle and tonumber(progress) ~= nil

  if shouldUpdate then
    aura_env.text = tostring(math.ceil(tonumber(progress)))
    aura_env.lastUpdateTime = GetTime()
  end

  return aura_env.text or ""
end

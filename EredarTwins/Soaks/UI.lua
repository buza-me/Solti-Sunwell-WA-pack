function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  aura_env.CONTEXT = LibStub(LIB_NAME)
  aura_env.SOAKERS_STUB_EMPTY = { { {}, {}, {}, {}, {}, {}, }, { {}, {}, {}, {}, {}, {}, } }
  aura_env.SOAKERS_STUB_FILLED = {
    {
      { "Arenagodx" },
      { UnitName("player") },
      { "Pvegod" },
      { "Borntosoak" },
      { "Johndoe" },
      { "Bestbackup",      "Ugh" }
    },
    {
      { "Pvegod" },
      { "Borntosoak" },
      { "Arenagodx" },
      { "Johndoe" },
      { "Xd" },
      { "Worstbackup", "Pvpgodx" }
    },
  }

  function aura_env:PaintText(text)
    local color = "32ff32"
    return string.format("|cff%s%s|r", color, text)
  end
end

-- SOLTI_SUNWELL_TWINS_SOAK_TRIGGER
function Trigger1(allStates, event, soakers, phase, totalSoakNumber, secondPhaseSoakNumber, duration, expirationTime)
  if not aura_env.CONTEXT.isInitialized or not soakers then
    return allStates
  end

  local soakNumber = totalSoakNumber

  if phase == 2 then
    soakNumber = secondPhaseSoakNumber
  end

  if event == "OPTIONS" or not soakers or not phase or not soakNumber then
    if WeakAuras.IsOptionsOpen() then
      soakers = aura_env.SOAKERS_STUB_FILLED
    else
      soakers = aura_env.SOAKERS_STUB_EMPTY
    end
    phase = 1
    soakNumber = 1
  end

  local phaseText = string.format("Phase        %d", phase)
  local soakNumberText = string.format("Soak wave    %d", soakNumber)
  local assignmentsText = "Fire:\n"

  for zoneIndex = 1, #soakers[1] do
    if zoneIndex <= 5 then
      local name = soakers[1][zoneIndex][1] or ""

      local line = string.format("%d   %s", zoneIndex, name)

      if aura_env.CONTEXT:IsMyName(name) then
        line = aura_env:PaintText(line)
      end

      assignmentsText = string.format("%s%s\n", assignmentsText, line)
    else
      assignmentsText = string.format(
        "%s\nFire backup:\n%s\n",
        assignmentsText,
        table.concat(soakers[1][zoneIndex], "\n")
      )
    end
  end

  assignmentsText = string.format("%s%s", assignmentsText, "\n\n")
  assignmentsText = string.format("%s%s", assignmentsText, "Shadow:\n")

  for zoneIndex = 1, #soakers[2] do
    if zoneIndex <= 5 then
      local name = soakers[2][zoneIndex][1] or ""

      local line = string.format("%d   %s", zoneIndex, name)

      if aura_env.CONTEXT:IsMyName(name) then
        line = aura_env:PaintText(line)
      end

      assignmentsText = string.format("%s%s\n", assignmentsText, line)
    else
      assignmentsText = string.format(
        "%s\nShadow backup:\n%s\n",
        assignmentsText,
        table.concat(soakers[2][zoneIndex], "\n")
      )
    end
  end

  local state = allStates[""] or { progressType = "static" }

  state.changed = true
  state.show = true
  state.value = 1
  state.total = 1
  state.phaseText = phaseText
  state.soakNumberText = soakNumberText
  state.assignmentsText = assignmentsText

  allStates[""] = state

  return allStates
end

local trigger1CustomVariables =
{ phaseText = "string", soakNumberText = "string", assignmentsText = "string" }

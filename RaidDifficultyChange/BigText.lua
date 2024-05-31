-- SOLTI_SUNWELL_DIFFICULTY_CHANGE_TRIGGER
function Trigger1(event, shouldDisplay)
  return event ~= "OPTIONS" and shouldDisplay
end

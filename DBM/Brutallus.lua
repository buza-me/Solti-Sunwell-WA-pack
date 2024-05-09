function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  local Context = LibStub(LIB_NAME)

  Context.pendingAugmentDBM = Context.pendingAugmentDBM or {}

  Context.pendingAugmentDBM["Brutallus"] = function(Mod, options)
    Mod:RegisterEvents(
      "CHAT_MSG_MONSTER_EMOTE"
    )

    Mod:AddOption(
      "UseSoltiMod",
      Context:UseFallback(options.UseSoltiMod, true),
      "Use Solti Netherwing boss mod patches"
    )
    Mod:AddOption(
      "WarnDoomfire",
      Context:UseFallback(options.WarnDoomfire, true),
      "Show Doomfire timers"
    )
    Mod:AddOption(
      "WarnArmageddon",
      Context:UseFallback(options.WarnArmageddon, true),
      "Show Armageddon timers"
    )

    local NO_BROADCAST = not aura_env.config.shouldBroadcast
    local lastDoomfireSync = 0
    local DOOMFIRE_SYNC_THROTTLE = 1
    local SPELL_IDS = {
      BURN = 46394,
      STOMP = 45185,
      METEOR_SLASH = 45150,
      ARMAGEDDON = 20478,
      DOOMFIRE = 31944
    }
    local SYNC_EVENTS = {
      -- [SPELL_IDS.BURN] = "Burn",
      -- [SPELL_IDS.STOMP] = "Stomp",
      -- [SPELL_IDS.METEOR_SLASH] = "Meteor Slash",
      [SPELL_IDS.ARMAGEDDON] = "Armageddon",
      [SPELL_IDS.DOOMFIRE] = "Doomfire"
    }

    local ANNOUNCE = {
      [SPELL_IDS.BURN] = "Next Burn",
      -- [SPELL_IDS.STOMP] = "Next Stomp",
      -- [SPELL_IDS.METEOR_SLASH] = "Next Meteor Slash",
      [SPELL_IDS.ARMAGEDDON] = "Next Armageddon",
      [SPELL_IDS.DOOMFIRE] = "Next Doomfire"
    }

    local ANNOUNCE_TARGET = {
      [SPELL_IDS.ARMAGEDDON] = "Armageddon builds on "
    }

    local OnCombatStart = Mod.OnCombatStart
    function Mod:OnCombatStart(delay)
      OnCombatStart(self, delay)

      if not self.Options.UseSoltiMod or not Context:IsHeroic() then
        return
      end

      self:StartStatusBarTimer(20 - delay, ANNOUNCE[SPELL_IDS.BURN], SPELL_IDS.BURN, NO_BROADCAST)

      if self.Options.WarnDoomfire then
        self:StartStatusBarTimer(20 - delay, ANNOUNCE[SPELL_IDS.DOOMFIRE], SPELL_IDS.DOOMFIRE, NO_BROADCAST)
      end

      if self.Options.WarnArmageddon then
        self:StartStatusBarTimer(40 - delay, ANNOUNCE[SPELL_IDS.ARMAGEDDON], SPELL_IDS.ARMAGEDDON, NO_BROADCAST)
      end
    end

    local OnEvent = Mod.OnEvent
    function Mod:OnEvent(event, args)
      OnEvent(self, event, args)

      if not self.Options.UseSoltiMod or not Context:IsHeroic() then
        return
      end

      local syncEvent = SYNC_EVENTS[args.spellId]

      if not syncEvent or event ~= "SPELL_AURA_APPLIED" then
        return
      end

      if args.spellId == SPELL_IDS.DOOMFIRE and self.Options.WarnDoomfire then
        self:SendSync(syncEvent .. tostring(args.destName))
      end

      if args.spellId == SPELL_IDS.ARMAGEDDON and self.Options.WarnArmageddon then
        self:SendSync(syncEvent .. tostring(args.destName))
      end
    end

    local OnSync = Mod.OnSync
    function Mod:OnSync(msg)
      OnSync(self, msg)

      if not self.Options.UseSoltiMod or not Context:IsHeroic() then
        return
      end

      local shouldShowArmageddonTimers =
          Context:StartsWith(msg, SYNC_EVENTS[SPELL_IDS.ARMAGEDDON])
          and self.Options.WarnArmageddon

      local shouldShowDoomfireTimers =
          Context:StartsWith(msg, SYNC_EVENTS[SPELL_IDS.DOOMFIRE])
          and GetTime() - lastDoomfireSync > DOOMFIRE_SYNC_THROTTLE
          and self.Options.WarnDoomfire

      if shouldShowArmageddonTimers then
        local name = Context:OmitPrefix(msg, SYNC_EVENTS[SPELL_IDS.ARMAGEDDON])
        self:Announce(ANNOUNCE_TARGET[SPELL_IDS.ARMAGEDDON] .. name, 1)
        self:StartStatusBarTimer(10, ANNOUNCE_TARGET[SPELL_IDS.ARMAGEDDON] .. name, SPELL_IDS.ARMAGEDDON, NO_BROADCAST)
        self:StartStatusBarTimer(40, ANNOUNCE[SPELL_IDS.ARMAGEDDON], SPELL_IDS.ARMAGEDDON, NO_BROADCAST)
      elseif shouldShowDoomfireTimers then
        lastDoomfireSync = GetTime()
        self:StartStatusBarTimer(40, ANNOUNCE[SPELL_IDS.DOOMFIRE], SPELL_IDS.DOOMFIRE, NO_BROADCAST)
      end
    end
  end
end

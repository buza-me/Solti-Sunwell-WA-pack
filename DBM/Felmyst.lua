function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  local Context = LibStub(LIB_NAME)

  Context.pendingAugmentDBM = Context.pendingAugmentDBM or {}

  Context.pendingAugmentDBM["Felmyst"] = function(Mod, options)
    Mod:AddOption(
      "UseSoltiMod",
      Context:UseFallback(options.UseSoltiMod, true),
      "Use Solti Netherwing boss mod patches"
    )
    Mod:AddOption(
      "WarnEncapsulate",
      Context:UseFallback(options.WarnEncapsulate, true),
      "Warn before Encapsulate cooldown ends"
    )
    Mod:AddOption(
      "TrackEncapsulate",
      Context:UseFallback(options.TrackEncapsulate, true),
      "Show Encapsulate CD"
    )

    local NO_BROADCAST = not aura_env.config.shouldBroadcast
    local WARN_DELAY = 3
    local DELAY_AFTER_AIR_PHASE = -5
    local isAirPhase = false

    local SPELL_IDS = {
      GAS_NOVA = 45855,
      ENCAPSULATE = 45665,
    }

    local TIMERS = {
      [SPELL_IDS.GAS_NOVA] = 20,
      [SPELL_IDS.ENCAPSULATE] = 28,
      AIR_PHASE = 69
    }

    local SYNC_EVENTS = {
      [SPELL_IDS.GAS_NOVA] = "GasNova",
      [SPELL_IDS.ENCAPSULATE] = "Encaps",
      AIR_PHASE = "Air",
      GROUND_PHASE = "Ground"
    }

    local ANNOUNCE_DBM = {
      [SPELL_IDS.GAS_NOVA] = {
        STATUS = "Next Gas Nova",
        WARN = "Next Gas Nova"
      },
      AIR_PHASE = "Air Phase"
    }

    local ANNOUNCE = {
      [SPELL_IDS.GAS_NOVA] = {
        STATUS = "Gas Nova Cooldown",
        WARN = "Gas Nova soon"
      },
      [SPELL_IDS.ENCAPSULATE] = {
        STATUS = "Encapsulate Cooldown",
        WARN = "Encapsulate soon"
      },
      AIR_PHASE = "Air Phase"
    }

    local ENRAGE = {
      NAME = "Enrage",
      ICON = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
      TIME = 540,
      ANNOUNCES = {
        FIVE_MINUTES = DBM_GENERIC_ENRAGE_WARN:format(5, DBM_MIN),
        THREE_MINUTES = DBM_GENERIC_ENRAGE_WARN:format(3, DBM_MIN),
        ONE_MINUTE = DBM_GENERIC_ENRAGE_WARN:format(1, DBM_MIN),
        THIRTY_SECONDS = DBM_GENERIC_ENRAGE_WARN:format(30, DBM_SEC),
        TEN_SECONDS = DBM_GENERIC_ENRAGE_WARN:format(10, DBM_SEC)
      }
    }

    function Mod:SoltiMod_UnScheduleEnrageTimers()
      self:EndStatusBarTimer(ENRAGE.NAME, NO_BROADCAST)
      self:UnScheduleAnnounce(ENRAGE.ANNOUNCES.FIVE_MINUTES, NO_BROADCAST)
      self:UnScheduleAnnounce(ENRAGE.ANNOUNCES.THREE_MINUTES, NO_BROADCAST)
      self:UnScheduleAnnounce(ENRAGE.ANNOUNCES.ONE_MINUTE, NO_BROADCAST)
      self:UnScheduleAnnounce(ENRAGE.ANNOUNCES.THIRTY_SECONDS, NO_BROADCAST)
      self:UnScheduleAnnounce(ENRAGE.ANNOUNCES.TEN_SECONDS, NO_BROADCAST)
    end

    function Mod:SoltiMod_ScheduleEnrageTimers(delay)
      self:StartStatusBarTimer(ENRAGE.TIME - delay, ENRAGE.NAME, ENRAGE.ICON, NO_BROADCAST)
      self:ScheduleAnnounce(240 - delay, ENRAGE.ANNOUNCES.FIVE_MINUTES, 1, NO_BROADCAST)
      self:ScheduleAnnounce(360 - delay, ENRAGE.ANNOUNCES.THREE_MINUTES, 1, NO_BROADCAST)
      self:ScheduleAnnounce(480 - delay, ENRAGE.ANNOUNCES.ONE_MINUTE, 2, NO_BROADCAST)
      self:ScheduleAnnounce(510 - delay, ENRAGE.ANNOUNCES.THIRTY_SECONDS, 3, NO_BROADCAST)
      self:ScheduleAnnounce(530 - delay, ENRAGE.ANNOUNCES.TEN_SECONDS, 4, NO_BROADCAST)
    end

    function Mod:SoltiMod_EndAirPhaseStatusBarTimer()
      self:EndStatusBarTimer(ANNOUNCE_DBM.AIR_PHASE, NO_BROADCAST)
    end

    function Mod:SoltiMod_StartAirPhaseStatusBarTimer(delay)
      self:StartStatusBarTimer(
        TIMERS.AIR_PHASE - delay,
        ANNOUNCE.AIR_PHASE,
        "Interface\\AddOns\\DBM_API\\Textures\\CryptFiendUnBurrow",
        NO_BROADCAST
      )
    end

    function Mod:SoltiMod_ScheduleGasNovaAnnounce(delay)
      self:ScheduleAnnounce(
        TIMERS[SPELL_IDS.GAS_NOVA] - delay,
        ANNOUNCE[SPELL_IDS.GAS_NOVA].WARN,
        1,
        NO_BROADCAST
      )
    end

    function Mod:SoltiMod_UnScheduleGasNovaAnnounce()
      self:UnScheduleAnnounce("Gas Nova soon", NO_BROADCAST)
      self:UnScheduleAnnounce("Gasnova bald", NO_BROADCAST)
      self:UnScheduleAnnounce("毒气新星 - 即将施放", NO_BROADCAST)
      self:UnScheduleAnnounce("毒氣新星 即將發動", NO_BROADCAST)
      self:UnScheduleAnnounce(ANNOUNCE[SPELL_IDS.GAS_NOVA].WARN, NO_BROADCAST)
    end

    function Mod:SoltiMod_StartGasNovaStatusBarTimer(delay)
      self:StartStatusBarTimer(
        TIMERS[SPELL_IDS.GAS_NOVA] - delay,
        ANNOUNCE[SPELL_IDS.GAS_NOVA].STATUS,
        SPELL_IDS.GAS_NOVA,
        NO_BROADCAST
      )
    end

    function Mod:SoltiMod_EndGasNovaStatusBarTimer()
      self:EndStatusBarTimer(ANNOUNCE_DBM[SPELL_IDS.GAS_NOVA].STATUS, NO_BROADCAST)
      self:EndStatusBarTimer(ANNOUNCE[SPELL_IDS.GAS_NOVA].STATUS, NO_BROADCAST)
    end

    function Mod:SoltiMod_ScheduleEncapsulateAnnounce(delay)
      self:ScheduleAnnounce(
        TIMERS[SPELL_IDS.ENCAPSULATE] - delay,
        ANNOUNCE[SPELL_IDS.ENCAPSULATE].WARN,
        1,
        NO_BROADCAST
      )
    end

    function Mod:SoltiMod_UnScheduleEncapsulateAnnounce()
      self:UnScheduleAnnounce(ANNOUNCE[SPELL_IDS.ENCAPSULATE].WARN, NO_BROADCAST)
    end

    function Mod:SoltiMod_StartEncapsulateStatusBarTimer(delay)
      self:StartStatusBarTimer(
        TIMERS[SPELL_IDS.ENCAPSULATE] - delay,
        ANNOUNCE[SPELL_IDS.ENCAPSULATE].STATUS,
        SPELL_IDS.ENCAPSULATE,
        NO_BROADCAST
      )
    end

    function Mod:SoltiMod_EndEncapsulateStatusBarTimer()
      self:EndStatusBarTimer(ANNOUNCE[SPELL_IDS.ENCAPSULATE].STATUS, NO_BROADCAST)
    end

    function Mod:SoltiMod_InitGroundPhase(delay)
      self:SoltiMod_EndAirPhaseStatusBarTimer()
      self:SoltiMod_StartAirPhaseStatusBarTimer(delay)

      self:SoltiMod_EndGasNovaStatusBarTimer()
      self:SoltiMod_StartGasNovaStatusBarTimer(delay)

      if self.Options.GasSoonWarn then
        self:SoltiMod_UnScheduleGasNovaAnnounce()
        self:SoltiMod_ScheduleGasNovaAnnounce(delay + WARN_DELAY)
      end

      if self.Options.WarnEncapsulate then
        self:SoltiMod_ScheduleEncapsulateAnnounce(delay + WARN_DELAY)
      end

      if self.Options.TrackEncapsulate then
        self:SoltiMod_StartEncapsulateStatusBarTimer(delay)
      end
    end

    --------------------------------------------------------------------------
    --------------------------------------------------------------------------
    --------------------------------------------------------------------------

    local OnCombatStart = Mod.OnCombatStart
    function Mod:OnCombatStart(delay)
      if not self.Options.UseSoltiMod or not Context:IsHeroic() then
        OnCombatStart(self, delay)
        return
      end

      isAirPhase = false

      OnCombatStart(self, delay)

      self:SoltiMod_UnScheduleEnrageTimers()
      self:SoltiMod_ScheduleEnrageTimers(delay)
      self:SoltiMod_InitGroundPhase(delay)
    end

    local OnEvent = Mod.OnEvent
    function Mod:OnEvent(event, args)
      OnEvent(self, event, args)
    end

    local OnSync = Mod.OnSync
    function Mod:OnSync(msg)
      OnSync(self, msg)

      if not self.Options.UseSoltiMod or not Context:IsHeroic() then
        return
      end

      if Context:StartsWith(msg, SYNC_EVENTS[SPELL_IDS.GAS_NOVA]) then
        self:SoltiMod_EndGasNovaStatusBarTimer()
        self:SoltiMod_StartGasNovaStatusBarTimer(0)

        if self.Options.GasSoonWarn then
          self:SoltiMod_UnScheduleGasNovaAnnounce()
          self:SoltiMod_ScheduleGasNovaAnnounce(WARN_DELAY)
        end
      elseif Context:StartsWith(msg, SYNC_EVENTS[SPELL_IDS.ENCAPSULATE]) then
        if self.Options.WarnEncapsulate then
          self:SoltiMod_ScheduleEncapsulateAnnounce(WARN_DELAY)
        end
        if self.Options.TrackEncapsulate then
          self:SoltiMod_StartEncapsulateStatusBarTimer(0)
        end
      elseif Context:StartsWith(msg, SYNC_EVENTS.AIR_PHASE) and not isAirPhase then
        isAirPhase = true
        self:SoltiMod_UnScheduleGasNovaAnnounce()
        self:SoltiMod_UnScheduleEncapsulateAnnounce()
        self:SoltiMod_EndGasNovaStatusBarTimer()
        self:SoltiMod_EndEncapsulateStatusBarTimer()
      elseif Context:StartsWith(msg, SYNC_EVENTS.GROUND_PHASE) then
        isAirPhase = false
        self:SoltiMod_InitGroundPhase(DELAY_AFTER_AIR_PHASE)
      end
    end
  end
end

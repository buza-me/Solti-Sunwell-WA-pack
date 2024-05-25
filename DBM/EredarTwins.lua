function Init()
  local LIB_NAME = "SoltiSunwellPackContext"
  LibStub:NewLibrary(LIB_NAME, 1)
  local Context = LibStub(LIB_NAME)

  Context.pendingAugmentDBM = Context.pendingAugmentDBM or {}

  Context.pendingAugmentDBM["Twins"] = function(Mod, options)
    local NO_BROADCAST = not aura_env.config.shouldBroadcast

    local phase = 1
    local soaks_count = 1
    local conflag_count = 1
    local shadow_nova_count = 1
    local current_vulnerability = "Unknown"

    Mod:RegisterCombat("COMBAT", 2, DBM_TWINS_MOB_WL, DBM_TWINS_NAME, { DBM_TWINS_MOB_WL, DBM_TWINS_MOB_SOCR })

    Mod:AddOption(
      "UseSoltiMod",
      Context:UseFallback(options.UseSoltiMod, true),
      "Use Solti Netherwing boss mod patches"
    )

    --Alythess Options
    Mod:AddOption(
      "WhisperConflag",
      Context:UseFallback(options.WhisperConflag, true),
      DBM_TWINS_OPTION_CONFLAG2
    )
    Mod:AddOption(
      "SpecWarnConflag",
      Context:UseFallback(options.SpecWarnConflag, true),
      DBM_TWINS_OPTION_CONFLAG3
    )
    Mod:AddOption(
      "IconConflag",
      Context:UseFallback(options.IconConflag, true),
      DBM_TWINS_OPTION_CONFLAG4
    )
    Mod:AddOption(
      "SoundWarnConflag",
      Context:UseFallback(options.SoundWarnConflag, true),
      DBM_TWINS_OPTION_CONFLAG5
    )

    --Sacrolash Options
    Mod:AddOption(
      "WhisperNova",
      Context:UseFallback(options.WhisperNova, true),
      DBM_TWINS_OPTION_NOVA2
    )
    Mod:AddOption(
      "SpecWarnNova",
      Context:UseFallback(options.SpecWarnNova, true),
      DBM_TWINS_OPTION_NOVA3
    )
    Mod:AddOption(
      "IconNova",
      Context:UseFallback(options.IconNova, false),
      DBM_TWINS_OPTION_NOVA4
    )

    --General Options
    Mod:AddOption(
      "VulnFilter",
      Context:UseFallback(options.VulnFilter, false),
      "Only show timers related to your vulnerability"
    )
    Mod:AddOption(
      "DarkTouch",
      Context:UseFallback(options.DarkTouch, true),
      DBM_TWINS_OPTION_TOUCH1
    )
    Mod:AddOption(
      "FlameTouch",
      Context:UseFallback(options.FlameTouch, false),
      DBM_TWINS_OPTION_TOUCH2
    )

    --Timers
    Mod:AddBarOption(
      "Enrage",
      Context:UseFallback(options["BAR" .. "Enrage"], true)
    )
    Mod:AddBarOption(
      "Next Conflagration",
      Context:UseFallback(options["BAR" .. "Next Conflagration"], true)
    )
    Mod:AddBarOption(
      "Next Shadow Nova",
      Context:UseFallback(options["BAR" .. "Next Shadow Nova"], true)
    )
    Mod:AddBarOption(
      "Next Circle Soaks",
      Context:UseFallback(options["BAR" .. "Next Circle Soaks"], true)
    )
    Mod:AddBarOption(
      "Next Inferno",
      Context:UseFallback(options["BAR" .. "Next Inferno"], true)
    )
    Mod:AddBarOption(
      "Next Dark Spin",
      Context:UseFallback(options["BAR" .. "Next Dark Spin"], true)
    )
    Mod:AddBarOption(
      "Next Vulnerability Swap",
      Context:UseFallback(options["BAR" .. "Next Vulnerability Swap"], true)
    )
    Mod:AddBarOption(
      "10 second kill window",
      Context:UseFallback(options["BAR" .. "10 second kill window"], true)
    )

    Mod:RegisterEvents(
      "SPELL_CAST_START",
      "SPELL_CAST_SUCCESS",
      "SPELL_AURA_APPLIED",
      "SPELL_AURA_REMOVED",
      "SPELL_DAMAGE",
      "CHAT_MSG_RAID_BOSS_EMOTE",
      "SPELL_AURA_APPLIED_DOSE"
    )

    local OnCombatStart = Mod.OnCombatStart
    function Mod:OnCombatStart(delay)
      if not self.Options.UseSoltiMod or not Context:IsHeroic() then
        OnCombatStart(self, delay)
        return
      end

      phase = 1
      current_vulnerability = "Unknown"
      soaks_count = 1
      conflag_count = 1
      shadow_nova_count = 1

      self:StartStatusBarTimer(360 - delay, "Enrage", "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
    end

    local OnEvent = Mod.OnEvent
    function Mod:OnEvent(event, args)
      if not self.Options.UseSoltiMod or not Context:IsHeroic() then
        OnEvent(self, event, args)
        return
      end

      if event == "SPELL_CAST_SUCCESS" then
        if args.spellId == 22959 then --Fire Vulnerability casted
          self:ScheduleSelf(1, "VulnerabilitySwap")
        elseif args.spellId == 19695 and phase == 2 then
          self:StartStatusBarTimer(75, "Next Inferno", "Interface\\Icons\\Spell_Fire_Incinerate")
        end
      elseif event == "SPELL_CAST_START" then
        if args.spellId == 45342 and phase == 2 then --conflag
          conflag_count = conflag_count + 1
          if conflag_count % 2 == 0 then
            self:StartStatusBarTimer(30, "Next Conflagration", "Interface\\Icons\\Spell_Fire_Fireball02")
          else
            self:StartStatusBarTimer(45, "Next Conflagration", "Interface\\Icons\\Spell_Fire_Fireball02")
          end
        elseif args.spellId == 45329 and phase == 2 then --shadow nova
          shadow_nova_count = shadow_nova_count + 1
          if shadow_nova_count % 2 == 0 then
            self:StartStatusBarTimer(30, "Next Shadow Nova", 45329)
          else
            self:StartStatusBarTimer(45, "Next Shadow Nova", 45329)
          end
        end
      elseif event == "VulnerabilitySwap" then
        for i = 1, 12 do
          local debuffName = UnitDebuff("player", i)
          if debuffName ~= nil then
            if debuffName == "Shadow Shell" then current_vulnerability = "Shadow" end
            if debuffName == "Growing Flames" then current_vulnerability = "Fire" end
          end
        end

        self:StartStatusBarTimer(14, "Next Circle Soaks", "Interface\\Icons\\Spell_Arcane_Blast")
        self:ScheduleSelf(14, "Circle Soaks");

        if not self.Options.VulnFilter or current_vulnerability == "Fire" then
          self:StartStatusBarTimer(24, "Next Conflagration", "Interface\\Icons\\Spell_Fire_Fireball02")
          self:ScheduleSelf(24, "Conflagration");

          self:StartStatusBarTimer(29, "Next Inferno", "Interface\\Icons\\Spell_Fire_Incinerate")
          self:StartStatusBarTimer(74, "Next Vulnerability Swap", "Interface\\Icons\\Inv_Enchant_ShardGlimmeringLarge")
        end

        if not self.Options.VulnFilter or current_vulnerability == "Shadow" then
          self:StartStatusBarTimer(24, "Next Shadow Nova", 45329)
          self:ScheduleSelf(24, "Shadow Nova");

          self:StartStatusBarTimer(29, "Next Dark Spin", "Interface\\Icons\\Inv_Sword_2h_Blood_C_01")
        end
      elseif event == "Circle Soaks" then
        --this event is only used in phase 1
        self:StartStatusBarTimer(30, "Next Circle Soaks", "Interface\\Icons\\Spell_Arcane_Blast")
      elseif event == "Conflagration" then
        --this event is only used in phase 1
        self:StartStatusBarTimer(30, "Next Conflagration", "Interface\\Icons\\Spell_Fire_Fireball02")
      elseif event == "Shadow Nova" then
        --this event is only used in phase 1
        self:StartStatusBarTimer(30, "Next Shadow Nova", 45329)
      elseif event == "SPELL_AURA_APPLIED" then
        if args.spellId == 30502 and phase == 2 then
          self:StartStatusBarTimer(75, "Next Dark Spin", "Interface\\Icons\\Inv_Sword_2h_Blood_C_01")
        end
        if args.spellId == 44806 then
          self:StartStatusBarTimer(9.5, "10 second kill window", "Interface\\Icons\\Ability_Rogue_Feigndeath")
        end
      elseif event == "SPELL_AURA_APPLIED_DOSE" then
        if self.Options.DarkTouch and args.spellId == 45347 and args.destName == UnitName("player") and args.amount >= 8 then
          self:AddSpecialWarning(DBM_TWINS_SPECWARN_SHADOW:format(args.amount))
        elseif self.Options.FlameTouch and args.spellId == 45348 and args.destName == UnitName("player") and args.amount >= 5 then
          self:AddSpecialWarning(DBM_TWINS_SPECWARN_FIRE:format(args.amount))
        end
      elseif event == "CHAT_MSG_RAID_BOSS_EMOTE" then
        local _, _, target = (args or ""):find(DBM_TWINS_EMOTE_CONFLAG)
        if target then
          self:SendSync("Conflagration" .. target)
        end
        target = nil

        local _, _, target = (args or ""):find(DBM_TWINS_EMOTE_NOVA)
        if target then
          self:SendSync("ShadowNova" .. target)
        end

        if arg1 == "Magic Affinity has been disrupted!" then
          phase = 2

          self:EndStatusBarTimer("Next Conflagration")
          self:EndStatusBarTimer("Next Shadow Nova")
          self:EndStatusBarTimer("Next Circle Soaks")
          self:EndStatusBarTimer("Next Inferno")
          self:EndStatusBarTimer("Next Dark Spin")
          self:EndStatusBarTimer("Next Vulnerability Swap")
          self:EndStatusBarTimer("10 second kill window")

          self:StartStatusBarTimer(15, "Next Circle Soaks", "Interface\\Icons\\Spell_Arcane_Blast")     --after this, soak timers are handled by looking for a boss emote
          self:StartStatusBarTimer(30, "Next Inferno", "Interface\\Icons\\Spell_Fire_Incinerate")       --after this, inferno timer is handled by a SPELL_CAST_SUCCESS event
          self:StartStatusBarTimer(30, "Next Dark Spin", "Interface\\Icons\\Inv_Sword_2h_Blood_C_01")   --after this, dark spin timer is handled by a SPELL_AURA_APPLIED event
          self:StartStatusBarTimer(25, "Next Conflagration", "Interface\\Icons\\Spell_Fire_Fireball02") --after this, conflag timer is handled by a SPELL_CAST_START event
          self:StartStatusBarTimer(39, "Next Shadow Nova", 45329)                                       --after this, shadow nova timer is handled by a SPELL_CAST_START event
        elseif arg1 == "The twins begin to unleash powerful spells!" then
          soaks_count = soaks_count + 1
          if soaks_count % 2 == 0 then
            self:StartStatusBarTimer(30, "Next Circle Soaks", "Interface\\Icons\\Spell_Arcane_Blast")
          else
            self:StartStatusBarTimer(45, "Next Circle Soaks", "Interface\\Icons\\Spell_Arcane_Blast")
          end
        end
      end
    end

    local OnSync = Mod.OnSync
    function Mod:OnSync(msg)
      if not self.Options.UseSoltiMod or not Context:IsHeroic() then
        OnSync(self, msg)
        return
      end

      if msg:sub(0, 13) == "Conflagration" then
        msg = msg:sub(14)
        if self.Options.WhisperConflag then
          self:SendHiddenWhisper(DBM_TWINS_WHISPER_CONFLAG, msg)
        end
        if msg == UnitName("player") then
          if self.Options.SoundWarnConflag then
            PlaySoundFile("Sound\\Spells\\PVPFlagTaken.wav")
            PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
          end
          if self.Options.SpecWarnConflag then
            self:AddSpecialWarning(DBM_TWINS_WHISPER_CONFLAG)
          end
        end
        if self.Options.IconConflag then
          self:SetIcon(msg, 8)
        end
      elseif msg:sub(0, 10) == "ShadowNova" then
        msg = msg:sub(11)
        if self.Options.WhisperNova then
          self:SendHiddenWhisper(DBM_TWINS_WHISPER_NOVA, msg)
        end
        if msg == UnitName("player") and self.Options.SpecWarnNova then
          self:AddSpecialWarning(DBM_TWINS_WHISPER_NOVA)
        end
        if self.Options.IconNova then
          self:SetIcon(msg, 7)
        end
      end
    end
  end
end

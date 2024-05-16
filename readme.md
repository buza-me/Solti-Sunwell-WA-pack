### Requirements and recommendations for the WA pack(s). Follow the list order.

### Latest AddOn versions:

- [WeakAuras2](https://github.com/RichSteini/WeakAuras2-TBC-2.4.3/releases)
- [DBM - Netherwing](https://discord.com/channels/700662901358461028/700679285954052156/1190601570082099241)
- [SoltiCore](https://github.com/buza-me/SoltiCore) - adds human voice phrases to use in addOns, WA in particular. **(optional)**

**It is requred to use the latest release of the WA addon for this WA pack to work properly.**  
Latest release brings "Subzone name" to the "Load" tab. Subzone name is a text on your minimap.  
With the latest release you can load auras depending on a boss room. For example Kalecgos "room" names are "Apex Point" and "Inner Veil".  
All the features are split into separate subgroups and can be turned on/off as a group.  
For instance if you want to disable raid frame glows, you need to select the "Raid Frame Glows" group -> Load tab -> select "Never"  
Raid marks can be changed in the custom options, "Raid Mark" group.

WAs:

- [Anchors for the "Solti: Sunwell" Pack](https://pastebin.com/cehfj3wW)
- ["Solti: Sunwell" pack](https://pastebin.com/4q7PUgJd)
- ["Solti: Sunwell" pack with SoltiCore sounds](https://pastebin.com/09pcbfxZ) **(if you installed SoltiCore addon)**

You need to install the anchors pack first. Move things where you want them to appear during the fight, scale different elements to fit your UI scale/monitor.  
After that install the Sunwell Pack. Scale different elements to the same scale as you did for the anchors pack.  
Sunwell Pack is glued to the Anchors pack, that's why if you want to move something then you need to move the anchors, not Sunwell pack.  
Anchors are a very useful feature for cases where you reinstall or update the WA pack, this way you will not have to reposition the elements every time.  
Make sure that two raid frame debuff icons from the WA pack can fit on your raid frames, you can scale the raid frame debuffs group down if they are too large.

Known issue that I can't really fix because it seems like a game client issue:  
Because WA's addon creates a lot of 2-d game objects and the TBC client has a bug, top level frames appearing for the first time cause around a 5 seconds game freeze in some cases.  
So first ready check, first character menu open etc can sometimes freeze the game for a couple seconds.  
For the same reason you need to disable the Kalecgos DBM spectral realm frame, because by author's design it spawns top level frames every time someone gets teleported, and on combat start.

### Sunwell WA pack features.

\* Only a raid leader can send raid warnings and use raid mark features of this WA pack. On purpose.  
\* DBM timers often duplicate with Mec's DBM, so choose one. Solti WA DBM features can be toggled in the "/dbm" Sunwell boss menus.  
\* All the debuff icons show timers.

### Kalecgos:

**Arcane Bolt:**

- Triggers when the boss swaps the target during the cast. Around half a second after he starts casting.
- Target gets notified with a big icon, text message, screen glow (DBM feature) and a "Run Away" sound.
- Target sends a chat message saying "Spark on me!"
- The raid frame of a target glows with red lines and a relatively large debuff icon with "spark" text is displayed on the raid frame.
- Players close to a target (~10 yards) get notified with a big icon, text message and a "Run Away" sound.

**Curse of Boundless Agony:**

- A target gets notified with a big icon at first, at 20 seconds left a red text message saying "Run out!" appears on a screen and a notification sound is played.
- A relatively large debuff icon appears on a target's raid frame. At 15 seconds of the debuff left "decurse" message shows above the debuff icon. Purple raid frame glow is displayed for mages and druids.

**Corrupting Strike:**

- A target gets notified with a big icon with a "stunned" text message and a messenger type sound.
- A relatively large debuff icon with "stunned" text appears on top of a debuffed player's raid frame. Raid frame glows red for the stun duration.

**Void Zones:**

- Players standing in void zones get notified with a red screen glow, an "Error" sound and a "Void Zone" text.
- Players taking damage from a spark get notified with a red screen glow, an "Error" sound and a "Spark" text.

**Misc:**

- Less important debuffs and a buff like Spectral Realm, Spectral Exhaustion, Haste buff, Wild Magic and Prismatic Aura are included in the "Small Icons" group.
- The text above and below the icons explains the debuff effects.
- Kalecgos and Sathrovarr HP widget will show an accurate state of health of the both bosses in each room, if at least one player with the WA pack installed will target each of the bosses.

### Brutallus:

**DBM timers:**

- Adds Armageddon and Doomfire timers to DBM. Adds new options to the /dbm Brutallus boss mod menu.
- Should automatically be disabled in normal mode, if Wolf will fix the GetInstanceInfo() API.

**Doomfire:**

- Players with the Doomfire debuff get marked with raid marks, configurable in the custom options inside the Raid Mark group.
- Players with the Doomfire debuff get notified with a big icon, a "Link with %player" text message and a messenger type sound.
- Raid leader sends a raid warning with a text "Doomfire on %target1 and %target2".
- Player names are class colored.
- Shows a large Doomfire icon on top of debuffed players' raid frames.

**Armageddon:**

- A player with the Armageddon debuff gets notified with a big icon, "Armageddon on You!" text message and notification type sound.
- A player with the Armageddon debuff sends a "{Skull} Armageddon on me! {Skull}" chat message.
- Shows a large Armageddon icon on top of debuffed players' raid frames.
- Player with the Armageddon debuff gets marked with Skull (configurable).
- 1.8 seconds later players without Burn debuff within 15 yards of an Armageddon target get notified with a large Armageddon icon, "Stack!" text message and a "Stack" sound.
- The delay is necessary because Burn has a travel time after a cast.

**Burn:**

- A target gets notified with a big icon, "Run out!" text and a notification type sound.
- A large debuff icon is displayed on top of a debuffed player's raid frame.
- On 15 seconds left of the debuff the raid frame of a debuffed player glows red, a "focus" text message above the debuff icon is displayed.

**Stomp:**

- A target gets notified with a large icon and a notification type sound.

**Meteor Slash:**

- Included in the "Small Icons" group. When stacks are at 3 or more a red "stacks high" text appears above the icon.

### Felmyst:

**DBM timers:**

- Adds/updates Encapsulate and Gas Nova timers to DBM. Adds new options to the /dbm Felmyst boss mod menu.

**Gas Nova:**

- Three players with the Gas Nova debuff get marked with Cross, Square and Circle (configurable).
- Shows a large Gas Nova icon on top of debuffed players' raid frames.
- Targets get notified with a messenger type sound, a big Gas Nova icon and a text message that changes.
- Targets start broadcasting the amount of players close to them to the other raid members.
- A debuffed player standing close (15 yards) to the other players will get a red "Run out!" text, and an "Error" sound.
- Red numbers inside the big icon represent the number of players near.
- A debuffed player standing away from the other players will get a green "Safe distance!" text and the error sound will stop.
- A debuffed player gets notified about the debuff dispel with a green "dispelled" text message and a notification type message.
- Large debuff icons with a text message are displayed on top of a debuffed players' raid frames.
- Text message changes with three conditions.
- If a debuffed player is broadcasting their range status, text will change from red to green, from "unsafe" to "dispel".
- If a debuffed player is not broadcasting their range status (does not have the WA pack installed) the text will be yellow "watch".

**Encapsulate:**

- If Felmyst changes her target during the fight, and the new target is not top on threat, Encapsulate cast will be registered.
- If a player in a raid get the Encapsulate debuff, Encapsulate cast will be registered.
- Encapsulate target gets notified with a large Encapsulate icon, "Stay!" text message and a notification type sound.
- Players within ~25 yards from an Encapsulate target get notified with a large Encapsulate icon, with red "Run away!" text and the "Run Away" WA sound.
- Players further than 25 yards away from an Encapsulate target get notified with a large Encapsulate icon, green "Safe!" text and a notification type sound.

**Corrosion:**

- A target gets notified with a large icon, "-armor" text and a notification type sound.

**Beam:**

- Target gets notified with a large icon, notification type sound and a "Kite the beam!" text message.
- Target sends a "Beam on me! Kiting!" chat message.
- Raid leader sends a raid warning message with a class colored name of a beam target.

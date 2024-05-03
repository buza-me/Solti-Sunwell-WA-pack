### Requirements and recommendations for the WA pack(s). Follow the list order.  

- **Install AddOns:**
- - DBM [Netherwing edition](https://discord.com/channels/700662901358461028/700685282751807630/701847782490636319).
- - The latest version of [WA addOn](https://github.com/RichSteini/WeakAuras2-TBC-2.4.3/releases).  
Make sure that you have a "Subzone name" option in the WA "Load" tab (scroll down).  
- - Optional - [custom sounds for WeakAuras](https://drive.google.com/drive/folders/1TIxyaHYE3t9_PNcbBfco-J6sq_2Aej4m?usp=drive_link).  
AI generated phrases to use instead of the standard WA sounds.  
Download the .mp3 files and put them into the "[game folder]\Interface\CustomSounds".  
If you do not have a "CustomSounds" folder inside of "Interface" folder, you can create it.  
In WA you can select a "custom" sound option and provide a path like this, for instance - Interface\CustomSounds\female_danger.mp3  
- **Install the [Solti: Anchors](https://discord.com/channels/848513360675864597/1219649374284415046/1230860601065210036) WA pack.**  
Check that everything fits on your screen.  
If some item is off screen the WA addon should indicate it with an arrow pointing at the edge of the screen.
- **Install the [Solti: Sunwell](https://discord.com/channels/848513360675864597/1219649374284415046/1231157081080336488) WA pack.**  
Auras in the Sunwell pack are "glued" to the items in the Anchors pack.  
When you move items of the Anchors pack - you move items of the Sunwell pack.  
If you delete Sunwell pack to install a newer version, but you keep the Anchors pack, you will not have to adjust aura positions again.  
  
### Sunwell WA pack features.  

- **Kalecgos:**
- - Arcane Bolt:  
Marks the Arcane Bolt taget with Cross for the duration of the cast and projectile travel.  
Arcane Bolt taget sends a chat message "Arcane Bolt on me!" to notify players around.  
Arcane Bolt target gets notified with a highlight texture, text message, red screen flash, screen shake and air horn sound.  
Players close to an Arcane Bolt target get notified with a highlight texture and the "Voice: Run Away" WA sound.  
- - Curse of Boundless Agony:  
Players with less than 20 seconds of the curse duration left get a big icon notification with a text "Run out!" and bike horn sound.  
Raid frames of the players with less than 15 seconds of the curse duration left start to glow purple, indicating a decurse request. Only visible to mages and druids.  
Curse of Boundless Agony icon is displayed at the center of the debuffed players' raid frames.  
- - Corrupting Strike:  
Corrupting Strike icon is displayed at the center of the debuffed players' raid frames.  
Raid frame of a player stunned with the Corrupting Strike glows red.  
- - Void zone:  
Players standing in a void zone get notified with the "Error beep" WA sound, screen shake, red screen glow and "Void Zone!" text message on the screen.  
- - Arcane Spark:  
Players taking spark damage get notified with the "Error beep" WA sound, screen shake, red screen glow and "Spark!" text message on the screen.  
- - Kalecgos + Sathrovarr HP widget:  
Shows the demon and the dragon health. Requres at least one player in the raid to target each of the bosses.  
  
- **Brutallus:**  
- - DBM timers:  
Adds Armageddon and Doomfire timers to DBM. Adds new options to the /dbm Brutallus boss mod menu.  
- - Doomfire:  
Players with the Doomfire debuff get marked with Moon and Square.  
Players with the Doomfire debuff get notified with a big animated icon, a "Link!" text message and the "Bike Horn" WA sound.  
Shows a large Doomfire icon on top of debuffed players' raid frames.  
- - Armageddon:  
Player with the Armageddon debuff gets notified with a big animated Armageddon icon, "Armageddon on You!" text message and "Bike Horn" WA sound.  
Player with the Armageddon debuff sends a "{Skull} Armageddon on me! {Skull}" chat message.  
Shows a large Armageddon icon on top of debuffed players' raid frames.  
Player with the Armageddon debuff gets marked with Skull.  
Players without Burn debuff within ~23 yards of an Armageddon target get notified with a large animated Armageddon icon, "Stack!" text message and "Bike Horn" WA sound.  

- **Felmyst:**
- - DBM timers:  
Adds/updates Encapsulate and Gas Nova timers to DBM. Adds new options to the /dbm Felmyst boss mod menu.  
- Gas Nova:  
Three players with the Gas Nova debuff get marked with Cross, Square and Circle.  
Shows a large Gas Nova icon on top of debuffed players' raid frames.  
Players with the Gas Nova debuff get notified with a WA sound, a large animated Gas Nova icon and text message(s) that change color depending on range conditions.  
Players with the Gas Nova debuff start broadcasting the amount of players close to them to the other raid members.  
If a player with the Gas Nova debuff is close to other players he/she/they/them will get a red "Run out!" text, red animated icon border and "Error beep" WA sound. Red numbers inside the animated icon represent the number of players close.  
If a player with the Gas Nova debuff is away from other players he/she/they/them will get a green "Safe distance!" text and a green animated icon border.  
If a player with the Gas Nova debuff is away from other players their raid frame will glow green indicating a dispel request.  
- Encapsulate:  
If Felmyst changes her target during the fight, and the new target is not top on threat, Encapsulate cast will be registered. If a player in a raid get the Encapsulate debuff, Encapsulate cast will be registered.  
Encapsulate target gets notified with a large animated Encapsulate icon, "Stay in place!" text message and "Oh no!" WA sound.  
Players within ~20 yards from an Encapsulate target get notified with a large animated Encapsulate icon with red border, red "Run away!" text and the "Air Horn" WA sound.  
Players further than 20 yards away from an Encapsulate target get notified with a large animated Encapsulate icon with green border, green "Safe!" text and the "Voice: Focus" WA sound.  
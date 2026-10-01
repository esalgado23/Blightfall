# Changelog

## Unreleased

### Animation redesign
- The progress bar is replaced by pixel-art animations. Soul Reaper and Blightfall play **Loading** (stretched to the timer, 1s fade-in) -> **Ready** (once) -> **Idle** (loops until cast) -> **OnUse** (0.5s, when cast).
- **Putrefy** appears 0.5s after Blightfall with a 0.15s fade-in, using one of 6 random card designs, and plays that card's OnUse when cast or after 5 seconds at full opacity. Optional small cards.
- The sequence is driven only by your casts, starting at Dark Transformation. The addon no longer reads the ghoul's auras, which Midnight hides in combat. Soul Reaper and Blightfall stay in Idle until cast; a new Dark Transformation restarts the sequence.
- New defaults: Soul Reaper 9.5s (1-15s), Blightfall 6s (1-8s), shown as recommended. Putrefy has no timer.
- Optional flash when N seconds of loading remain (placeholder effect).
- Optional flash for the whole Ready/Idle phase (Soul Reaper, Blightfall and Putrefy).
- Soul Reaper has its own Ready animation.
- Ready sound per spell with presets (placeholder sounds), alongside the spoken countdown.

### Fixes and tweaks
- Fixed timers disappearing as soon as combat started (caused by reading the ghoul's auras, now removed).
- Casts with hidden spell IDs are ignored instead of causing errors.
- New `/bf debug` command prints detected casts to chat.
- Spell name is anchored to the centre of the animation, like the countdown.
- Soul Reaper now leaves on its own: instantly if you cast Blightfall or Dark Transformation, or with a 0.5s fade-out 15s after Dark Transformation.
- Countdown and spell name fade in with the animation.
- Defaults: countdown in DTM Mono, monochrome, no shadow; spell name in Oldbitz, monochrome, #FCBC31 with #CC4419 shadow.
- Minimap icon is now a close-up of the Blightfall orb; window title and minimap tooltip show the full addon name.
- "Only show on mouseover" is disabled while the minimap button is hidden.
- The window's X button closes it directly instead of going through Blizzard's panel manager.

### Sound presets and Perfect Combo
- Real sound packs replace the placeholder sounds. The presets are **Majora** (Zelda low health / tower, the default) and **Umamusume: Rider of the Apocalypse**, plus Custom. The Isaac, card, bomb and Zelda sounds are all selectable; only sounds that ship with the addon can be picked, so Blizzard's own sound kits were dropped.
- Using a Putrefy card plays one of four burning-card sounds at random as it burns away. It has an on/off switch, is on by default, and stays quiet under a combo preset.
- Sounds are attached to moments instead of spells. Every preset uses Soul Reaper ready and Blightfall ready; the three "after" moments and the whole Perfect Combo block belong to combo presets and are hidden otherwise. Changing any sound switches the preset to Custom.
- One sound section now holds the channel and that channel's volume, with a note that Blizzard only lets an addon set a channel's level rather than one effect's volume.
- New combo preset **Umamusume: Rider of the Apocalypse**. It plays Combo 1-5 across those five moments, and a clean run ends with the Helios Rap finale: a 528-frame celebration that starts 0.267s after the music, with a blinking PERFECT COMBO caption (shown when the spell-name option is on). The celebration keeps its native 188px art.
- The combo is missed if Soul Reaper or Blightfall is cast before its Ready, or if Putrefy is never cast. Casting Putrefy before its card appears is fine. A missed combo still plays every sound, just no finale.
- Perfect Combo options: turn the finale off, turn it off in Mythic+ and Mythic raid only, and preview it. Its sound belongs to the preset and is not offered in the pickers.

### Settings
- **Custom mode** is the new default preset. It starts with Majora's sounds and keeps whatever you pick, separately from the other presets.
- Presets now lock what they own: Majora and Umamusume fix their sounds, Majora still lets you turn the Putrefy SFX off (remembered on its own), and Umamusume shows it locked on while covering that moment with its own sound.
- Each sound picker gained a **Listen** button and a **Test with animation** button, which plays the last half second of loading, then Ready with its sound, then the idle loop.
- Opening the settings window still shows an animation, but silently; only the preview and test buttons make noise.
- The addon only sets itself up on a Death Knight; on any other class it drops its events at login and does nothing further.
- Move and Reset position sit in the window header, so they are reachable from both tabs, and the talent line moved down next to the credit.
- New Blizzard-style window with two tabs (General, Style) and scrolling; opened with `/bf` or the minimap button.
- Style: animation size 1-300% with 1x/2x/3x shortcuts; countdown text and spell name each with font, size, outline, colour, shadow and X/Y offset; editable spell names.
- Bundled fonts: Oldbitz and DTM Mono.
- Removed: progress bar options, colours, profiles, fonts tab, dungeon toggle, enable toggle and grace period.
- Settings from earlier builds are reset.

## v1.0.0

- First release of **Blightfall - The Ultimate Death Knight Experience**.
- Slash commands are now `/bf` and `/blightfall`.

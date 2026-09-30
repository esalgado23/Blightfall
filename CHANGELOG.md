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
- Casting Soul Reaper plays one of four burning-card sounds at random alongside its burn animation. It has an on/off switch, is on by default, and stays quiet under a combo preset.
- Sounds are attached to moments instead of spells. Every preset uses Soul Reaper ready and Blightfall ready; the three "after" moments and the whole Perfect Combo block belong to combo presets and are hidden otherwise. Changing any sound switches the preset to Custom.
- One sound section now holds the channel and that channel's volume, with a note that Blizzard only lets an addon set a channel's level rather than one effect's volume.
- New combo preset **Umamusume: Rider of the Apocalypse**. It plays Combo 1-5 across those five moments, and a clean run ends with the Helios Rap finale: a 528-frame celebration that starts 0.267s after the music, with a blinking PERFECT COMBO caption (shown when the spell-name option is on). The celebration keeps its native 188px art.
- The combo is missed if Soul Reaper or Blightfall is cast before its Ready, or if Putrefy is never cast. Casting Putrefy before its card appears is fine. A missed combo still plays every sound, just no finale.
- Perfect Combo options: turn the finale off, turn it off in Mythic+ and Mythic raid only, pick its sound, and preview it.

### Settings
- New Blizzard-style window with two tabs (General, Style) and scrolling; opened with `/bf` or the minimap button.
- Style: animation size 1-300% with 1x/2x/3x shortcuts; countdown text and spell name each with font, size, outline, colour, shadow and X/Y offset; editable spell names.
- Bundled fonts: Oldbitz and DTM Mono.
- Removed: progress bar options, colours, profiles, fonts tab, dungeon toggle, enable toggle and grace period.
- Settings from earlier builds are reset.

## v1.0.0

- First release as **Blightfall - The Ultimate Death Knight Experience** (formerly BlightfallHelper 2.7.5).
- New addon folder `Blightfall` and new saved settings (`BlightfallDB`). Settings from BlightfallHelper are not carried over.
- Slash commands are now `/bf` and `/blightfall`.
- Can be installed alongside BlightfallHelper without conflicts.

---

## Legacy BlightfallHelper history

```text
V2.1 CHANGES
- Soul Reaper bar colour #1C28FF from 4 seconds upward.
- Blightfall bar colour #9F1CFF from 4 seconds upward.
- Both bars become #FF0010 below 4 seconds.
- Spell icons are shown using Soul Reaper ID 343294 and Blightfall ID 1271967.
- Smaller 2px moving marker; oversized glow removed.
- ESC menu button removed.
- Blightfall minimap button added and draggable.
- /bfh always opens centred.
- Settings window is resizable from the bottom-right corner and remembers size.
- Scrollable settings pages prevent clipping.
- Font picker uses WoW fonts, LibSharedMedia fonts, and optional local fonts.
- Audio mode can be Custom 1-10 voice files or WoW TTS.
- TTS has independent 0-100 volume and speed controls.
- Custom voice files can be routed through Master/SFX/Dialog/Music/Ambience.
- Search results open the relevant settings tab.
- ? icons provide hover explanations.

COMMANDS
/bfh          Open/close settings
/bfh unlock   Unlock display and preview Soul Reaper
/bfh lock     Lock display
/bfh test     Preview Soul Reaper
/bfh stop     Stop preview

V2.1.1 HOTFIX
- Fixed blank font picker.
- Added X button and Escape support to font picker.
- Font popup now opens centred and always shows Blizzard fallback fonts.

V2.1.2 FONT PICKER HOTFIX
- Font picker is rebuilt fresh every time it opens.
- Fixed the popup getting stuck after closing.
- Removed fragile keyboard handling that could interrupt popup creation.
- Uses a safer LibSharedMedia lookup.
- Always includes Blizzard fallback fonts.

V2.1.3 FONTSTRING HOTFIX
- Fixed FontString:SetText(): Font not set in the font picker.
- Font picker rows now receive a valid fallback font before any text is assigned.

V2.1.4 BAR COLOUR HOTFIX
- Soul Reaper is now forced to #1C28FF at 4.0 seconds and above.
- Blightfall is now forced to #9F1CFF at 4.0 seconds and above.
- Both bars are forced to #FF0010 below 4.0 seconds.
- Existing SavedVariables can no longer keep stale green/purple values.

V2.2.0 CUSTOMISATION
- Added full Colors tab with WoW colour pickers.
- Soul Reaper, Blightfall, under-4-seconds, bar background, menu background,
  menu panel and menu accent colours can all be changed.
- Current requested colours remain the defaults.
- Selected timer font now also applies across the BlightfallHelper settings UI.
- Minimap button restyled to match WoW's standard circular minimap buttons.

V2.2.1 TEXT-ONLY MODE
- Added Text Only as a third Display Mode.
- Text Only hides the progress bar, bar background, spell icon and moving marker.
- Only the spell name and countdown timer remain visible.
- Existing bar and icon modes remain unchanged.

V2.2.2 UI POLISH
- Inset the right-side scrollbars so they stay fully inside the settings window.
- Added creator credit: by Tyh.

V2.2.3 MINIMAP BUTTON HOTFIX
- Corrected minimap button border layering and sizing.
- Removed the malformed/offset crescent appearance.
- Blightfall icon remains circular and centered inside a standard WoW-style ring.

V2.2.4 MINIMAP BUTTON FIX
- Replaced the broken Blizzard tracking-border texture with a clean custom minimap frame.
- Blightfall icon remains circular, centered and draggable.

V2.2.5 MINIMAP MOUSEOVER
- Added an optional mouseover-only minimap button mode.
- When enabled, the minimap button becomes invisible when not hovered.
- Its mouse hit-area remains active so hovering its saved position reveals it.
- Default remains OFF, so existing behaviour is unchanged.

V2.2.6 LAYOUT HOTFIX
- Fixed the General-page minimap mouseover option overlapping the preview buttons.
- Added proper vertical spacing between minimap controls, previews, reset position and creator credit.
- Restored Text Only to the Display Mode selector if it was missing after prior hotfixes.

V2.2.7 TIMING DEFAULT
- Changed the default Blightfall delay after Soul Reaper from 7.0s to 6.0s.
- Existing custom saved timing values are not forcibly overwritten.

V2.2.8 TIMING MIGRATION FIX
- Default Blightfall delay remains 6.0s.
- Existing installs that still contain the previous 7.0s default are migrated to 6.0s once.
- Any saved value other than exactly 7.0s is preserved as a custom setting.

V2.3.0 BORDER CUSTOMISATION
- Added separate bar and icon border settings.
- Toggle bar border on/off.
- Adjust bar border thickness from 0-8 px.
- Change bar border colour and opacity.
- Toggle icon border on/off.
- Adjust icon border thickness from 0-8 px.
- Change icon border colour and opacity.
- Text-only mode hides both borders automatically.

V2.3.1 SETTINGS REORGANISATION
- Moved all bar/icon border controls into Display.
- Renamed Fonts & Style to Fonts and kept it typography-only.
- Reviewed tab grouping:
  General = addon access, minimap, position and previews.
  Display = mode, scale, bar/icon dimensions, marker, opacity and borders.
  Timing = cast delays, countdown start and timer precision.
  Sound = custom files/TTS, channel, TTS voice and volume.
  Fonts = font family and text sizes.
  Colors = bar/background/menu colours.
  Profiles = save/load/reset configurations.
- Updated search results to point to the correct tabs.

V2.4.0 TEXT AND ICON COUNTDOWN OPTIONS
- Added bar text position: Left, Center or Right.
- Added Show Text on Progress Bar toggle for completely clean text-free bars.
- Added Icon Countdown Position: Below Icon or Center of Icon.
- Added independent icon countdown text size.
- Added independent icon countdown text colour and opacity.
- Existing defaults remain unchanged: bar text shown on the left and icon countdown below the icon.

V2.4.1 QUARTZ-STYLE BAR OPTIONS
- Added searchable Bar Style picker with live texture previews.
- Detects LibSharedMedia statusbar textures, so Quartz/WeakAuras/SharedMedia styles appear when registered.
- Includes Blizzard and Solid fallback styles.
- Added Reverse Bar Direction.
- Added Smooth Bar Movement.
- Existing Blizzard bar style remains the default.

V2.4.2 DISPLAY LAYOUT HOTFIX
- Moved the Bar Text help tooltip beside the Show Text on Progress Bar option.
- Kept the Bar Style tooltip with the Bar Style selector.

V2.4.3 TOOLTIP / DISPLAY POLISH
- Rebuilt the Display tab with consistent two-column spacing.
- Helper ? icons now anchor to the control they explain instead of fixed screen coordinates.
- Fixed misplaced Bar Text, Bar Style, Bar Text Position and Icon Countdown helper icons.
- Applied relative helper placement across General, Timing, Sound, Fonts and Colors too.
- Checkbox helper icons now sit after the option label rather than floating elsewhere.

V2.4.4 WINDOW POLISH
- Enlarged the top-right close button and X glyph.
- Moved the bottom-right resize grip fully inside the window.
- Raised the resize grip above scrollbars and added a subtle background.
- Added extra content inset so scrollbars no longer clip the resize grip.

V2.4.5 CLOSE BUTTON FIX
- Replaced the tiny font-based X with a dedicated WoW close-button texture.
- The X is now independent of the selected addon font.
- Increased the visible close icon to 34 px inside a 48 px button.
- Added hover highlighting to match the addon accent colour.

V2.4.6 CLOSE BUTTON STYLE
- Replaced the Blizzard close artwork with a clean compact X.
- X is drawn independently of fonts for consistent sizing.
- X and button border inherit the selected menu accent colour.
- Hovering the button turns the X white for clear feedback.

V2.4.7 EMERGENCY STABILITY HOTFIX
- Removed the rotated-texture close X introduced in 2.4.6.
- Replaced it with a fixed Blizzard-font X that still inherits the menu accent colour.
- The selected addon font cannot affect the close X.
- Fixed SavedVariables schema finalisation for older configurations.

V2.4.8 CLOSE BUTTON CONSISTENCY
- Standardised the main window and all addon popup/submenu close buttons.
- Font picker and Bar Style picker now use the same large accent-coloured X.
- Close buttons update automatically when the menu accent colour changes.
- Hovering any close button turns the X white.

V2.4.9 RUNTIME HOTFIX
- Fixed Display.lua error caused by GetFrameTime() being unavailable.
- Smooth bar movement now uses the elapsed value supplied directly by WoW's OnUpdate handler.

V2.5.0 TALENT DETECTION
- Soul Reaper timer only starts if Soul Reaper is currently learned/talented.
- Blightfall timer only starts if Blightfall is currently talented.
- Checks Blightfall cast spell 1271967 and talent/passive 1271974.
- Talent/spell state refreshes automatically after talent changes, spellbook changes and login.
- Active timers are removed if the corresponding talent becomes unavailable.
- General tab shows detected Soul Reaper and Blightfall availability.

V2.5.1 TALENT CHAIN FIX
- Soul Reaper + Blightfall: Dark Transformation -> Soul Reaper -> Blightfall.
- Soul Reaper only: Dark Transformation -> Soul Reaper.
- Blightfall only: Dark Transformation -> Blightfall directly.
- Neither: no timer is shown.

V2.5.2 MINIMAP BUTTON POLISH
- Rebuilt the minimap button as a true circular icon.
- Removed the square backdrop that made the button look out of place.
- Added a Blizzard-style circular minimap ring and hover highlight.
- Dragging now stores only the angle and always projects the button back onto the minimap rim.
- Button centre is anchored to the minimap outer radius instead of floating inside the minimap.

V2.5.3 MINIMAP BORDER REBUILD
- Removed MiniMap-TrackingBorder completely.
- Border is now built from concentric circular masked textures.
- This avoids the recurring offset/crescent border bug.
- Uses a gold outer ring, dark inner ring and circular Blightfall artwork.
- Dragging still locks the button to the minimap rim.

V2.5.4 CONTINUOUS PREVIEW
- Preview Soul Reaper and Preview Blightfall now loop continuously.
- When a preview timer reaches zero it immediately restarts the same preview.
- Preview continues until Stop Preview is pressed or the settings window is closed.
- Countdown audio is suppressed during preview, making it suitable for positioning and comparing bar/icon styles.

V2.5.5 PREVIEW AUDIO
- Countdown audio now plays during the first cycle of a preview.
- Once that first preview reaches zero, all repeating preview cycles are silent.
- Pressing Preview again starts a fresh first cycle with audio.
- Normal combat countdown audio is unchanged.

V2.6.0 DARK TRANSFORMATION EXPIRY GUARD
- Added optional "Cancel timer 5s after Dark Transformation ends" setting under Timing.
- When enabled, the addon watches the player's Dark Transformation aura.
- Five seconds after the aura falls off, any unfinished Soul Reaper/Blightfall sequence is cancelled.
- Once cancelled, no further stage can start until Dark Transformation is cast again.
- Recasting/reapplying Dark Transformation invalidates the old expiry timer.
- Enabled by default.

V2.6.1 DARK TRANSFORMATION PET AURA FIX
- Dark Transformation expiry detection now watches the Death Knight's pet/ghoul.
- UNIT_AURA checks now respond to the pet rather than the player.
- Added pet-change handling so replacing, losing or resummoning the ghoul updates the expiry guard.
- The existing 5-second grace period remains unchanged.

V2.6.2 DARK TRANSFORMATION SEQUENCE LOCK
- Fixed Soul Reaper being able to start a Blightfall timer after the Dark Transformation grace period had already expired.
- Added a hard expired/disarmed state to each Dark Transformation sequence.
- Soul Reaper can only advance to Blightfall while the current Dark Transformation sequence is still armed.
- StartStage now refuses combat timers from expired sequences.
- Casting Dark Transformation again clears the expired state and starts a fresh sequence.

V2.6.3 DARK TRANSFORMATION TRACKING FIX
- Corrected Dark Transformation tracking to check the transformed-ghoul pet aura (1235391), with 1233448 retained as a fallback.
- Fixed the expiry guard not starting when the pet aura was never detected.
- Added configurable Dark Transformation grace period from 0-10 seconds.
- Default grace period remains 5 seconds.
- 0 seconds cancels the sequence immediately when the pet aura disappears.
- Once cancelled, Soul Reaper cannot start Blightfall until Dark Transformation is cast again.

V2.6.4 DARK TRANSFORMATION WATCHER FIX
- Reworked Dark Transformation expiry tracking for reliability.
- The addon now watches the pet aura by spell ID and spell name.
- Added a 0.20s pet-aura polling watcher while the sequence is armed.
- Added combat-log tracking for Dark Transformation aura applied/refreshed/removed.
- This prevents Soul Reaper from creating Blightfall after the DT sequence has expired.
- Reworked Timing UI spacing.
- Renamed the option to "Cancel sequence when Dark Transformation ends".
- Grace period is now clearly separated and displays values as "0 seconds" through "10 seconds".

V2.7.0 MODULAR TIMER CONTROLS
- Added independent Soul Reaper and Blightfall timer toggles; both default ON.
- Soul Reaper tracking continues in the background when its display is disabled, allowing Blightfall to remain independent.
- Added optional Disable Helper in Dungeons; defaults OFF.
- When enabled, combat timers are suppressed in 5-player dungeon instances and cleared on entry.

V2.7.1 AUTOMATIC MENU PREVIEW
- Opening /bfh now automatically starts the continuous preview.
- Soul Reaper is previewed by default when its module is enabled.
- If Soul Reaper is disabled and Blightfall is enabled, Blightfall is previewed instead.
- If both modules are disabled, a configuration-only Soul Reaper preview is still shown so the display can be positioned and styled.
- Closing the settings window still stops the preview.
- Existing Preview Soul Reaper, Preview Blightfall and Stop Preview buttons remain available.

V2.7.2 MENU OPEN HOTFIX
- Fixed /bfh settings window failing to open after automatic preview was added.
- Automatic preview is now started on the next frame after the menu finishes opening.
- Preview startup is protected so a preview error can never brick the settings window.
- Closing the menu also safely checks the display module before stopping preview.

V2.7.3 CRITICAL LOAD FIX
- Fixed a missing `end` in Config.lua that prevented the entire settings module from loading.
- Fixed malformed texture path escaping in the resize-grip backdrop.
- This was why /bfh reached Core.lua but ToggleConfig was nil.
- Cleaned up spacing for the new modular timer and dungeon options.
- All addon Lua files were syntax-checked before packaging.

V2.7.4 MIDNIGHT API HOTFIX
- Removed COMBAT_LOG_EVENT_UNFILTERED registration.
- Retail Midnight 12.x restricts that event for normal addons and can trigger ADDON_ACTION_FORBIDDEN.
- Dark Transformation expiry tracking now relies on the pet UNIT_AURA watcher plus the existing 0.20s pet-aura polling fallback.
- No combat-log API is required for BlightfallHelper's sequence tracking.

V2.7.5 DUNGEON HELPER FIX
- Fixed nil-function errors from the Disable Helper in Dungeons feature.
- Added the missing IsDisabledByInstance and RefreshInstanceState functions.
- Added defensive guards so dungeon checks cannot break Dark Transformation handling.
- Normal, Heroic, Mythic and Mythic+ remain covered through WoW's 'party' instance type.
```

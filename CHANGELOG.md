# Changelog

## Unreleased

- **Putrefy animation style** is now a dropdown: **Normal**, **Small** or **Mini (simplified)**. Mini is a new, much smaller card that also drops some of the detail. The old "Small Putrefy cards" checkbox moves over to the matching choice.
- Refreshed the Blood and Frost Perfect-style Putrefy cards at Normal and Small size.

## v1.0.1

- **Self-correcting timers.** If a mechanic or a boss move makes you cast Soul Reaper late, Blightfall's timer shortens to match instead of running its full length and costing you damage. A 1.2 second grace keeps a slightly late cast on time, and if no time is left Blightfall opens on ready.
- The addon list now shows Blightfall's own logo instead of a stock spell icon. The minimap button is unchanged.
- Sounds start the instant they are meant to: the silence baked into most of the clips, up to 1.4s on one, is trimmed when the addon is built.
- Sound presets lock what they own, and each picker gained **Listen** and **Test with animation**.
- Both settings tabs were reordered, sliders no longer answer the mouse wheel, and the countdown defaults to whole seconds.

## v1.0.0

First release.

Blightfall follows the Unholy rotation **Dark Transformation → Soul Reaper → Blightfall → Putrefy** and shows where you are in it with pixel-art animations instead of a bar.

### The sequence

- Casting Dark Transformation starts Soul Reaper's **loading** animation, stretched to the timer you choose. It then plays **ready** once and loops **idle** until you cast, and casting plays its **use** animation.
- Soul Reaper hands over to Blightfall the same way. Blightfall hands over to a **Putrefy card**, which leaves after five seconds if you do not use it. There is a smaller size if the cards crowd your screen.
- Soul Reaper clears itself fifteen seconds after Dark Transformation, or at once if you cast Blightfall.
- Recommended timings are 9.5s for Soul Reaper and 6s for Blightfall, both adjustable. Keep your trinket in mind: the timers should line up with it.
- Everything is driven by your own casts, so it keeps working in combat, and it only tracks the spells you actually have talented.

### Sound

- **Custom mode** is the default and lets you choose each sound. **Majora** fixes its two sounds but still lets you mute the Putrefy effect. **Umamusume: Rider of the Apocalypse** plays a five-part combo across the rotation, and casting every spell on time ends it with a Perfect Combo celebration.
- Every picker has **Listen** and **Test with animation**, the second playing the end of the loading animation into ready so you hear it where it lands.
- Spoken countdown over the last seconds, using the bundled voice files or WoW's text-to-speech.

### Display

- Animation size from 1% to 300%, with an optional flash near the end of loading or for the whole ready phase.
- Countdown and spell name can each be turned off or restyled: font, size, outline, colour, shadow and position. Spell names are editable, and two fonts are bundled.
- Draggable display and minimap button.

### Requirements

Retail only, and only on a Death Knight; on any other class the addon stops at login and does nothing.

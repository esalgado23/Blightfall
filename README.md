# Blightfall - The Ultimate Death Knight Experience

Timing helper for Unholy Death Knights in World of Warcraft (Retail).

Tracks the **Dark Transformation → Soul Reaper → Blightfall → Putrefy** sequence with pixel-art animations: each spell loads while you wait, shows a ready loop when it's time to cast, and plays an effect when you use it.

## Features

- Loading animation stretched to your chosen timer, then Ready/Idle until you cast, then an OnUse effect.
- Putrefy reminder animations after Blightfall; it leaves after 5 seconds if not cast.
- Talent aware. Driven only by your own casts, so it keeps working in combat.
- Optional countdown text and spell name with custom fonts, colours, shadow and position.
- Sound presets for each moment of the sequence, plus spoken countdown (voice files or WoW text-to-speech).
- Combo preset with a Perfect Combo celebration when the whole sequence is cast on time.
- Draggable minimap button.

## Commands

| Command | Action |
|---|---|
| `/bf` or `/blightfall` | Open / close settings |
| `/bf move` | Unlock the display to drag it |
| `/bf lock` | Lock the display |
| `/bf test` | Preview Soul Reaper |
| `/bf stop` | Stop preview |

## Installation

Install with the CurseForge app, or download the latest zip from Releases and extract the `Blightfall` folder into `World of Warcraft\_retail_\Interface\AddOns\`.

## Building the media (maintainers)

Everything under `Media/` is generated from `art/` and is not committed; the release workflow builds it.

- `python tools/build_anims.py` (needs Pillow) turns the sprite sheets in `art/src` into `Media/Anim/*.tga` and `AnimData.lua`.
- `python tools/build_sounds.py` (needs soundfile) copies `art/sounds` into `Media/Sounds`, trimming any leading silence so a sound lands the moment it is meant to.
- `python tools/check.py` (needs luaparser) syntax-checks the Lua and confirms the media it references exists.

## Releasing (maintainers)

Push a tag such as `v1.0.1`. GitHub Actions packages the addon and uploads it to CurseForge and GitHub Releases. Add release notes to `CHANGELOG.md` before tagging.

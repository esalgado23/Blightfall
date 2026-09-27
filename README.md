# Blightfall - The Ultimate Death Knight Experience

Timing helper for Unholy Death Knights in World of Warcraft (Retail).

Tracks the **Dark Transformation → Soul Reaper → Blightfall → Putrefy** sequence and shows a countdown bar, icon or text for each stage, with optional voice countdown.

## Features

- Automatic sequence: Dark Transformation starts the Soul Reaper timer, Soul Reaper starts the Blightfall timer, Blightfall starts the Putrefy timer.
- Talent aware: only tracks the spells you actually have talented.
- Cancels the sequence when Dark Transformation ends (configurable grace period).
- Bar, icon or text-only display with full font, colour, texture and border customisation (LibSharedMedia supported).
- Countdown audio with bundled voice files or WoW text-to-speech.
- Profiles, searchable settings and a draggable minimap button.
- Optional: disable inside 5-player dungeons.

## Commands

| Command | Action |
|---|---|
| `/bf` or `/blightfall` | Open / close settings |
| `/bf unlock` | Unlock the display and preview Soul Reaper |
| `/bf lock` | Lock the display |
| `/bf test` | Preview Soul Reaper |
| `/bf stop` | Stop preview |

## Installation

Install with the CurseForge app, or download the latest zip from Releases and extract the `Blightfall` folder into `World of Warcraft\_retail_\Interface\AddOns\`.

## Releasing (maintainers)

Push a tag such as `v1.0.1`. GitHub Actions packages the addon and uploads it to CurseForge and GitHub Releases. Add release notes to `CHANGELOG.md` before tagging.

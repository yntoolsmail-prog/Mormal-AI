# Mormal AI

A balance mod for **Crusader Kings III** (CK3 1.16.x) that makes the AI a more
**competitive opponent** — quicker to go to war, smarter about army size, less
timid about target selection, and less prone to hoarding gold it never spends.

It's a pure data/balance mod: no DLC required, no graphics, no new mechanics.
It re-tunes values the game's AI already reads, so it stays lightweight and
multiplayer-sync safe.

## Status

**v0.1 — scaffolding.** The mod structure, vanilla reference, and the tuning
plan are in place. The actual balance changes are documented and staged but not
yet enabled — see [`docs/AI_TUNING_PLAN.md`](docs/AI_TUNING_PLAN.md).

## What it changes (planned v0.1 pass)

- **War tempo** — shorter cooldown between offensive wars.
- **Army sizing** — the AI aims to *outnumber*, and commits more of its warchest
  to mercenaries to do it.
- **Target selection** — willing to attack neighbours that are slightly stronger
  instead of only weaker ones.

The design principle is *make the AI play better with the resources it already
has*, rather than handing it hidden cheats.

## Install (from this repo)

The repository **is** the mod folder. To run it:

1. Copy/clone this folder into your CK3 `mod/` directory, e.g.
   `Documents/Paradox Interactive/Crusader Kings III/mod/Mormal-AI/`.
2. Create a launcher descriptor next to it,
   `Documents/Paradox Interactive/Crusader Kings III/mod/Mormal-AI.mod`:
   ```
   version="0.1.0"
   tags={ "Balance" "Warfare" }
   name="Mormal AI"
   supported_version="1.16.*"
   path="mod/Mormal-AI"
   ```
3. Launch CK3, enable **Mormal AI** in a playset, and play.

> If you place the folder somewhere else, change `path=` to match.

## Repository layout

| Path | Purpose |
|---|---|
| `common/defines/00_mormal_ai.txt` | Our AI tuning overrides (the main file). |
| `common/modifiers/` | Reserved for character/skill modifier tweaks. |
| `vanilla/` | Pristine copies of the original game files (reference only). |
| `docs/AI_TUNING_PLAN.md` | The levers, their defaults, and the plan. |
| `CLAUDE.md` | Contributor guide / how the mod is structured. |
| `descriptor.mod`, `.metadata/metadata.json` | CK3 mod descriptors. |

## Contributing / developing

Read [`CLAUDE.md`](CLAUDE.md) first — it explains the two-layer (vanilla vs.
override) approach, the file syntax, and the conventions for documenting every
change. Keep overrides slim, document the vanilla value and rationale inline,
and change one theme at a time.

## Compatibility

- **Game version:** CK3 1.16.x.
- **DLC:** none required.
- **Other mods:** conflicts with any mod that also overrides the same `NAI`
  defines (load order decides the winner).

# CLAUDE.md

Guidance for Claude Code (and humans) working in this repository.

## What this project is

**Mormal AI** is a mod for **Crusader Kings III** (CK3 — written "КС3"/"KC3").
The goal is a single, focused one: **make the AI a more competitive opponent**
— better at waging war, sizing its armies, picking targets, and spending its
gold — without turning it into an unfair cheat-bot.

This is a *data/balance* mod. CK3's AI behaviour is driven by tunable values in
the game's script files (Clausewitz engine, plain-text `key = value` syntax).
There is no compiling and no engine code here — we change numbers and rules the
game already reads.

Target game version: **CK3 1.19.x**. The vanilla files include administrative
government, the "Hegemony" tier, and nomad `herd` mechanics.

## Repository layout

```
descriptor.mod                      # CK3 mod descriptor (legacy launcher)
.metadata/metadata.json             # CK3 mod descriptor (current launcher / Paradox Mods)
common/
  defines/
    00_mormal_ai.txt                # OUR AI define overrides (the main editable file)
  modifiers/                        # reserved for modifier overrides (skill buffs etc.)
vanilla/                            # PRISTINE upstream reference - DO NOT EDIT
  00_ai.txt                         #   -> vanilla common/defines/00_ai.txt   (NAI block)
  00_defines.txt                    #   -> vanilla common/defines/00_defines.txt
  00_basic_modifiers.txt            #   -> vanilla common/modifiers/00_basic_modifiers.txt
docs/
  AI_CURRENT_STATE.md               # how the stock AI behaves today (baseline)
  AI_TUNING_PLAN.md                 # the levers, current values, and the plan
CLAUDE.md                           # this file
README.md                           # player-facing install & overview
```

### The two-layer rule (important)

- **`vanilla/`** is a read-only snapshot of the original game files. It exists
  so we can diff, look up default values, and re-baseline when CK3 updates.
  **Never edit files in `vanilla/`** — treat it like a vendored dependency.
- **`common/`** is the mod itself. When the game loads, files here are merged on
  top of vanilla. Filenames load alphabetically, so `00_mormal_ai.txt` loads
  *after* `00_ai.txt` and any `NAI` key it sets overrides the default.

This means our override files should be **slim**: list only the keys we change,
never paste a whole vanilla file. Slim overrides survive game patches far better
than full-file replacements (a full copy silently reverts any value Paradox
changed in a patch).

## How CK3 reads these files

- `common/defines/*.txt` — global constants grouped in named blocks
  (`NAI = { ... }`, `NGame = { ... }`, etc.). Later files override earlier keys.
  You can override a single key inside a block without repeating the rest.
- `common/modifiers/00_basic_modifiers.txt` — per-skill modifier packages
  (`diplomacy_modifier`, `martial_modifier`, …) applied to every character.
  Overriding one of these **replaces the whole named block**, so copy the
  vanilla block first, then edit — partial merge does not apply here.
- Syntax: tabs for indentation, `#` for comments, `key = value`, lists in
  `{ a b c }`. Fixed-point numbers (e.g. `0.6`), int32, and arrays-by-tier
  (one value per government tier) all appear. The vanilla files carry
  `### Brief:` comments above most keys — read them, they describe each lever.

## Working conventions

- **Document every change inline.** Use the format:
  `KEY = <new>      # vanilla <old> | why this helps the AI compete`
- **Keep the rationale in sync** in `docs/AI_TUNING_PLAN.md` (what changed, the
  hypothesis, and the playtest result once known).
- **Change one theme at a time** (war tempo, army sizing, target selection,
  economy …) so playtesting can attribute effects.
- **No invisible cheats.** Prefer making the AI *play better* (smarter
  thresholds, fuller use of its real resources) over raw bonuses. If a bonus is
  ever added, gate it and document it loudly.
- **Multiplayer-safe.** Define/modifier changes are deterministic and MP-sync
  safe; keep it that way (no `random`-based divergence in shared files).

## Re-baselining on a CK3 update

1. Drop the new vanilla `00_ai.txt` / `00_defines.txt` / `00_basic_modifiers.txt`
   into `vanilla/` (overwrite).
2. `git diff` the `vanilla/` change to see what Paradox altered.
3. Reconcile our overrides in `common/` against any moved/renamed/removed keys.
4. Bump `supported_version` in `descriptor.mod` and `.metadata/metadata.json`.

## Validation (no test harness exists)

There is no automated test suite — this is game script. To validate:

1. Load the mod in CK3 with the **error log** open
   (`Documents/Paradox Interactive/Crusader Kings III/logs/error.log`).
2. A clean `error.log` (no new entries pointing at our files) means the script
   parses. Define typos usually surface there or as default-value fallbacks.
3. Behavioural validation is **observational**: run observer/fast-forward games
   and watch war frequency, army sizes, and map churn vs. an unmodded baseline.

## Quick orientation for a new task

- Want to change AI behaviour? → edit `common/defines/00_mormal_ai.txt`.
- Need the default value or the meaning of a key? → grep `vanilla/00_ai.txt`
  (the `### Brief:` comment above the key explains it).
- Planning or recording tuning decisions? → `docs/AI_TUNING_PLAN.md`.
- Need to understand how the stock AI already behaves? → `docs/AI_CURRENT_STATE.md`.

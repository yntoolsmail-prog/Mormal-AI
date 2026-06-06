# AI Tuning Plan

Working notes for making the CK3 AI more competitive. This is the place to
record *what* we change, *why*, and *what the playtest showed*.

> Status legend: 🔲 candidate · 🔬 testing · ✅ kept · ❌ reverted

All levers live in `vanilla/00_ai.txt` (the `NAI` block). We override them in
`common/defines/00_mormal_ai.txt`. Vanilla values are quoted from the shipped
files (CK3 1.19.x).

## Diagnosis — where the vanilla AI is weak

Common, well-known shortcomings of the CK3 AI that a balance mod can address
purely through defines:

1. **Too passive at war** — long cooldowns and conservative chance rolls leave
   AI rulers idle for years when a player in their shoes would be expanding.
2. **Under-sized armies** — the AI under-uses its gold/mercs and often commits
   stacks that only just match the enemy, then loses attrition wars.
3. **Timid target selection** — it avoids anyone even slightly stronger, so
   strong AI blobs rarely get challenged and snowball unopposed.
4. **Gold hoarding** — wealth sits unused instead of being converted into
   mercenaries, buildings, or men-at-arms.

The plan attacks these one theme at a time so each effect is measurable.

## Levers by theme

### 1. War tempo
| Key | Vanilla | Candidate | Rationale | Status |
|---|---|---|---|---|
| `AI_WAR_BASE_COOLDOWN` | `50` | `40` | Less dead time between offensive wars. | 🔲 |
| `AI_BASE_WAR_CHANCE` | `1` | `1` | Base roll; scaled by energy (x0.5 at 0). Hold for now. | 🔲 |
| `AI_WAR_COOLDOWN_RATIO_FOR_FULL_CHANCE` | `0` | `0` | Already "always look for a CB once cooldown ends". Keep. | 🔲 |

### 2. Army sizing
| Key | Vanilla | Candidate | Rationale | Status |
|---|---|---|---|---|
| `MERC_OVERMATCHING_TARGET` | `1.25` | `1.4` | Aim to outnumber, not just match. | 🔲 |
| `MAX_WEALTH_EXPENDITURE_MERCS` | `0.8` | `0.85` | Free up a little more gold for mercs. | 🔲 |
| `MAX_WAR_CHEST_EXPENDITURE_MERC_OVERMATCHING` | `0.7` | `0.8` | Commit more warchest to a winning edge. | 🔲 |
| `RAISE_TROOPS_MIN_RATIO_OF_ENEMY` | `0.5` | `0.5` | Threshold to bother raising. Hold. | 🔲 |

### 3. Target selection
| Key | Vanilla | Candidate | Rationale | Status |
|---|---|---|---|---|
| `CB_TARGET_AT_PEACE_POWER_RATIO_MAX` | `1.0` | `1.1` | Willing to attack slightly stronger targets. | 🔲 |
| `CB_TARGET_POWER_RATIO_BOLDNESS` | `0.25` | `0.30` | Bold rulers reach a bit further up. | 🔲 |
| `DESIRED_WAR_SIDE_POWER` | `1.25` | `1.25` | When the AI stops calling allies. Hold. | 🔲 |

### 4. Economy
| Key | Vanilla | Candidate | Rationale | Status |
|---|---|---|---|---|
| `PERCENTAGE_INTO_WAR_CHEST` | `0.6` | `0.6` | Share of income reserved for war. Watch before touching. | 🔲 |

## Proposed v0.1 ("first competitive pass")

A small, conservative bundle to enable together and playtest as one step:

- War tempo: `AI_WAR_BASE_COOLDOWN` 50 → 40
- Army sizing: `MERC_OVERMATCHING_TARGET` 1.25 → 1.4,
  `MAX_WAR_CHEST_EXPENDITURE_MERC_OVERMATCHING` 0.7 → 0.8
- Target selection: `CB_TARGET_AT_PEACE_POWER_RATIO_MAX` 1.0 → 1.1

Hypothesis: noticeably more (and more decisive) AI-vs-AI wars and map churn,
without the AI bankrupting itself or suiciding into far-stronger neighbours.

> These are **not yet enabled** — they sit commented in
> `common/defines/00_mormal_ai.txt` pending a go-ahead and a baseline playtest.

## Playtest protocol

1. Pick a fixed start (e.g. 867 or 1066), run an **observer game** at max speed.
2. Record at a fixed checkpoint (e.g. +50 in-game years): number of independent
   realms, largest realm size, total active wars, notable blob formation.
3. Compare unmodded baseline vs. each enabled theme. Keep the `error.log` open.
4. Log results back into the tables above (status → 🔬/✅/❌ with a one-line note).

## Ideas parked for later (need more than define edits)

- Skill-modifier buffs for AI characters (`common/modifiers/00_basic_modifiers.txt`)
  to make high-skill rulers actually punch above their weight.
- Council/scheme aggressiveness, marriage/alliance webs, succession planning.
- Difficulty-gated bonuses (only if "play better" levers prove insufficient).

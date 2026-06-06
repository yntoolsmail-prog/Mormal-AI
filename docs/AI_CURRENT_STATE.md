# How the vanilla CK3 AI works today (1.19)

Before changing anything, this is a map of what the stock AI actually does, read
straight from `vanilla/00_ai.txt` (the `NAI` define block). Every value below is
the shipped default. Use this as the baseline we measure against.

> These defines don't *contain* the AI logic — the engine does — but they are the
> knobs that logic reads. Where a knob is the lever for a behaviour, it's the
> thing we can change.

## 1. How often the AI thinks

The AI re-evaluates "tasks" on staggered timers, **per government tier**
(Unlanded · Baron · Count · Duke · King · Emperor · Hegemony):

| Task class | Count/Duke/King | Notes |
|---|---|---|
| `SHORT_TASK_TICK` | 7 days | fast reactions (Unlanded 30) |
| `MEDIUM_TASK_TICK` | 30–60 days | |
| `LONG_TASK_TICK` | 60–180 days | |
| `RARE_TASK_TICK` | 180 days | |
| `STRATEGY_TASK_TICK` | 180 days | long-horizon plans |

Higher tiers and the Hegemon tick **faster** on grants/revocations/tax. Takeaway:
big realms react quickly; small fry deliberate slowly. This cadence caps how
responsive the AI can be regardless of other tuning.

## 2. Deciding to go to war (the offensive-war gate)

A landed AI only considers a new offensive war after passing several gates:

- **Cooldown:** `AI_WAR_BASE_COOLDOWN = 50` days minimum between offensive wars.
  With `AI_WAR_COOLDOWN_RATIO_FOR_FULL_CHANCE = 0`, once those 50 days pass it
  will *always* look for a CB — there's no extra ramp-up.
- **Base chance × Energy:** `AI_BASE_WAR_CHANCE = 1`, then scaled by the ruler's
  **Energy** trait: ×0 at −100, ×0.5 at 0, ×1 at +100. So a lethargic ruler is
  roughly half as warlike as an energetic one; a deeply lethargic one barely
  wars at all.
- **Offensive-war penalty:** `AI_WAR_MAX_OFFENSIVE_WAR_PENALTY = 0.0` — if the
  ruler has *any* offensive-war penalty (e.g. recent wars, tribal/feudal limits)
  it won't declare, **unless** it's a faith warmonger or has Rationality ≤
  `AI_WAR_MIN_RATIONALITY_FOR_OFFENSIVE_WAR_PENALTY = −30`.
- **Best-CB filter:** `MIN_SCORE_RATIO_FOR_CASUS_BELLI = 0.9` — it only declares
  a war scoring within 90% of the best CB it currently has. It won't take
  "okay" wars while a much better one exists.

**Net effect:** the stock AI is cautious and bursty — it waits out cooldowns,
needs a clean offensive-war slate, and its appetite swings heavily with the
Energy trait. This is the #1 reason AI realms can look passive.

## 3. Picking a target (CB scoring + power gating)

Among valid CBs, score is dominated by **de jure / title** drivers:

- `CB_SCORE_DE_JURE_MULTIPLIER = 100`, `CB_SCORE_HIGHER_TITLE_MULTIPLIER = 100`,
  `CB_SCORE_MULT_NEIGHBOR_TITLE = 15`, `EXTRA_CB_SCORE_FOR_HOLY_SITES = 10`.
- Opinion & claimant factors: `CB_OPINION_OF_TARGET_MULTIPLIER`,
  `CB_OPINION_OF_CLAIMANT_MULTIPLIER`, `CB_CLAIMANT_GREED_MULTIPLIER`, etc.

So the AI strongly prefers grabbing **de jure / neighbouring** land — sensible,
but it means it rarely reaches for opportunistic far targets.

**Power gating — who it dares attack:**

- Hard ceiling: `CB_TARGET_MAX_POWER = 3.0` independent / `2.0` vassal — it won't
  even look at anyone more than 3× (or 2×) its power.
- At peace: `CB_TARGET_AT_PEACE_POWER_RATIO_MAX = 1.0` — **it will not attack
  anyone stronger than itself** if that target is currently at peace.
- Already at war: `CB_TARGET_AT_WAR_POWER_RATIO_MAX = 1.5`, plus
  `+0.25` per extra war the target is in — it pounces on the over-extended.
- Boldness nudge: `CB_TARGET_POWER_RATIO_BOLDNESS = 0.25` — a maximally bold
  ruler (100) raises the ratio by +0.25.

**Net effect:** strong AI realms are almost never challenged while at peace
(nobody attacks "up"), so the map snowballs — a leading blob keeps growing
because its peers refuse to gang up on it until it's already fighting someone.

## 4. Sizing the army (raise + mercs)

- **Raise threshold:** raises levies/MAA when it can field ≥ `0.3` of its own max
  (`RAISE_TROOPS_MIN_RATIO_OF_SELF`) **or** ≥ `0.5` of the enemy
  (`RAISE_TROOPS_MIN_RATIO_OF_ENEMY`). Tops up in chunks of `0.1`
  (`RAISE_ADDITIONAL_TROOPS_RATIO`) to avoid army spam.
- **Mercs:** tries to **outnumber by 25%** (`MERC_OVERMATCHING_TARGET = 1.25`)
  *if affordable*, spending at most `0.8` of wealth (`MAX_WEALTH_EXPENDITURE_MERCS`)
  and `0.7` of the warchest (`MAX_WAR_CHEST_EXPENDITURE_MERC_OVERMATCHING`).
  Pretends to be `100` gold poorer per merc hired (keeps a reserve),
  rounds small gaps up to `MIN_HIRING_GOAL = 500`.
- **War plans:** wants `WANTED_POWER_RATIO_AGAINST_ENEMY_FOR_WAR_PLAN = 1.25`
  before committing a plan; stops pulling in allies once its side hits
  `DESIRED_WAR_SIDE_POWER = 1.25`.

**Net effect:** the AI only aims for a *modest* 25% edge and caps merc spend
conservatively, so against a well-prepared opponent it often shows up "just
barely ahead" and loses the attrition/quality battle.

## 5. Spending gold (the warchest)

- Reserves a warchest = max(`MIN_WAR_CHEST` by tier, `18` months of maintenance).
  `MIN_WAR_CHEST` per tier: `25 / 25 / 50 / 100 / 200 / 300 / 400`.
- While the chest isn't full, it diverts `PERCENTAGE_INTO_WAR_CHEST = 0.6` of
  income into it.

**Net effect:** a lot of income is parked. The intent is "save up for war", but
in practice mid-tier AIs sit on idle gold instead of compounding it into
buildings / men-at-arms / mercs.

## 6. Fighting the battle (tactical)

- MAA purchase weighting: `TOUGHNESS_SCORE_MULT = 10`, `ATTACK_SCORE_MULT = 10`,
  `PURSUIT = 3`, `SCREEN = 1`, `SIEGE_VALUE = 1000` (siege weapons heavily
  favoured when a siege is the goal).
- Engagement nerves: asks allies for help below predicted win ratio
  `ASK_FOR_HELP_COMBAT_PREDICTION_RATIO = 0.66`; retreats below
  `RETREAT_COMBAT_PREDICTION_RATIO = 0.45`; `COMBAT_RATIO_THRESHOLD = 0.5`.

**Net effect:** tactically the AI is okay — it retreats from clearly-losing
fights and values siege weapons — but its army-composition scoring is generic.

## 7. Personality traits as global multipliers

- **Energy** scales war chance (§2) and can only *amplify already-positive*
  faction/scheme scores (`ENERGY_FACTOR = 1.0`).
- **Rationality** can move an evaluation above *or* below 0 (`RATIONALITY_FACTOR
  = 1.0`); also unlocks penalised wars when very low (§2).
- **Boldness** raises the power ratio it dares attack (§3); **Dread** modifies
  boldness for factions (`DREAD_MODIFIED_BOLDNESS_FACTOR = 1.0`).

**Net effect:** a single unlucky personality (lethargic / cowardly / very
rational) can make an otherwise-powerful AI almost inert.

## Summary — the four weaknesses we can target

| # | Symptom | Primary knobs |
|---|---|---|
| A | **Passive / bursty wars** | `AI_WAR_BASE_COOLDOWN`, Energy scaling, `AI_WAR_MAX_OFFENSIVE_WAR_PENALTY` |
| B | **Never attacks "up" → blobs snowball** | `CB_TARGET_AT_PEACE_POWER_RATIO_MAX`, `CB_TARGET_POWER_RATIO_BOLDNESS`, `CB_TARGET_MAX_POWER` |
| C | **Armies only just match the enemy** | `MERC_OVERMATCHING_TARGET`, `MAX_WAR_CHEST_EXPENDITURE_MERC_OVERMATCHING`, `MAX_WEALTH_EXPENDITURE_MERCS` |
| D | **Idle gold hoarding** | `PERCENTAGE_INTO_WAR_CHEST`, `MONTHS_OF_MAINTENANCE_IN_WAR_CHEST`, `MIN_WAR_CHEST` |

The proposed v0.1 pass in `AI_TUNING_PLAN.md` deliberately touches A, B and C
with small steps so each effect is observable. D is noted but left alone until we
see whether the AI actually *needs* more spendable gold or just better targets.

## Open questions to resolve before tuning values

1. **Baseline first.** We should run an unmodded observer game and record the
   metrics in the playtest protocol, so "more competitive" has numbers behind it.
2. **Where's the pain?** Is the complaint that AIs are too passive, that one blob
   always snowballs, that the *player* is never threatened, or all three? Each
   points at a different column above.
3. **Cheats or not?** Decide whether we stay "play better with real resources"
   only, or allow gated bonuses (skills/levies/gold) for a harder challenge.

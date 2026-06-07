# Полный разбор бюджета ИИ: каждая функция + проход 0→5000

Разбор `vanilla/scripted_effects/00_ai_budget_effects.txt` (`ai_budget_manipulation_effect`)
вместе с `00_ai.txt` (дефайны дележа) и `00_ai_values.txt` (бюджетные value-функции).
Цель: определить КАЖДУЮ функцию, затем пройти один счёт от 0 до 5000 со всеми
механизмами. Спец-архетипы (завоеватель/строитель/воин/осторожный) — только отличия
от БАЗЫ; база расписана целиком.

> **[есть]** — определено в наших файлах. **[НЕТ — дозапросить: …]** — не в проекте,
> указан файл. **[движок]** — встроенное, файла нет.

---

## ЧАСТЬ 1. ГЛОССАРИЙ — все функции/флаги/значения из эффекта

### 1A. Флаги, которые этот эффект САМ ставит (это не внешние функции)
| Флаг | Срок | Что значит | Где задаётся |
|---|---|---|---|
| `ai_boom` | 15 лет | «разрешение бумить экономику» (разблокировать казну в short_term) | стр. 252 |
| `ai_boom_cooldown` | 30 лет | пауза перед след. шансом на `ai_boom` | стр. 253 |
| `ai_save_gold_for_revoke` | 6 лет | «копить золото на отзыв титула вассала» (тиранская игра) | стр. 128/137/142 |
| `ai_revoke_recheck_cooldown` | 6 лет | пауза перед перепроверкой логики отзыва | стр. 145/161 |

**ЧТО ТАКОЕ `ai_boom` (ты спрашивал):** это НЕ отдельная функция, а **флаг, который ИИ
вешает сам на себя** (стр. 226–254):
```
limit: НЕ строитель, НЕ воин, НЕ осторожный, нет ai_boom_cooldown
random chance = primary_title.tier  (граф 2, герцог 3, король 4, имп. 5)  [в %]
               + diligent → +1 ;  + architect → +4
→ ставит ai_boom на 15 лет  И  ai_boom_cooldown на 30 лет
```
То есть **только «безличностный» ИИ** (без архетипа) с малым шансом (≈ номер яруса в %,
+1/+4 за черты) раз в прогон получает «бум-режим» на 15 лет, потом 30 лет кулдаун.
Архетипы (строитель/воин/осторожный) `ai_boom` НЕ получают — у них свои ветки.

### 1B. Бюджетные value-функции — **[есть]** в `00_ai_values.txt`
`war_chest_gold`, `long_term_gold`, `short_term_gold` — **[движок]** текущие суммы в
корзинах. `war_chest_gold_maximum` — **[движок]** цель/максимум казны =
`max(MIN_WAR_CHEST[ярус]; 18×содержание)`.

| Функция | Формула | Смысл |
|---|---|---|
| `halved_ai_war_chest_gold` | `war_chest_gold × 0.5` | половина ТЕКУЩЕЙ казны |
| `halved_ai_war_chest_gold_maximum` | `war_chest_gold_maximum × 0.5` | половина ЦЕЛИ казны |
| `excess_over_halved_ai_war_chest_gold` | `war_chest_gold − halved_..._maximum` | сколько казны сверх половины цели |
| `quarter_ai_war_chest_gold_maximum` | `war_chest_gold_maximum × 0.25` | четверть цели |
| `excess_over_a_quarter_ai_war_chest_gold` | `war_chest_gold − quarter_..._maximum` | сверх четверти цели |
| `cautious_ai_minimum_war_chest_gold` | `50` (+100 герц/+200 кор/+300 имп), кап = цель | осторожный пол |
| `excess_over_cautious_ai_minimum_war_chest_gold` | `war_chest_gold − cautious_min` | сверх осторожного пола |
| `conqueror_safe_spending_gold` | `war_chest_gold_maximum × 2` | завоеватель копит вдвое |
| `halved_faction_power_threshold` | `faction_power_threshold × 0.5` | порог силы фракции/2 |

(Для казны-сокровищницы — те же с `_treasury` (админ-правительство). Логика та же.)

### 1C. Дефайны дележа — **[есть]** в `00_ai.txt` / `00_defines.txt`
| Ключ | Значение |
|---|---|
| `BUDGET_CATEGORY` | Reserved 0.0 / War chest 0.0 / **long_term 0.20** / **short_term 0.80** |
| `BUDGET_CATEGORY_MAX` | `5000` на корзину (излишек переливается) |
| `BUDGET_CATEGORY_SHORT_TERM_MIN` | `{25 25 200 200 400 400 400}` (граф 200) |
| `MIN_WAR_CHEST` | `{25 25 50 100 200 300 400}` (граф 50) |
| `MONTHS_OF_MAINTENANCE_IN_WAR_CHEST` | `18` |
| `PERCENTAGE_INTO_WAR_CHEST` | `0.6` |
| латники: `..._gold_min/ideal/max` | `0.15 / 0.40 / 0.60` (доля дохода) |

### 1D. Эффекты перемещения — **[движок]**
`move_budget_gold = { gold = СКОЛЬКО from = budget_A to = budget_B }` — переносит
золото между `budget_war_chest` / `budget_long_term` / `budget_short_term`.
`move_budget_treasury` — то же для сокровищницы.

### 1E. Функции/триггеры, которых НЕТ у нас — **дозапросить**
| Идентификатор | Что это | Где лежит (по индексу) |
|---|---|---|
| `main_building_tier_1_cost` | цена постройки нового ХОЛДИНГА (T1) | **дозапросить `01_dynamic_values.txt`** (и/или `00_building_values.txt`) |
| `expensive_building_tier_1_cost` | порог престижа для племенной стройки | **дозапросить `01_dynamic_values.txt`** |
| `feudalize_holding_interaction_cost` | цена феодализации | **дозапросить `50_tribal_values.txt`** |
| `minimum_ai_gold_value_for_tyranny_wars` / `_treasury` | порог золота для тиран-войн | **дозапросить** (вероятно define/`01_dynamic_values.txt`) |
| `ai_has_warlike_personality` | триггер «воинственный» | **дозапросить `common/scripted_triggers/*`** |
| `ai_has_cautious_personality` | триггер «осторожный» | **дозапросить `common/scripted_triggers/*`** |
| `ai_has_builder_or_pious_builder_personality` | триггер «строитель» | **дозапросить `common/scripted_triggers/*`** |
| `ai_should_focus_on_building_in_their_capital` | триггер «фокус на стройке в столице» | **дозапросить `common/scripted_triggers/*`** |

### 1F. Встроенные скоупы/значения — **[движок]** (файла не нужно)
`is_ai`, `is_at_war`, `is_playable_character`, `has_treasury`, `treasury`, `gold`,
`prestige`, `primary_title.tier`, `domain_size`, `domain_limit`, `years_from_game_start`,
`current_military_strength`, `max_military_strength`, `capital_county/province`,
`free_building_slots`, `has_holding(_type)`, `barony_cannot_construct_holding`,
`has_innovation` (motte, city_planning), `days_of_continuous_peace`, `ai_boldness`,
`ai_rationality`, `tyranny`, `dread`, `has_trait` (diligent/architect/generous/just/…),
`any_ally`, `any_held_title`, `any_county_province`, `any_targeting_faction`,
`faction_power`, `government_has_flag` (tribal/nomadic), `has_realm_law_flag`,
`vassal_contract_has_flag`.

---

## ЧАСТЬ 2. БАЗА — как течёт бюджет (без архетипов)

Каждый месяц **доход** раскладывается (`00_ai.txt`):
1. **Reserved** (0 у обычных).
2. **Военная казна:** 60% дохода (`PERCENTAGE_INTO_WAR_CHEST`), пока `war_chest_gold <
   war_chest_gold_maximum` (= `max(50; 18×содержание)`).
3. **Остаток** делится: **20% → long_term, 80% → short_term** (`BUDGET_CATEGORY`).

Что какая корзина **тратит** (доказано эффектом):
- **short_term (80%)** → обычные здания (слоты) + латники (+ наёмники в войну).
- **long_term (20%)** → новые холдинги (`main_building`) + феодализация.
- **war chest** → война.

Поверх этого периодически гоняет `ai_budget_manipulation_effect` и **перекладывает**
деньги. БАЗА (безличностный ИИ, в мире, `war_chest_gold ≥ 10`, не копит на отзыв, нет
крупной угрозы-фракции; племя ещё требует `prestige ≥ expensive_building_tier_1_cost`):

**(а) Бросок на `ai_boom`** (стр. 236–254): шанс ≈ ярус% (+1/+4 черты) → флаг на 15 лет.

**(б) РАННЯЯ игра — есть свободные слоты построек ИЛИ фокус-стройка** (стр. 259+):
- **есть слот в столице** → **вся `war_chest_gold` → short_term** (стр. 282). ← БАЗА бумит!
  (то есть казна разблокируется в спендабельный short_term, и там тратится на здания/латников)
- иначе, если есть `ai_boom`/`ai_boldness ≥ 25`/diligent/architect (стр. 373):
  - **можно построить ХОЛДИНГ** (домен<лимит, хватает золота, есть инновации
    motte+city_planning, есть пустое баронство) → перенести `main_building_tier_1_cost`
    из war_chest И short_term **→ long_term**, и строить холдинг (стр. 382–417);
  - иначе → **вся war_chest → short_term** (стр. 420).

**(в) ПОЗДНЯЯ игра — слотов больше нет** (стр. 434+):
- безличностный с `ai_boom` И `boldness ≥ 25` → строить холдинг (long_term) или
  war_chest → short (стр. 585–636);
- безличностный с `ai_boom`, НЕ смелый → `excess_over_halved_ai_war_chest_gold` → short
  (оставляет половину казны) (стр. 637–655);
- **иначе (нет `ai_boom`, не смелый) → НИЧЕГО не двигает → казна копится впустую.**

**(г) Заплатка феодализации** (стр. 657–682): если не-племя сидит на племенном
холдинге — `feudalize_holding_interaction_cost` → long_term.

**Отличия архетипов от БАЗЫ (кратко, без деталей):**
- **Завоеватель** (стр. 164–183): выгребает long_term И short_term → **war_chest** (всё в войну).
- **Строитель** (стр. 317, 434): **всю казну → short_term** всегда (бумит максимально).
- **Воин** (стр. 352, 512, 561): копит казну; излишек в short только если казна полна и
  мир ≥5–7 лет; иначе **тянет long_term → war_chest**.
- **Осторожный** (стр. 329, 485): оставляет `cautious_ai_minimum_war_chest_gold`; бумит
  лишь если очень безопасно (мир 5 лет + 2 союзника / dread ≥ 50).
- **Авантюрист** (стр. 184): всё (long + war_chest) → short_term.

---

## ЧАСТЬ 3. ПРОХОД ОДНОГО СЧЁТА 0→5000 (short_term), все механизмы

Сценарий: **безличностный граф, доход +10/мес, мир, старт всё по 0.** Цель —
проследить **short_term** до потолка 5000, отмечая КАЖДУЮ функцию по пути. Цены зданий
точные **[НЕТ — дозапросить `01_dynamic_values.txt`]**; для иллюстрации беру слот-здание
≈100, латник ≈90/0.4 (`00_men_at_arms_values.txt`).

```
ЭТАП A. Наполнение военной казны (war_chest_gold → war_chest_gold_maximum=50)
  Механизмы: PERCENTAGE_INTO_WAR_CHEST=0.6, MIN_WAR_CHEST[граф]=50, MONTHS...=18.
  Доход 10 → 6 в war chest, остаток 4 делится BUDGET_CATEGORY: long +0.8, short +3.2.
  war chest 0→50 за ~8–9 мес. short_term накапливает ~30.

ЭТАП B. Эффект видит свободные слоты в столице (РАННЯЯ игра)
  Механизм: ai_budget_manipulation_effect, ветка стр. 282.
  move_budget_gold { war_chest_gold from war_chest to short_term }.
  → war chest 50 → 0, short_term += 50 (стало ~80). База БУМИТ: казна разблокирована.

ЭТАП C. short_term тратит на здание/латника (выбор §6)
  Механизмы: ai_men_at_arms_chance_expense_below_min/ideal (бросок латник-vs-здание),
             BUILDING_MIN_SCORE_COMPARED_TO_BEST=0.8 (здание не хуже 80% лучшего),
             латники: гейт ai_..._gold_ideal=0.40×доход, жёсткий лимит max_men_at_arms.
  short_term ≥ 100 → постройка −100 (или латник −90). short_term падает, копится заново.
  (Эффект на следующих прогонах снова сливает наполняемую war chest → short_term,
   пока есть свободные слоты → активная стройка/набор.)

ЭТАП D. Подушка ликвидности
  Механизм: BUDGET_CATEGORY_SHORT_TERM_MIN[граф]=200.
  Пока short_term < 200 — ИИ жмётся переводить в long_term/war chest (т.е. не копит
  на новый холдинг). Выше 200 — готов финансировать long_term.

ЭТАП E. Появилась возможность холдинга (пустое баронство + инновации motte+city_planning)
  Механизм: ветка стр. 382–417 (нужен ai_boom/boldness≥25/diligent/architect).
  move_budget_gold { main_building_tier_1_cost from war_chest → long_term }
  move_budget_gold { main_building_tier_1_cost from short_term → long_term }
  → деньги уходят из short_term в long_term, оттуда строится ХОЛДИНГ.
  [цена main_building_tier_1_cost — НЕТ, дозапросить]

ЭТАП F. Слоты кончились, латники у лимита, войны нет → тратить short_term НЕ на что
  Механизм: поздняя игра, безличностный БЕЗ ai_boom/смелости → эффект НИЧЕГО не двигает.
  short_term получает 80% дохода (+8/мес) и НЕ тратится → НАКАПЛИВАЕТСЯ.

ЭТАП G. short_term упирается в потолок 5000
  Механизм: BUDGET_CATEGORY_MAX=5000.
  Доход в short_term +8/мес; от ~30 до 5000 это ~620 мес (~52 года!) для графа +10.
  При достижении 5000 → излишек ПЕРЕЛИВАЕТСЯ в другую корзину (long_term).
  ⇒ Для бедного графа 5000 практически недостижимо → перелив не наступает.
     У богатого (доход +100) 5000 набегает за ~6 лет → перелив реально срабатывает.
```

**Главные выводы прохода:**
- БАЗА **бумит в ранней игре** (свободные слоты → war chest сливается в short_term →
  активно строит/набирает). Это НЕ «застой».
- «Застой/копит впустую» — это **поздняя игра** у безличностного ИИ **без `ai_boom`/
  смелости** (эффект перестаёт разблокировать казну) + всегда у **воинов/завоевателей**
  (выгребают всё в war chest).
- Потолок 5000 для бедных недостижим; «перелив между корзинами» — привилегия богатых.
- Латники и здания спорят за один short_term (§6); новые холдинги — отдельно из long_term.

---

## ЧАСТЬ 4. Чтобы добить ТОЧНЫЕ числа — дозапросить файлы
1. `common/scripted_values/01_dynamic_values.txt` — `main_building_tier_1_cost`,
   `expensive_building_tier_1_cost` (+ возможно tyranny-пороги).
2. `common/scripted_values/50_tribal_values.txt` — `feudalize_holding_interaction_cost`.
3. `common/scripted_triggers/*` (файл с `ai_has_*_personality`,
   `ai_should_focus_on_building_in_their_capital`) — чтобы знать ТОЧНЫЕ условия архетипов.
4. (Опц.) `common/men_at_arms/*`, `common/buildings/*` — реальные цены/размеры для
   полностью числового прохода.

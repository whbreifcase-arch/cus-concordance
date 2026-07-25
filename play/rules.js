/* ============================================================================
 * CUS — THE RULES SOURCE
 * v0.6 · one authoritative record per rule · three presentations
 * ----------------------------------------------------------------------------
 * WHY THIS FILE EXISTS
 *   Do not hand-author the tutorial, the quick reference and the full rulebook
 *   separately — they will drift. Every rule is stored ONCE, here, and the
 *   three doors of PLAY CUS are rendered from it:
 *
 *     FIRST_BATTLE.html   ← trigger · instruction · consequence · diagram
 *     HELP.html           ← trigger · help_bucket · related
 *     HOW_TO_PLAY_v1_5    ← formal_name · exact_rule · cites
 *
 * AUTHORITY
 *   CUS v0.6, CLOSED 2026-07-24. `cites` names the governing section of
 *   ../A_KERNEL_CONSTITUTION.md or ../B_COMBAT_MODULE.md. If this file ever
 *   disagrees with A or B, A and B win and this file is a bug.
 *
 * WHY .js AND NOT .json
 *   These pages are opened both from GitHub Pages and by double-clicking the
 *   file. fetch() of a local .json fails on file:// . A plain script that
 *   assigns a global works in both places and needs no build step — which
 *   matters, because this machine has neither node nor python.
 *
 * COPY DISCIPLINE (enforced by cusRulesLint() at the bottom of this file)
 *   trigger      ≤ 12 words · the physical event, in plain language
 *   instruction  ≤ 20 words · what the player does now
 *   consequence  ≤ 20 words · what changed
 *   instruction + consequence ≤ 35 words — the guided-lesson hard limit.
 *   exact_rule   unbounded · reference prose, never shown in guided play
 * ========================================================================== */

window.CUS_RULES = (function () {
  'use strict';

  /* ------------------------------------------------------------------ meta */
  const meta = {
    cus_version: '0.6',
    spec_version: '1.0',
    dated: '2026-07-25',
    authority: 'CUS_KERNEL_REBUILD — A_KERNEL_CONSTITUTION.md, B_COMBAT_MODULE.md (v0.6, CLOSED 2026-07-24)',
    figure_data: 'CUS_FACTIONS/data/faction_militia.json, faction_goblin.json',
    packet_data: 'CUS_FACTIONS/data/packets_family.json',
    screen_map: '../PLAY_FIRST_BATTLE_SCREENMAP.md',
    verbs: 'MOVE | ACTION | WAIT'
  };

  /* ---------------------------------------------------------------- tokens
   * The diagram language. Locked from the footer of HOW_TO_PLAY_v1_5.html —
   * this is not new, it is the grammar already shipping. A diagram may not
   * use a mark absent from this table; new marks are added HERE first and
   * then applied to every existing diagram.                                */
  const tokens = [
    { token: 'base_black',   render: 'solid black base',      means: 'the figure currently acting' },
    { token: 'base_white',   render: 'white outlined base',   means: 'the figure receiving' },
    { token: 'base_grey',    render: 'grey base',             means: 'present but irrelevant this screen' },
    { token: 'base_dashed',  render: 'dashed base',           means: 'where a figure WAS' },
    { token: 'base_solid',   render: 'solid base',            means: 'where a figure IS' },
    { token: 'notch',        render: 'notch on the base edge',means: 'facing — Squares only; Circles have none' },
    { token: 'hatch',        render: 'hatching',              means: 'wall / impassable structure' },
    { token: 'gold',         render: 'gold',                  means: 'movement · action · bonus · legal choice' },
    { token: 'red',          render: 'red',                   means: 'wound · death · failed check · illegal destination' },
    { token: 'ring',         render: 'thin ring',             means: 'reach or effect distance' },
    { token: 'arrow_big',    render: 'large directional arrow', means: 'forced movement' },
    { token: 'arrow_curved', render: 'small curved arrow',    means: 'reface / rotate' }
  ];

  /* ----------------------------------------------------------------- rules
   * teach_tier:
   *   'core'      the first activation — the only material learned before play
   *   'event'     just-in-time, fired by a board event
   *   'reference' HELP + FULL REFERENCE only; never a guided screen
   * provisional: true  → B·9b, unratified. NEVER rendered in guided play.   */
  const rules = [

    /* ============================ THE CORE LOOP ============================ */
    {
      id: 'OBJECTIVE', formal_name: 'Scenario Objective', teach_tier: 'core',
      trigger: 'The battle begins',
      instruction: 'Every scenario tells you what must be won.',
      consequence: 'Everything else is how you win it.',
      diagram: 'obj-establish', help_bucket: null, cites: 'B·intent',
      exact_rule: 'Complete the scenario objective. That is the whole game — every ' +
        'other rule exists only to describe how a round happens. Intent is separate ' +
        'from resolution (A·XI): the scenario states what must be accomplished; the ' +
        'Kernel states how figures accomplish it.',
      related: ['ALTERNATION']
    },
    {
      id: 'ALTERNATION', formal_name: 'Alternating Activation', teach_tier: 'core',
      trigger: 'It is your turn',
      instruction: 'Choose one figure that has not activated.',
      consequence: 'When it finishes, your opponent chooses one.',
      diagram: 'alt-focus', help_bucket: null, cites: 'B·12',
      exact_rule: 'Side A activates one Figure → Side B activates one Figure → repeat ' +
        'until exhausted. If one side runs out of eligible Figures, the other resolves ' +
        'its remainder one at a time. Wild/uncontrolled figures resolve afterward per ' +
        'the owning procedure. Alternation is attention management — a camera that ' +
        'directs focus to the hottest fight — not initiative bookkeeping.',
      related: ['ACTIVATED', 'AP']
    },
    {
      id: 'AP', formal_name: 'Agency (AP)', teach_tier: 'core',
      trigger: 'A figure is selected',
      instruction: 'AP is what a figure can spend this activation. Read it off the base.',
      consequence: '1 AP buys one MOVE, one ACTION or one WAIT.',
      diagram: 'ap-read', help_bucket: null, cites: 'A·IV, B·15',
      exact_rule: 'Agency is the resource a Figure spends to act. The printed default ' +
        'is Circle 3 AP · Square 2 AP — higher agency for the hero, lower for the crew. ' +
        'It is a DEFAULT, not a law: a figure\'s AP is whatever its card prints ' +
        '(the Watch Sergeant is a Square with 3 AP). Always read the figure. ' +
        'One attack per activation, regardless of AP. MOVE may be taken before or ' +
        'after an ACTION. WAIT ends the activation.',
      related: ['BASE_CIRCLE', 'BASE_SQUARE', 'ONE_ATTACK', 'VERBS']
    },
    {
      id: 'VERBS', formal_name: 'MOVE · ACTION · WAIT', teach_tier: 'core',
      trigger: 'The figure needs to do something',
      instruction: 'Spend 1 AP on one of three verbs.',
      consequence: 'There are only ever these three.',
      diagram: 'verbs-hub', help_bucket: null, cites: 'A·III',
      exact_rule: 'CUS has three canonical verbs and no others. MOVE changes Position ' +
        'now. ACTION resolves a PACKET now. WAIT arms a PACKET for later. Combat ' +
        'renames them for flavour — MOVE→Advance, ACTION→Strike/Interact/Cast, ' +
        'WAIT→Brace/Overwatch — but the player reads the flavour and the system reads ' +
        'MOVE · ACTION · WAIT.',
      related: ['MOVE', 'ACTION', 'WAIT']
    },
    {
      id: 'MOVE', formal_name: 'MOVE', teach_tier: 'core',
      trigger: 'The figure changes position',
      instruction: 'Move up to the figure\'s Speed.',
      consequence: 'One AP is spent.',
      diagram: 'move-drag', help_bucket: 'moving', cites: 'A·III, B·2',
      exact_rule: 'MOVE changes Position now. Choose a legal destination or trajectory, ' +
        'pay Agency, change Position. Obstacles are paid inline as part of one ' +
        'continuous MOVE — no stop-spend-move. Climbing or vaulting costs extra Agency ' +
        'per story. Dropping one story is free and harmless. Domain aliases — Advance, ' +
        'Sprint, Leap, Withdraw — are all MOVE.',
      related: ['SPRINT', 'ENGAGED', 'DISENGAGE']
    },
    {
      id: 'ACTION', formal_name: 'ACTION', teach_tier: 'core',
      trigger: 'The figure does something to someone',
      instruction: 'Choose one of this figure\'s packets and resolve it.',
      consequence: 'One AP is spent. This is your attack for the activation.',
      diagram: 'packet-choose', help_bucket: 'attacking', cites: 'A·III, B·5',
      exact_rule: 'ACTION resolves a PACKET now — strike, use, cast. Only one attack ' +
        'may be made per activation, however much AP remains.',
      related: ['PACKET', 'ONE_ATTACK', 'DECLARE']
    },
    {
      id: 'WAIT', formal_name: 'WAIT', teach_tier: 'core',
      trigger: 'The player chooses to prepare something',
      instruction: 'Choose a packet to trigger later.',
      consequence: 'Waiting ends this figure\'s activation.',
      diagram: 'wait-arm', help_bucket: 'waiting', cites: 'A·III, B·15',
      exact_rule: 'WAIT arms a PACKET for later — it does not resolve now. The armed ' +
        'packet waits on a trigger. WAIT ends the activation even if AP remains. ' +
        'Brace, Overwatch, Ready and the automatic Counter all live in the WAIT family ' +
        '(deferred resolution).',
      related: ['COUNTER', 'BRACE']
    },
    {
      id: 'ONE_ATTACK', formal_name: 'One Attack Per Activation', teach_tier: 'event',
      trigger: 'You already attacked this activation',
      instruction: 'A figure attacks once per activation.',
      consequence: 'Spare AP may still buy a MOVE or a WAIT.',
      diagram: 'hub-action-spent', help_bucket: 'attacking', cites: 'B·15',
      exact_rule: 'One attack per activation, regardless of remaining AP. Remaining AP ' +
        'may still be spent on MOVE or WAIT. MOVE may be taken before or after the ' +
        'attack. This constraint only bites on a figure with 3 or more AP.',
      related: ['AP', 'ACTION', 'MOVE_ANYTIME']
    },
    {
      id: 'MOVE_ANYTIME', formal_name: 'Move Before or After', teach_tier: 'reference',
      trigger: 'You want to move after attacking',
      instruction: 'MOVE may be spent before or after an ACTION.',
      consequence: 'The order is yours.',
      diagram: null, help_bucket: 'moving', cites: 'B·15',
      exact_rule: 'There is no fixed movement phase. AP is spent in any order the ' +
        'player chooses within the activation, subject only to one attack per ' +
        'activation and to WAIT ending the activation.',
      related: ['AP', 'ONE_ATTACK']
    },
    {
      id: 'ACTIVATED', formal_name: 'Activated', teach_tier: 'core',
      trigger: 'The figure has spent its AP',
      instruction: 'Mark the figure Activated.',
      consequence: 'Your opponent now chooses one figure.',
      diagram: 'pass-play', help_bucket: null, cites: 'B·12',
      exact_rule: 'A Figure that has activated is marked and may not be chosen again ' +
        'this round. Play passes to the other side, which chooses one of its own ' +
        'un-activated Figures.',
      related: ['ALTERNATION', 'END_ROUND']
    },
    {
      id: 'END_ROUND', formal_name: 'End of Round', teach_tier: 'reference',
      trigger: 'Every figure has activated',
      instruction: 'Clear all Activated marks.',
      consequence: 'A new round begins.',
      diagram: null, help_bucket: null, cites: 'B·12',
      exact_rule: 'When both sides are exhausted, the round ends and every Figure ' +
        'becomes eligible again. If one side runs out first, the other resolves its ' +
        'remaining Figures one at a time. NOT TAUGHT IN FIRST BATTLE — deliberately ' +
        'withheld until the player has completed an activation.',
      related: ['ALTERNATION', 'ACTIVATED']
    },

    /* ============================== THE BASES ============================== */
    {
      id: 'BASE_CIRCLE', formal_name: 'Circle Base', teach_tier: 'reference',
      trigger: 'The base is round',
      instruction: 'A Circle is a hero. It is faceless — it has no facing.',
      consequence: 'It cannot be flanked, never tests Nerve and never breaks.',
      diagram: 'base-circle', help_bucket: 'positioning', cites: 'B·1',
      exact_rule: 'Circle = hero / avatar. Faceless — no facing, so angle never matters ' +
        'to or from a Circle and it can never be flanked or backstabbed. It always ' +
        'Counters, from any angle. It never tests Nerve and never breaks. It cannot ' +
        'Brace (a faceless base has no facing to fix). Printed default 3 AP. A Banner ' +
        'fields EXACTLY ONE Circle: its Champion. Every other figure is a Square. ' +
        'A Circle is cracked by numbers, not by angles — see Mob.',
      related: ['BASE_SQUARE', 'MOB', 'COUNTER']
    },
    {
      id: 'BASE_SQUARE', formal_name: 'Square Base', teach_tier: 'core',
      trigger: 'The base has corners',
      instruction: 'A Square is crew. It has a facing — read the notch.',
      consequence: 'Orientation matters as much as position.',
      diagram: 'base-square', help_bucket: 'positioning', cites: 'B·1',
      exact_rule: 'Square = crew / commandable body. Has a facing. May test Nerve, may ' +
        'break. Printed default 2 AP — but read the card; the Watch Sergeant is a ' +
        'Square with 3 AP. A Square trades agency for mutual protection: locked facing ' +
        'when Braced, breakable morale, no independent agency once it Routs — in ' +
        'exchange for formation, shields and the shoulder of the man beside it.',
      related: ['BASE_CIRCLE', 'FRONT', 'FLANK', 'REAR', 'NERVE']
    },
    {
      id: 'SIZE', formal_name: 'Size — Small · Medium · Large', teach_tier: 'reference',
      trigger: 'The footprints are different',
      instruction: 'Read the footprint: Small, Medium or Large.',
      consequence: 'Size decides who plows whom.',
      diagram: 'size-three', help_bucket: 'large', cites: 'B·1',
      exact_rule: 'Three classes, read from the footprint. Square: Small 20mm, Medium ' +
        '25mm, Large 40mm. Circle: Small 25mm, Medium 32mm, Large 40mm. There is no ' +
        'Monstrous class and no Cavalry class. A "monstrous" creature is simply a Large ' +
        'figure distinguished by its traits — e.g. unstoppable — not by a fourth size.',
      related: ['SIZE_PLOW', 'MOUNTED', 'UNSTOPPABLE']
    },
    {
      id: 'MOUNTED', formal_name: 'Mounted', teach_tier: 'reference',
      trigger: 'The base is elongated',
      instruction: 'An elongated base is mounted.',
      consequence: 'It plows as one size class larger.',
      diagram: 'mounted-plow', help_bucket: 'large', cites: 'B·1, B·4',
      exact_rule: 'Mounted is geometry, not a size class. An elongated base — Small, ' +
        'Medium or Large — communicates mounted geometry: narrow frontage penetrates ' +
        'deeply, wide frontage bulldozes broadly. A mounted figure keeps its size class ' +
        'and plows as one class larger (the lance). There is no heavy/light cavalry ' +
        'split; cavalry doctrine emerges from Role · Tempo · Tool · Temperament · ' +
        'PACKETs · geometry.',
      related: ['SIZE', 'SIZE_PLOW', 'IMPACT']
    },
    {
      id: 'TRAIT', formal_name: 'Trait', teach_tier: 'reference',
      trigger: 'The card lists something it always has',
      instruction: 'A trait is always true. It resolves nothing.',
      consequence: 'It is a property, not an action.',
      diagram: null, help_bucket: null, cites: 'B·14',
      exact_rule: 'Traits are referenced passive Definitions — Large, Flying, Mounted, ' +
        'Fearless, Amphibious, Reach, Unstoppable. A Trait is defined once and ' +
        'referenced by ID on a figure, exactly like a PACKET but passive: it is never ' +
        'an ACTION/WAIT-resolved effect and never holds runtime state. Traits are not ' +
        'PACKETs and not size classes.',
      related: ['REACH', 'UNSTOPPABLE', 'MOUNTED']
    },

    /* ========================== ATTACK RESOLUTION ========================== */
    {
      id: 'PACKET', formal_name: 'PACKET', teach_tier: 'core',
      trigger: 'You choose what the figure does',
      instruction: 'A packet is one thing a figure can do. Follow the card.',
      consequence: 'Everything you need is printed on it.',
      diagram: 'packet-choose', help_bucket: 'attacking', cites: 'A·V, B·5',
      exact_rule: 'A PACKET is the universal referenced definition — the executable ' +
        'unit of what a figure can do. A combat PACKET may define dice · success_number ' +
        '· range/reach · area · cost · grades · effects. It is referenced, never copied ' +
        'onto each weapon. PACKETs are stateless: they hold no runtime state.',
      related: ['DECLARE', 'ROLL', 'GRADE', 'EFFECT']
    },
    {
      id: 'DECLARE', formal_name: 'Declare the Target', teach_tier: 'core',
      trigger: 'A packet is selected',
      instruction: 'Name who you are hitting.',
      consequence: 'Only legal targets may be chosen.',
      diagram: 'target-declare', help_bucket: 'attacking', cites: 'B·5',
      exact_rule: 'Declare target, then verify legality — Position decides what is ' +
        'legal. A melee packet (range 0) requires base contact, or the reach band if ' +
        'the packet or figure has Reach. An illegal declaration costs nothing; choose ' +
        'again.',
      related: ['PACKET', 'ENGAGED', 'REACH']
    },
    {
      id: 'ROLL', formal_name: 'Roll the Dice', teach_tier: 'core',
      trigger: 'The target is declared',
      instruction: 'Roll the packet\'s dice, modified by position.',
      consequence: 'Position changes dice, not numbers.',
      diagram: 'roll-dice', help_bucket: 'attacking', cites: 'B·5',
      exact_rule: 'Load modifiers first — position, facing, environment; prefer Position ' +
        'over numbers — then roll the packet\'s dice pool. Flank adds +1 die; Rear adds ' +
        '+2 dice; a wall-jam Crush adds +2 dice; a Braced figure adds +1 die into its ' +
        'front arc and imposes −1 die on enemies attacking that arc.',
      related: ['SUCCESS', 'FLANK', 'REAR', 'MOB']
    },
    {
      id: 'SUCCESS', formal_name: 'Success', teach_tier: 'core',
      trigger: 'The dice are rolled',
      instruction: 'Every die that meets or beats the packet\'s number is a Success.',
      consequence: 'Count them.',
      diagram: 'roll-dice', help_bucket: 'attacking', cites: 'A·VI, B·6',
      exact_rule: 'A Success is a die equal to or greater than the PACKET\'s success ' +
        'number. Count successes; the count is the Grade reached.',
      related: ['GRADE', 'ROLL']
    },
    {
      id: 'GRADE', formal_name: 'Success Grade', teach_tier: 'core',
      trigger: 'The successes are counted',
      instruction: 'Your Successes are your Grade. Read the highest Grade you reached.',
      consequence: 'That one line is your result.',
      diagram: 'grade-read', help_bucket: 'attacking', cites: 'A·VI, B·6',
      exact_rule: 'Grade is how WELL a roll succeeded. A combat PACKET lists its Grades ' +
        'against a success count; you read the highest Grade you reached. Do not call ' +
        'it a Tier, a Ladder or a Rung.',
      related: ['GRADE_DISCRETE', 'EFFECT', 'SUCCESS']
    },
    {
      id: 'GRADE_DISCRETE', formal_name: 'Discrete Grades (Model 2)', teach_tier: 'core',
      trigger: 'You reached a higher Grade',
      instruction: 'Read only the line you reached.',
      consequence: 'A higher Grade does not carry up the lower ones.',
      diagram: 'grade-read', help_bucket: 'attacking', cites: 'A·VI, B·5',
      exact_rule: 'SIGNED (William, 2026-07-24) — Model 2, Discrete. Read the single ' +
        'Grade you reached and resolve ONLY the Effects written on that line. A higher ' +
        'Grade does not carry up lower Grades\' Effects. Authoring rule: write each ' +
        'Grade line as a complete result; if an Effect should appear at several Grades, ' +
        'print it on each. No accumulation, no best-Wound-plus-every-passed-Effect.',
      related: ['GRADE', 'EFFECT']
    },
    {
      id: 'EFFECT', formal_name: 'Effect', teach_tier: 'core',
      trigger: 'The Grade line names something',
      instruction: 'Resolve every Effect printed on that Grade line.',
      consequence: 'Effects change state — wounds, position, condition.',
      diagram: null, help_bucket: 'attacking', cites: 'B·6',
      exact_rule: 'An Effect is the state change a Grade resolves — Wound, Shove, ' +
        'Knockdown, Guard, Cleave, Execute, ignore-Armour, and others. Effects are ' +
        'printed per Grade line and read only from the line reached.',
      related: ['GRADE_DISCRETE', 'SHOVE', 'ARMOUR']
    },
    {
      id: 'ARMOUR', formal_name: 'Armour', teach_tier: 'core',
      trigger: 'A Wound is about to land',
      instruction: 'The defender rolls one save die per incoming Wound.',
      consequence: 'Unsaved Wounds land.',
      diagram: 'armour-save', help_bucket: 'wounded', cites: 'B·7',
      exact_rule: 'Armour rolls one save die per incoming Wound. None — · Light 6+ · ' +
        'Medium 5+ · Heavy 4+. A save that would worsen past 6+ can no longer save. ' +
        'Unsaved Wounds apply to the health track.',
      related: ['WOUND_TRACK', 'EFFECT']
    },
    {
      id: 'WOUND_TRACK', formal_name: 'The Wound Track', teach_tier: 'event',
      trigger: 'A figure takes damage',
      instruction: 'Step the figure along its track.',
      consequence: 'Fine → Hurt → Knocked Out → Dead.',
      diagram: 'wound-track', help_bucket: 'wounded', cites: 'B·7',
      exact_rule: 'Health track: Fine → Hurt → Knocked Out → Dead. Each unsaved Wound ' +
        'steps the figure one place along it. A figure with a 1-Wound track is removed ' +
        'by the first unsaved Wound.',
      related: ['ARMOUR', 'SHOCK']
    },

    /* ======================= CONTACT AND POSITIONING ======================= */
    {
      id: 'ENGAGED', formal_name: 'Engaged', teach_tier: 'event',
      trigger: 'Your bases touched',
      instruction: 'These two figures are now Engaged.',
      consequence: 'Squares turn to face each other.',
      diagram: 'engaged-contact', help_bucket: 'touched', cites: 'B·8',
      exact_rule: 'Bases touching = engaged. There is no measured band — if two bases ' +
        'are in contact, the figures are engaged, full stop. Engaging turns Squares to ' +
        'face each other; Circles are faceless, so angle never matters to or from a ' +
        'Circle. A figure faces the enemy it is engaged with.',
      related: ['DISENGAGE', 'COUNTER', 'REACH', 'FRONT']
    },
    {
      id: 'DISENGAGE', formal_name: 'Disengage', teach_tier: 'event',
      trigger: 'Someone is trying to leave a fight',
      instruction: 'Spend 1 AP to Disengage before you move away.',
      consequence: 'Leaving an engagement is never free.',
      diagram: 'engaged-disengage', help_bucket: 'touched', cites: 'B·8',
      exact_rule: 'Leaving an engagement costs a Disengage — 1 AP — paid before the ' +
        'MOVE that carries you away. A Small figure is the exception: it slips through ' +
        'without an ordinary Disengage.',
      related: ['ENGAGED', 'MOVE', 'SIZE_PLOW']
    },
    {
      id: 'COUNTER', formal_name: 'Counter', teach_tier: 'event',
      trigger: 'You attacked someone',
      instruction: 'The defender strikes back — one melee packet.',
      consequence: 'It turns to face you. You are now engaged.',
      diagram: 'counter-turn', help_bucket: 'touched', cites: 'B·9',
      exact_rule: 'Attack a figure and it Counters — one melee PACKET back — and turns ' +
        'to face you; you are now engaged. A free (unengaged) target ALWAYS gets its ' +
        'swing and is pulled into engagement with its attacker: the first attacker on ' +
        'an open figure eats the Counter. Structurally a Counter is a PACKET armed ' +
        'against the trigger "struck by an enemy", so it lives in the WAIT family even ' +
        'though it fires automatically. The ONLY ways to deny a Counter are positional: ' +
        'a Square already engaged with another enemy struck on its unfaced flank or ' +
        'rear; or a Reach strike made without base contact. A Circle is faceless and ' +
        'always Counters, from any angle.',
      related: ['COUNTER_DYING', 'COUNTER_NO_LOOP', 'ENGAGED', 'FLANK', 'REAR', 'REACH']
    },
    {
      id: 'COUNTER_DYING', formal_name: 'The Dying Swing', teach_tier: 'event',
      trigger: 'The figure you killed strikes back',
      instruction: 'A figure Counters even as it dies.',
      consequence: 'There is no cap — it Counters every attacker.',
      diagram: 'counter-dying', cinematic: 'the-dying-swing',
      help_bucket: 'touched', cites: 'B·9',
      exact_rule: 'SIGNED (William, 2026-07-24). There is no per-round limit on Counters ' +
        'and no counter_x economy: a figure Counters EVERY enemy that attacks it, and ' +
        'Counters even as it dies. Worked example — you attack a figure, engage, it ' +
        'Counters and kills you; your body is shoved off; that same figure is now free ' +
        'and will Counter the next attacker who steps up.',
      related: ['COUNTER', 'COUNTER_NO_LOOP']
    },
    {
      id: 'COUNTER_NO_LOOP', formal_name: 'A Counter Draws No Counter', teach_tier: 'event',
      trigger: 'You wonder whether it loops forever',
      instruction: 'A Counter is a response, not an attack.',
      consequence: 'It draws no Counter of its own.',
      diagram: null, help_bucket: 'touched', cites: 'B·9',
      exact_rule: 'SIGNED (William, 2026-07-24). A Counter does not itself draw a ' +
        'Counter — a Counter is a response, not an ATTACK — so two figures never loop ' +
        'forever.',
      related: ['COUNTER', 'COUNTER_DYING']
    },
    {
      id: 'REACH', formal_name: 'Reach', teach_tier: 'reference',
      trigger: 'Someone tries to walk past a spear',
      instruction: 'A Reach figure threatens a 1–2″ band without base contact.',
      consequence: 'A Reach strike from outside contact draws no Counter.',
      diagram: 'reach-band', help_bucket: 'touched', cites: 'B·8, B·14',
      exact_rule: 'Reach is the exception to base-contact. A Reach figure threatens a ' +
        '1–2″ band and may strike a figure that tries to move past within that reach ' +
        'WITHOUT base contact — so you cannot just walk by a spearman. A Reach strike ' +
        'from outside contact is not engagement and draws no Counter, because the reach ' +
        'striker is not glued to its target. Reach is a Trait, and/or a PACKET property.',
      related: ['ENGAGED', 'COUNTER', 'TRAIT']
    },
    {
      id: 'FRONT', formal_name: 'Front Arc', teach_tier: 'reference',
      trigger: 'You attack the face it is turned to',
      instruction: 'A front attack is normal.',
      consequence: 'No bonus, and it Counters.',
      diagram: 'angle-front', help_bucket: 'positioning', cites: 'B·8',
      exact_rule: 'A figure faces the enemy it is engaged with. Engaging or Countering ' +
        'turns a Square to face; otherwise a Square refaces on its own turn. An attack ' +
        'into the faced arc is ordinary and draws a Counter.',
      related: ['FLANK', 'REAR', 'BASE_SQUARE']
    },
    {
      id: 'FLANK', formal_name: 'Flank', teach_tier: 'event',
      trigger: 'You struck a side it was not facing',
      instruction: 'A flank attack rolls +1 die.',
      consequence: 'It faces its other foe, not you.',
      diagram: 'angle-flank', help_bucket: 'positioning', cites: 'B·8, B·9',
      exact_rule: 'A Square already engaged with another enemy faces THAT foe, so a new ' +
        'attacker reaching its flank strikes an arc it is not facing: +1 die, and no ' +
        'Counter. A Circle is faceless and can never be flanked.',
      related: ['REAR', 'FRONT', 'COUNTER', 'BASE_CIRCLE']
    },
    {
      id: 'REAR', formal_name: 'Rear · Backstab', teach_tier: 'event',
      trigger: 'You reached its back',
      instruction: 'A rear attack rolls +2 dice.',
      consequence: 'It draws no Counter.',
      diagram: 'angle-rear', help_bucket: 'positioning', cites: 'B·8, B·9',
      exact_rule: 'A Square already engaged with another enemy, struck in its rear arc, ' +
        'suffers +2 attack dice and does not Counter. A Circle is faceless and can never ' +
        'be backstabbed.',
      related: ['FLANK', 'FRONT', 'COUNTER', 'BASE_CIRCLE']
    },
    {
      id: 'MOB', formal_name: 'Mob', teach_tier: 'reference',
      trigger: 'Several figures gang up on one',
      instruction: 'Each extra attacker adds dice.',
      consequence: 'Numbers are how you crack a hero.',
      diagram: 'mob-dice', help_bucket: 'positioning', cites: 'B·8, B·9b',
      exact_rule: 'Extra attackers on the same target add dice. A Circle has no flanks, ' +
        'so numbers — not angles — are how a hero is cracked. Squares fear angles; ' +
        'Circles fear numbers.',
      related: ['BASE_CIRCLE', 'FLANK', 'ROLL']
    },

    /* ========================= MOVEMENT AND IMPACT ========================= */
    {
      id: 'SPRINT', formal_name: 'Sprint', teach_tier: 'event',
      trigger: 'You moved twice',
      instruction: 'A second MOVE in one activation is a Sprint.',
      consequence: 'Both AP went to movement.',
      diagram: 'sprint-second', help_bucket: 'moving', cites: 'B·3',
      exact_rule: 'Charge is retired as a keyword — it collided with movement. Sprint is ' +
        'simply continued MOVE. The figure stays in its Sprint; "charge" survives only ' +
        'as flavour. Sprint through bodies = MOVE + N× Impact resolutions + Position ' +
        'changes.',
      related: ['MOVE', 'IMPACT']
    },
    {
      id: 'IMPACT', formal_name: 'Impact', teach_tier: 'event',
      trigger: 'Your sprint reached an enemy',
      instruction: 'A Sprint that contacts a body resolves an Impact.',
      consequence: 'Keep a straight course; move each base the minimum.',
      diagram: 'impact-contact', help_bucket: 'moving', cites: 'B·3, B·4',
      exact_rule: 'Impact names the collision a Sprint creates and its resolution — not ' +
        'the movement producing it. Two bases cannot share space: a moving base ' +
        'continues along its straight trajectory and displaces contacted bases the ' +
        'minimum needed to clear its path. Slide the models; do not measure. ' +
        'Displacement is not damage — the Push changes Position; any Wound or state ' +
        'change comes from the PACKET the Impact resolves.',
      related: ['SPRINT', 'PUSH', 'INDENT', 'CRUSH', 'SIZE_PLOW']
    },
    {
      id: 'PUSH', formal_name: 'Push', teach_tier: 'event',
      trigger: 'The target can move aside',
      instruction: 'Shove the contacted body aside, just enough to clear your lane.',
      consequence: 'You keep moving.',
      diagram: 'impact-push', help_bucket: 'moving', cites: 'B·4',
      exact_rule: 'Step 1 of the Impact cascade. Shove the contacted body aside enough ' +
        'to clear the lane, and no further. "Push" here names the charge plow only — the ' +
        'weapon displacement effect is now Shove.',
      related: ['IMPACT', 'INDENT', 'CRUSH', 'SHOVE']
    },
    {
      id: 'INDENT', formal_name: 'Indent', teach_tier: 'event',
      trigger: 'Bodies behind it blocked the shove',
      instruction: 'Carry them forward instead.',
      consequence: 'The line dents.',
      diagram: 'impact-indent', help_bucket: 'moving', cites: 'B·4',
      exact_rule: 'Step 2 of the Impact cascade. If bodies behind the contacted figure ' +
        'block the sideways shove, carry them forward; the line dents.',
      related: ['IMPACT', 'PUSH', 'CRUSH']
    },
    {
      id: 'CRUSH', formal_name: 'Crush', teach_tier: 'event',
      trigger: 'The line is against a wall',
      instruction: 'The mover jams and stops.',
      consequence: 'Nowhere to go — the Impact gains +2 dice.',
      diagram: 'impact-crush', help_bucket: 'moving', cites: 'B·4',
      exact_rule: 'Step 3 of the Impact cascade. If a wall or obstacle prevents ' +
        'clearance, the mover jams and stops, and the Impact receives the appropriate ' +
        'bonus — nowhere to go means it crushes. The poster prints this as +2 attack ' +
        'dice. The wall-crush is the only place a blocked shove feeds the hit.',
      related: ['IMPACT', 'INDENT', 'PUSH']
    },
    {
      id: 'SIZE_PLOW', formal_name: 'Who Plows Whom', teach_tier: 'reference',
      trigger: 'A big base meets a small one',
      instruction: 'Larger bodies plow smaller; same-size plow grudgingly.',
      consequence: 'Small does not plow — it slips through.',
      diagram: 'size-plow', help_bucket: 'large', cites: 'B·4',
      exact_rule: 'Size gating across Small · Medium · Large: larger bodies plow ' +
        'smaller; same-size plow grudgingly; Small does not plow — it slips through ' +
        'without an ordinary Disengage; Mounted (elongated) plows as one class larger ' +
        '(the lance); a head-on clearing tie is the mover\'s choice; movement continues ' +
        'until Agency/Move is exhausted or the mover jams.',
      related: ['SIZE', 'MOUNTED', 'UNSTOPPABLE', 'IMPACT', 'DISENGAGE']
    },
    {
      id: 'UNSTOPPABLE', formal_name: 'Unstoppable', teach_tier: 'reference',
      trigger: 'It shoves through bodies unchecked',
      instruction: 'Only a wall stops it.',
      consequence: 'This is a trait, not a size class.',
      diagram: 'unstoppable', help_bucket: 'large', cites: 'B·4, B·14',
      exact_rule: 'A figure that should shove through bodies unchecked — the old ' +
        '"Monstrous" — carries the trait unstoppable, rather than occupying a fourth ' +
        'size class. Only a wall stops its Push. The canonical monster is a Large figure ' +
        'plus this trait.',
      related: ['TRAIT', 'SIZE', 'SIZE_PLOW', 'CRUSH']
    },

    /* ============================ CONSEQUENCES ============================= */
    {
      id: 'SHOCK', formal_name: 'Shock', teach_tier: 'event',
      trigger: 'It was wounded, or a friend fell nearby',
      instruction: 'A Square tests Nerve when it is Wounded, or a friend falls within 3″.',
      consequence: 'One test per shock.',
      diagram: 'nerve-shock', help_bucket: 'shocked', cites: 'B·10',
      exact_rule: 'A Square suffers a shock and tests Nerve when: it is Wounded by an ' +
        'ATTACK (took a hit and lived), OR a friendly figure within 3″ is slain or goes ' +
        'Broken. One test per shock. A PACKET may also force a test through an Effect ' +
        '(a Terror rung). Only Squares of Creature Type Man or Beast test. Circles never ' +
        'test — heroes hold. Spirit and Construct never test — fearless.',
      related: ['NERVE', 'MORALE', 'WOUND_TRACK']
    },
    {
      id: 'NERVE', formal_name: 'The Nerve Test', teach_tier: 'event',
      trigger: 'The figure must test',
      instruction: 'Roll 3 dice. Count dice that meet or beat its Nerve.',
      consequence: '0 steps down · 1–2 hold · 3 steps up.',
      diagram: 'nerve-roll', help_bucket: 'shocked', cites: 'B·10',
      exact_rule: 'Roll 3 dice; each die equal to or greater than the figure\'s Nerve ' +
        'value is a success. Read the successes against the morale track: 0 successes ' +
        'steps DOWN one state (Steady → Shaken → Broken); 1–2 successes HOLD, no change; ' +
        '3 successes step UP one state (Shaken → Steady). The test reads like every ' +
        'other roll in CUS — a small pool, a success number, count successes — so ' +
        'nothing new is learned.',
      related: ['SHOCK', 'MORALE', 'BROKEN', 'RALLY']
    },
    {
      id: 'MORALE', formal_name: 'Morale — Steady · Shaken · Broken', teach_tier: 'event',
      trigger: 'The test is read',
      instruction: 'Move the figure along the morale track.',
      consequence: 'Steady → Shaken → Broken.',
      diagram: 'nerve-read', help_bucket: 'shocked', cites: 'B·10',
      exact_rule: 'Morale track, in threes: Steady → Shaken → Broken. A failed test ' +
        'steps a Square down the track. Rally steps a figure back up. Creature Type may ' +
        'alter the branch.',
      related: ['NERVE', 'BROKEN', 'RALLY']
    },
    {
      id: 'BROKEN', formal_name: 'Broken', teach_tier: 'event',
      trigger: 'A figure becomes Broken',
      instruction: 'A Broken figure Routs.',
      consequence: 'How it routs is set by its Temperament.',
      diagram: 'morale-broken', help_bucket: 'shocked', cites: 'B·10',
      exact_rule: 'Broken = it Routs, behaving by its Temperament. Circles never break.',
      related: ['TEMPERAMENT', 'MORALE', 'RALLY']
    },
    {
      id: 'RALLY', formal_name: 'Rally', teach_tier: 'reference',
      trigger: 'A leader steadies the line',
      instruction: 'Rally steps a figure up the morale track.',
      consequence: 'Broken → Shaken → Steady.',
      diagram: null, help_bucket: 'shocked', cites: 'B·10',
      exact_rule: 'Rally — a leader\'s USE — steps a figure up one state toward Steady. ' +
        'The leader trait radiates Rally within 6″ on its activation.',
      related: ['MORALE', 'NERVE', 'BROKEN']
    },
    {
      id: 'TEMPERAMENT', formal_name: 'Temperament', teach_tier: 'event',
      trigger: 'It broke — what does it do?',
      instruction: 'Read only this figure\'s Temperament.',
      consequence: 'It decides how it routs, and how it acts leaderless.',
      diagram: 'temperament-five', help_bucket: 'shocked', cites: 'A·VII, B·10',
      exact_rule: 'Temperament governs what a figure does when LEADERLESS (its AI ' +
        'fallback) and when it goes BROKEN (Routs). ' +
        'Cowardly — leaderless: keeps distance, avoids danger, strikes only with the ' +
        'odds; Broken: flees to its own table edge. ' +
        'Resolute — leaderless: holds or pursues the objective; Broken: falls back ' +
        'toward its leader or the objective, does not flee outright. ' +
        'Aggressive — leaderless: advances on the nearest enemy; Broken: one last ' +
        'reckless advance at the nearest enemy. ' +
        'Protective — leaderless: guards or stays close to the nearest ally; Broken: ' +
        'retreats to the nearest ally. ' +
        'Ravenous — leaderless: attacks the nearest figure, any side; Broken: turns ' +
        'Wild, attacking the nearest figure, friend or foe.',
      variants: {
        Cowardly:   { rout: 'It flees to its own table edge.',              diagram: 'temperament-cowardly' },
        Resolute:   { rout: 'It falls back toward its leader.',             diagram: 'temperament-resolute' },
        Aggressive: { rout: 'It makes one last reckless advance.',          diagram: 'temperament-aggressive' },
        Protective: { rout: 'It retreats to the nearest ally.',             diagram: 'temperament-protective' },
        Ravenous:   { rout: 'It turns Wild — it attacks friend or foe.',    diagram: 'temperament-ravenous' }
      },
      related: ['BROKEN', 'MORALE']
    },

    /* =============================== RANGED =============================== */
    {
      id: 'RANGED_PRECISION', formal_name: 'Precision Shot', teach_tier: 'reference',
      trigger: 'You want the best possible shot',
      instruction: 'Do not move. Roll +1 die and ignore cover.',
      consequence: 'It ends the activation.',
      diagram: 'ranged-precision', help_bucket: 'ranged', cites: 'B·15 (poster)',
      exact_rule: 'PRECISION — no MOVE this activation · +1 die · ignore cover · ends ' +
        'the activation.',
      related: ['RANGED_REGULAR', 'RANGED_MULTI']
    },
    {
      id: 'RANGED_REGULAR', formal_name: 'Regular Shot', teach_tier: 'reference',
      trigger: 'You want to move and shoot',
      instruction: 'Move and shoot normally.',
      consequence: 'No bonus, no penalty.',
      diagram: 'ranged-regular', help_bucket: 'ranged', cites: 'B·15 (poster)',
      exact_rule: 'REGULAR — move and shoot normally.',
      related: ['RANGED_PRECISION', 'RANGED_MULTI']
    },
    {
      id: 'RANGED_MULTI', formal_name: 'Multi-shot', teach_tier: 'reference',
      trigger: 'You want two shots',
      instruction: 'Take two shots.',
      consequence: 'Your hit number worsens one step.',
      diagram: 'ranged-multi', help_bucket: 'ranged', cites: 'B·15 (poster)',
      exact_rule: 'MULTI-SHOT — two shots · hit worsens one step.',
      related: ['RANGED_PRECISION', 'RANGED_REGULAR']
    },

    /* =================== PROVISIONAL — B·9b, NOT RATIFIED ==================
     * provisional: true. NEVER rendered in guided play. Rendered in HELP and
     * FULL REFERENCE behind a visible PROVISIONAL flag.                    */
    {
      id: 'SHIELD', formal_name: 'Shield — the intercept', teach_tier: 'reference',
      provisional: true,
      trigger: 'An ally within 1″ is about to be hit',
      instruction: 'Declare it before the packet resolves — take the hit yourself.',
      consequence: 'Your armour saves. You draw no Counter.',
      diagram: 'shield-intercept', help_bucket: 'touched', cites: 'B·9b',
      exact_rule: 'PROVISIONAL — ratify after the first game. A shield is gear (a ' +
        'Trait). It grants a reaction: consume an ACTION packet aimed at a friendly ' +
        'within 1″ and take the hit yourself instead. You must declare it in the moment, ' +
        'before the packet resolves — miss the window, miss the save; it is an act of ' +
        'attention, not an automatic shield. The interceptor\'s own Armour rolls against ' +
        'it and unsaved Wounds land on him. No Counter — he was not the one attacked and ' +
        'is not in contact. No cap — a shieldman can eat hit after hit for his line; the ' +
        'cap is that he dies. Works regardless of facing, even while Braced. Intercepts ' +
        'melee and ranged alike. A shield wall is not a skill — it is emergent geometry.',
      related: ['BRACE', 'MOB', 'ARMOUR']
    },
    {
      id: 'BRACE', formal_name: 'Brace', teach_tier: 'reference',
      provisional: true,
      trigger: 'You want to hold one direction',
      instruction: 'Lock your facing. +1 die into your front; enemies into it roll −1.',
      consequence: 'Your flank and rear get in free, with no Counter.',
      diagram: 'brace-stance', help_bucket: 'waiting', cites: 'B·9b',
      exact_rule: 'PROVISIONAL — ratify after the first game. Brace is a universal ' +
        'action: any Square may do it; it is not a special ability and is never printed ' +
        'on a card. It is a WAIT — 1 AP, ends your activation, lasts until your next ' +
        'activation — that locks your facing and turns you into a wall in one direction. ' +
        '+1 die attacking into your front arc; enemies attacking your front roll −1 die. ' +
        'The price: you cannot turn. Anything striking your flank or rear gets in free ' +
        'and you do not Counter it. Circles cannot Brace — a faceless base has no facing ' +
        'to fix. A Shove breaks Brace.',
      related: ['WAIT', 'SHOVE', 'SHIELD', 'BASE_SQUARE']
    },
    {
      id: 'SHOVE', formal_name: 'Shove', teach_tier: 'reference',
      provisional: true,
      trigger: 'A Grade line says Shove',
      instruction: 'Move the target straight away from you, up to 1″.',
      consequence: 'It ends no more than 1″ from you. A Shove breaks a Brace.',
      diagram: 'shove-effect', help_bucket: 'attacking', cites: 'B·9b, B·6',
      exact_rule: 'PROVISIONAL — ratify after the first game. The Grade effect once ' +
        'called Push is now SHOVE, so "push" is free for ordinary language and the §4 ' +
        'charge-plow keeps the word cleanly. SHOVE: move the target directly away from ' +
        'you, up to X″, ending no more than Y″ from you. Default X = Y = 1″; X and Y are ' +
        'tunable per weapon or effect. In contact the target is knocked back to ~1″; ' +
        'already ~1″ out (a Reach band) it barely moves — a spear holds a foe at bay, it ' +
        'does not launch him across the table. A Shove against a Braced figure breaks the ' +
        'Brace instead of merely nudging it: shove the wall out of line, then hit the ' +
        'gap. Distinct from the charge Push → Indent → Crush plow, which is unchanged.',
      related: ['BRACE', 'PUSH', 'EFFECT']
    }
  ];

  /* --------------------------------------------------------------- packets
   * Mirrored verbatim from CUS_FACTIONS/data/packets_family.json.
   * Only the packets First Battle can reach.                              */
  const packets = [
    {
      packet_id: 'militia_sword', name: 'COMMON WEAPON', verb: 'ACTION',
      dice: 3, success: 4, range: 0, cost_ap: 1,
      grades: [
        { grade: 1, successes: 1, effects: ['1 Wound'] },
        { grade: 2, successes: 2, effects: ['1 Wound', 'Shove'] },
        { grade: 3, successes: 3, effects: ['2 Wounds'] }
      ]
    },
    {
      packet_id: 'goblin_shiv', name: 'COMMON WEAPON', verb: 'ACTION',
      dice: 2, success: 4, range: 0, cost_ap: 1,
      grades: [
        { grade: 1, successes: 1, effects: ['1 Wound'] },
        { grade: 2, successes: 2, effects: ['1 Wound', 'Shove'] }
      ]
    }
  ];

  /* --------------------------------------------------------------- figures
   * Mirrored verbatim from CUS_FACTIONS/data/. Nothing is invented here.  */
  const figures = [
    {
      definition_id: 'MIL_SWORD', name: 'Militia Swordsman', faction: 'The Freeholt Militia',
      role: 'Pressure', tempo: '>>', tool: 'Melee', temperament: 'Resolute',
      creature_type: 'Man', archetype: 'Swordsman', rank: 'I',
      base: { shape: 'Square', size: 'Medium', mounted: false },
      stats: { max_wounds: 2, armour: 'Medium', armour_save: 5, nerve: 3, speed: 6, max_ap: 2 },
      traits: [], packets: ['militia_sword'],
      tutorial_note: 'Chosen as the tutorial figure because it carries ZERO traits — ' +
        'the only militia profile with no exception attached to it.'
    },
    {
      definition_id: 'GOB_WARRIOR', name: 'Goblin Warrior', faction: 'The Gnash Horde',
      role: 'Pressure', tempo: '>>', tool: 'Melee', temperament: 'Cowardly',
      creature_type: 'Man', archetype: 'Warrior', rank: 'I',
      base: { shape: 'Square', size: 'Small', mounted: false },
      stats: { max_wounds: 1, armour: 'Light', armour_save: 6, nerve: 4, speed: 7, max_ap: 2 },
      traits: ['expendable'], packets: ['goblin_shiv'],
      tutorial_note: 'The expendable trait is defined as "its fall within 3\\" is a ' +
        'shock that tests nearby allies\' Nerve" — so the Nerve lesson is caused by the ' +
        'board, not staged.'
    }
  ];

  /* -------------------------------------------------------------- scenario
   * The scripted First Battle board. Positions in inches, 12x12 field,
   * player south. Every distance is load-bearing — see the screen map §1.2. */
  const scenario = {
    id: 'FIRST_BATTLE_PART_ONE',
    title: 'Your First Activation',
    field: { w: 12, h: 12 },
    objective: { at: [6.0, 10.0], label: 'THE WELL', note: 'Behind the goblins — you cannot walk around the lesson.' },
    terrain: [
      { type: 'wall', token: 'hatch', from: [2.0, 9.0], to: [10.0, 9.0], gap_at: 4.0,
        note: 'The Crush surface. The gap keeps the scenario winnable.' }
    ],
    figures: [
      { id: 'S', def: 'MIL_SWORD',    side: 'player', at: [6.0, 2.0], facing: 'N',
        note: '4.0" from contact against Speed 6 — MOVE is a distance you choose, not a jump.' },
      { id: 'A', def: 'GOB_WARRIOR',  side: 'enemy',  at: [6.0, 6.0], facing: 'S',
        note: 'The first target.' },
      { id: 'B', def: 'GOB_WARRIOR',  side: 'enemy',  at: [7.6, 6.0], facing: 'S',
        note: '1.6" from A — inside the 3" shock band. This is the Nerve trigger.' },
      { id: 'C', def: 'GOB_WARRIOR',  side: 'enemy',  at: [4.4, 6.0], facing: 'S',
        note: '1.6" from A — blocks the sideways shove, so a Sprint resolves to INDENT.' }
    ],
    withheld: ['REACH', 'RANGED_PRECISION', 'RANGED_REGULAR', 'RANGED_MULTI',
               'BASE_CIRCLE', 'MOUNTED', 'SIZE', 'UNSTOPPABLE', 'MOB',
               'SHIELD', 'BRACE', 'SHOVE', 'END_ROUND', 'PUSH', 'CRUSH'],
    withheld_because: 'Principle: no exception unless it is currently happening. ' +
      'Nothing provisional is ever taught to a beginner.'
  };

  /* ------------------------------------------------------------------ flow
   * The First Battle screen graph. Screens carry no rule text of their own —
   * `renders` names the rule id(s) every word is drawn from.
   * Full specification: ../PLAY_FIRST_BATTLE_SCREENMAP.md                 */
  const flow = {
    entry: 'FB-01',
    state_shape: {
      ap_left: 2, attack_used: false, activation_over: false,
      engaged_with: null, moves_this_activation: 0, facing: 'N',
      wounds: {}, morale: {}, seen_lessons: []
    },
    spine: [
      { id: 'FB-01',  renders: ['OBJECTIVE'],   diagram: 'obj-establish',   button: 'BEGIN BATTLE',        to: 'FB-02' },
      { id: 'FB-02',  renders: ['ALTERNATION'], diagram: 'alt-focus',       button: 'CHOOSE THIS FIGURE',  to: 'FB-03' },
      { id: 'FB-03',  renders: ['AP', 'BASE_SQUARE'], diagram: 'ap-read',   button: 'SPEND AP',            to: 'FB-04',
        headline_from: 'figure.stats.max_ap', note: 'Never hard-code the AP number.' },
      { id: 'FB-04',  renders: ['VERBS', 'MOVE', 'ACTION', 'WAIT'], diagram: 'verbs-hub', hub: true,
        tiles: [
          { verb: 'MOVE',   to: 'FB-M1', enabled_when: 'ap_left > 0' },
          { verb: 'ACTION', to: 'FB-A1', enabled_when: 'ap_left > 0 && !attack_used',
            disabled_caption_from: 'ONE_ATTACK' },
          { verb: 'WAIT',   to: 'FB-W1', enabled_when: 'ap_left > 0' }
        ],
        exit_when: 'ap_left === 0 || activation_over', exit_to: 'FB-99' },

      { id: 'FB-M1',  renders: ['MOVE'],        diagram: 'move-drag',       button: 'FINISH MOVE',         to: 'ROUTER-M', interactive: true },
      { id: 'FB-A1',  renders: ['ACTION', 'PACKET'], diagram: 'packet-choose', button: 'CHOOSE TARGET',    to: 'FB-A1b' },
      { id: 'FB-A1b', renders: ['DECLARE'],     diagram: 'target-declare',  button: null,                  to: 'FB-A2', interactive: true,
        no_legal_target: { inline: 'NOTHING IS IN REACH', to: 'FB-04', spend_ap: false } },
      { id: 'FB-A2',  renders: ['ROLL', 'SUCCESS'], diagram: 'roll-dice',   button: 'ROLL',                to: 'FB-A2b' },
      { id: 'FB-A2b', renders: ['GRADE', 'GRADE_DISCRETE'], diagram: 'grade-read', button: 'APPLY THE GRADE', to: 'FB-A2c' },
      { id: 'FB-A2c', renders: ['ARMOUR', 'WOUND_TRACK'], diagram: 'armour-save', button: 'APPLY WOUNDS',  to: 'ROUTER-A' },
      { id: 'FB-W1',  renders: ['WAIT'],        diagram: 'wait-arm',        button: 'ARM PACKET',          to: 'FB-99' },
      { id: 'FB-99',  renders: ['ACTIVATED', 'ALTERNATION'], diagram: 'pass-play', button: 'PASS TO OPPONENT', to: 'END-CARD' }
    ],
    routers: {
      'ROUTER-M': [
        { when: 'moves_this_activation === 2', to: 'LE-SPRINT' },
        { when: 'engaged_with !== null',       to: 'LE-ENGAGED' },
        { when: 'else',                        to: 'FB-04' }
      ],
      'ROUTER-A': [
        { when: 'wounds_landed > 0', to: 'LE-WOUND' },
        { when: 'else',              to: 'LE-COUNTER' }
      ],
      'ROUTER-N': [
        { when: 'friendly Square (Man/Beast) within 3" of a slain or Broken friend', to: 'LE-NERVE' },
        { when: 'else', to: 'FB-04' }
      ]
    },
    lessons: [
      { id: 'LE-ENGAGED', fires_when: 'engaged_with became non-null after a MOVE', returns_to: 'FB-04',
        pages: [
          { renders: 'ENGAGED',    diagram: 'engaged-contact' },
          { renders: 'DISENGAGE',  diagram: 'engaged-disengage' },
          { renders: 'COUNTER',    diagram: 'engaged-counter-tease', tease: true }
        ] },
      { id: 'LE-COUNTER', fires_when: 'any ACTION-attack resolved', forced: true, returns_to: 'ROUTER-N',
        pages: [
          { renders: 'COUNTER',        diagram: 'counter-turn' },
          { renders: 'COUNTER_DYING',  diagram: 'counter-dying', cinematic: 'the-dying-swing',
            also: ['COUNTER_NO_LOOP'] }
        ] },
      { id: 'LE-WOUND', fires_when: 'wounds landed', returns_to: 'LE-COUNTER',
        pages: [
          { renders: 'WOUND_TRACK', diagram: 'wound-track' },
          { renders: 'WOUND_TRACK', diagram: 'wound-remove', variant: 'kill' }
        ] },
      { id: 'LE-NERVE', fires_when: 'a friend fell within 3"', returns_to: 'FB-04',
        pages: [
          { renders: 'SHOCK',  diagram: 'nerve-shock' },
          { renders: 'NERVE',  diagram: 'nerve-roll', value_from: 'figure.stats.nerve' },
          { renders: 'MORALE', diagram: 'nerve-read' },
          { renders: 'BROKEN', diagram: 'morale-broken', only_when: 'became Broken', to: 'LE-TEMPERAMENT' }
        ] },
      { id: 'LE-TEMPERAMENT', fires_when: 'a figure went Broken', returns_to: 'FB-04',
        pages: [
          { renders: 'TEMPERAMENT', diagram_from: 'variants[figure.temperament].diagram',
            reveal: 'this figure only — never all five' }
        ] },
      { id: 'LE-SPRINT', fires_when: 'moves_this_activation === 2', returns_to: 'LE-IMPACT or FB-99',
        pages: [
          { renders: 'SPRINT', diagram: 'sprint-second' },
          { renders: 'AP',     diagram: 'sprint-cost', angle: 'both AP went to movement' }
        ] },
      { id: 'LE-IMPACT', fires_when: 'a Sprint reached a body', returns_to: 'FB-99',
        pages: [
          { renders: 'IMPACT', diagram: 'impact-contact' },
          { renders: 'IMPACT', diagram: 'impact-question', angle: 'can the target move aside?' },
          { renders: 'INDENT', diagram: 'impact-indent',
            optional_expand: [
              { renders: 'PUSH',  diagram: 'impact-push' },
              { renders: 'CRUSH', diagram: 'impact-crush' }
            ] }
        ] },
      { id: 'LE-ANGLE', fires_when: 'NOT REACHABLE IN PART ONE — specified for HELP', returns_to: 'FB-04',
        pages: [
          { renders: 'FLANK', diagram: 'angle-flank' },
          { renders: 'REAR',  diagram: 'angle-rear' }
        ] }
    ]
  };

  /* ------------------------------------------------------------------ help
   * HELP ME NOW asks "WHAT IS HAPPENING?" and reaches the answer in two
   * taps. Buckets are the first tap; `related` chains are the second.     */
  const help = [
    { bucket: 'moving',      label: 'Moving',                icon: 'move',
      questions: ['How far can it go?', 'It moved twice', 'It ran into someone', 'It wants to leave a fight'] },
    { bucket: 'attacking',   label: 'Attacking',             icon: 'action',
      questions: ['How do I resolve a packet?', 'How many dice?', 'Which Grade line do I read?', 'It has an effect I do not know'] },
    { bucket: 'touched',     label: 'Bases touched',         icon: 'engaged',
      questions: ['Are the bases touching?', 'Did one figure just attack?', 'Is someone trying to leave?', 'Is the attacker using Reach?'] },
    { bucket: 'positioning', label: 'Positioning',           icon: 'flank',
      questions: ['Which way is it facing?', 'I came in from the side', 'I reached its back', 'Several of us are on one figure'] },
    { bucket: 'wounded',     label: 'Wounded or Shocked',    icon: 'wound',
      questions: ['A wound landed', 'Does armour save?', 'It has to test Nerve', 'It broke — what now?'] },
    { bucket: 'shocked',     label: 'Nerve and Morale',      icon: 'shock',
      questions: ['What causes a test?', 'How do I roll it?', 'What does the result mean?', 'How does it break?'] },
    { bucket: 'waiting',     label: 'Waiting',               icon: 'wait',
      questions: ['What can I arm?', 'When does it fire?', 'Does it end my activation?'] },
    { bucket: 'ranged',      label: 'Ranged attack',         icon: 'ranged',
      questions: ['Which shooting mode?', 'Does cover apply?', 'Can I move and shoot?'] },
    { bucket: 'large',       label: 'Large or mounted',      icon: 'large',
      questions: ['Can it pass through?', 'Who plows whom?', 'What does mounted change?', 'What stops an Unstoppable figure?'] }
  ];

  /* ------------------------------------------------------------------ lint
   * Enforces the copy discipline at load time in dev. Call cusRulesLint()
   * from the console; it returns [] when the corpus is clean.             */
  function cusRulesLint() {
    const wc = s => (s || '').trim().split(/\s+/).filter(Boolean).length;
    const ids = new Set(rules.map(r => r.id));
    const out = [];
    for (const r of rules) {
      if (wc(r.trigger) > 12)      out.push(r.id + ': trigger ' + wc(r.trigger) + ' words (max 12)');
      if (wc(r.instruction) > 20)  out.push(r.id + ': instruction ' + wc(r.instruction) + ' words (max 20)');
      if (wc(r.consequence) > 20)  out.push(r.id + ': consequence ' + wc(r.consequence) + ' words (max 20)');
      if (wc(r.instruction) + wc(r.consequence) > 35)
        out.push(r.id + ': instruction+consequence ' + (wc(r.instruction) + wc(r.consequence)) + ' words (max 35)');
      if (!r.exact_rule) out.push(r.id + ': no exact_rule');
      if (!r.cites)      out.push(r.id + ': no citation');
      for (const rel of (r.related || []))
        if (!ids.has(rel)) out.push(r.id + ': related -> unknown id "' + rel + '"');
      if (r.provisional && r.teach_tier !== 'reference')
        out.push(r.id + ': PROVISIONAL rules may never be teach_tier "core" or "event"');
    }
    // every rule the flow renders must exist
    const rendered = new Set();
    for (const s of flow.spine) (s.renders || []).forEach(x => rendered.add(x));
    for (const l of flow.lessons) for (const p of l.pages) {
      if (p.renders) rendered.add(p.renders);
      (p.also || []).forEach(x => rendered.add(x));
      (p.optional_expand || []).forEach(e => rendered.add(e.renders));
    }
    for (const id of rendered) if (!ids.has(id)) out.push('flow renders unknown rule id "' + id + '"');
    // nothing provisional may be reachable in guided play
    for (const id of rendered) {
      const r = rules.find(x => x.id === id);
      if (r && r.provisional) out.push('flow reaches PROVISIONAL rule "' + id + '" in guided play');
    }
    return out;
  }

  const byId = Object.fromEntries(rules.map(r => [r.id, r]));

  return {
    meta, tokens, rules, byId, packets, figures, scenario, flow, help,
    lint: cusRulesLint,
    /* convenience accessors for the three renderers */
    guided:    () => rules.filter(r => !r.provisional && r.teach_tier !== 'reference'),
    forBucket: b  => rules.filter(r => r.help_bucket === b),
    reference: () => rules.slice().sort((a, b) => a.formal_name.localeCompare(b.formal_name))
  };
})();

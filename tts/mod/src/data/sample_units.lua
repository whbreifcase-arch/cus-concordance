-- data/sample_units.lua
-- Embedded unit-definition fixture (mirrors data/sample_units.json). These are
-- what you paste into a card's GM Notes (or spawn via the test fixture). Cards
-- own the DEFINITION; miniatures own runtime state.
CUS = CUS or {}
CUS.SAMPLE_UNITS = {
  {
    schema_version = 1, definition_id = "MIL_SWORD_01", name = "Militia Swordsman",
    role = "Assault", tool = "Melee", creature_type = "Man", archetype = "Swordsman", signature = "Shield Drill",
    stats = { max_wounds = 2, armour = "Medium", speed = 6, max_ap = 2, nerve = 3, rank = "I" },
    base = { shape = "Square", class = "Normal", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_SWORD_01" }, ability_packet_ids = { "ABIL_GUARD_01" },
    temperament = "Resolute",
    display = { card_image_url = "", weapon = "Sword", dice = 3, hit = "3+", tiers = "1→1W · 3→Guard",
                armour = "5+", base = "Square / Normal", note = "" },
  },
  {
    schema_version = 1, definition_id = "MIL_SPEAR_01", name = "Militia Spearman",
    role = "Anchor", tool = "Melee", creature_type = "Man", archetype = "Spearman", signature = "Brace",
    stats = { max_wounds = 2, armour = "Light", speed = 6, max_ap = 2, nerve = 3, rank = "I" },
    base = { shape = "Square", class = "Normal", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_SPEAR_01" }, ability_packet_ids = { "ABIL_BRACE_01", "ABIL_REACH_PASSIVE" },
    temperament = "Resolute",
    display = { card_image_url = "", weapon = "Spear (Reach)", dice = 2, hit = "4+", tiers = "1→1W · 2→Push",
                armour = "6+", base = "Square / Normal", note = "Reach: no lock, no Counter suffered." },
  },
  {
    schema_version = 1, definition_id = "GOB_ARCHER_01", name = "Goblin Archer",
    role = "Skirmisher", tool = "Ranged", creature_type = "Man", archetype = "Archer", signature = "Skulk",
    stats = { max_wounds = 1, armour = "None", speed = 7, max_ap = 2, nerve = 2, rank = "I" },
    base = { shape = "Square", class = "Small", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_BOW_01" }, ability_packet_ids = { "ABIL_OVERWATCH_01" },
    temperament = "Cowardly",
    display = { card_image_url = "", weapon = "Bow", dice = 2, hit = "4+", tiers = "1→1W · 3→2W",
                armour = "—", base = "Square / Small", note = "Never countered." },
  },
  {
    schema_version = 1, definition_id = "GOB_BOSS_01", name = "Goblin Warboss",
    role = "Assault", tool = "Melee", creature_type = "Man", archetype = "Berserker", signature = "Reckless",
    counter_uses = 2,
    stats = { max_wounds = 3, armour = "Light", speed = 6, max_ap = 3, nerve = 4, rank = "III" },
    base = { shape = "Circle", class = "Large", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_GREATAXE_01" }, ability_packet_ids = {},
    temperament = "Aggressive",
    display = { card_image_url = "", weapon = "Greataxe", dice = 3, hit = "5+", tiers = "1→1W · 2→2W · 3→Cleave",
                armour = "6+", base = "Circle / Large", note = "Circle hero — never tests Nerve. Counter 2." },
  },
  {
    schema_version = 1, definition_id = "CHAMP_ASSN_01", name = "Shadowblade Champion",
    role = "Skirmisher", tool = "Melee", creature_type = "Man", archetype = "Assassin", signature = "Backstab",
    stats = { max_wounds = 2, armour = "None", speed = 8, max_ap = 3, nerve = 5, rank = "III" },
    base = { shape = "Circle", class = "Normal", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_ASSASSIN_01", "ATK_DAGGER_01" }, ability_packet_ids = { "ABIL_HEAL_01" },
    temperament = "Aggressive",
    display = { card_image_url = "", weapon = "Assassin Blade", dice = 3, hit = "3+", tiers = "1→1W · 3→2W · 5→Execute",
                armour = "—", base = "Circle / Normal", note = "Champion (3 AP). Circle hero." },
  },
  {
    schema_version = 1, definition_id = "SKEL_CON_01", name = "Bone Construct",
    role = "Anchor", tool = "Melee", creature_type = "Construct", archetype = "Sentinel", signature = "Tireless",
    stats = { max_wounds = 2, armour = "Heavy", speed = 5, max_ap = 2, nerve = 0, rank = "I" },
    base = { shape = "Square", class = "Normal", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_SWORD_01" }, ability_packet_ids = {},
    temperament = "Resolute",
    display = { card_image_url = "", weapon = "Sword", dice = 3, hit = "3+", tiers = "1→1W · 3→Guard",
                armour = "4+", base = "Square / Normal", note = "Construct — never tests Nerve." },
  },
}

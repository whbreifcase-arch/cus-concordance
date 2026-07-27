-- data/card_layout.lua
-- The DEFAULT card layout for the mod, stored as the SAME JSON text the HTML
-- Card Forge uses (single source of truth). Global decodes it into
-- CUS.CARD_LAYOUT at load. Editing zones in-game (nudge editor) mutates the
-- decoded table; Export prints JSON you can paste back into card_layout.json /
-- the HTML forge, and Import accepts pasted JSON. Keep this in sync with
-- data/card_layout.json (build/bundle.ps1 does not auto-sync these two).
CUS = CUS or {}
CUS.CARD_LAYOUT_JSON = [==[
{
  "card": { "aspect_w": 5, "aspect_h": 7, "bg": "#141821", "fg": "#e8f0ff", "accent": "#8fd0ff" },
  "zones": {
    "name":   { "x": 0.06, "y": 0.035, "w": 0.88, "h": 0.10, "size": 0.070, "align": "left",   "label": "",      "show": true },
    "role":   { "x": 0.06, "y": 0.140, "w": 0.44, "h": 0.045, "size": 0.034, "align": "left",   "label": "",      "show": true },
    "tool":   { "x": 0.06, "y": 0.185, "w": 0.44, "h": 0.040, "size": 0.030, "align": "left",   "label": "",      "show": true },
    "base":   { "x": 0.50, "y": 0.140, "w": 0.44, "h": 0.045, "size": 0.032, "align": "right",  "label": "",      "show": true },
    "temper": { "x": 0.50, "y": 0.185, "w": 0.44, "h": 0.040, "size": 0.030, "align": "right",  "label": "",      "show": true },
    "dice":   { "x": 0.06, "y": 0.600, "w": 0.21, "h": 0.070, "size": 0.045, "align": "center", "label": "DICE ", "show": true },
    "hit":    { "x": 0.29, "y": 0.600, "w": 0.19, "h": 0.070, "size": 0.045, "align": "center", "label": "HIT ",  "show": true },
    "wounds": { "x": 0.50, "y": 0.600, "w": 0.19, "h": 0.070, "size": 0.045, "align": "center", "label": "W ",    "show": true },
    "armour": { "x": 0.71, "y": 0.600, "w": 0.23, "h": 0.070, "size": 0.045, "align": "center", "label": "ARM ",  "show": true },
    "speed":  { "x": 0.06, "y": 0.680, "w": 0.21, "h": 0.060, "size": 0.038, "align": "center", "label": "SPD ",  "show": true },
    "ap":     { "x": 0.29, "y": 0.680, "w": 0.19, "h": 0.060, "size": 0.038, "align": "center", "label": "AP ",   "show": true },
    "nerve":  { "x": 0.50, "y": 0.680, "w": 0.19, "h": 0.060, "size": 0.038, "align": "center", "label": "NRV ",  "show": true },
    "rank":   { "x": 0.71, "y": 0.680, "w": 0.23, "h": 0.060, "size": 0.038, "align": "center", "label": "RANK ", "show": true },
    "weapon": { "x": 0.06, "y": 0.770, "w": 0.88, "h": 0.050, "size": 0.040, "align": "left",   "label": "",      "show": true },
    "tiers":  { "x": 0.06, "y": 0.825, "w": 0.88, "h": 0.060, "size": 0.032, "align": "left",   "label": "",      "show": true },
    "note":   { "x": 0.06, "y": 0.895, "w": 0.88, "h": 0.085, "size": 0.028, "align": "left",   "label": "",      "show": true }
  }
}
]==]

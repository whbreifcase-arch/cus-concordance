# CUS_FACTIONS — the build system (source of the play/ pages)

Everything to regenerate the game content lives here. Python 3.11 + a couple stdlib-only scripts.

## Layout
- `data/`  — all the game data (v0.6 JSON): packets*.json, packet_index.json, traits.json,
  faction_*.json (the armies), library_generic.json (generic profiles), faction_bestiary.json (enemies).
- `sim/`   — the engine + tools:
  - `engine.py`, `game.py`  — the from-scratch v0.6 combat engine (spatial + elevation).
  - `loader.py`             — loads the JSON into engine objects.
  - `scenarios.py`          — 5 mechanic tests (run this after any engine change).
  - `balance.py`            — pricing + parallel round-robin.  `python balance.py vs <a> <b> <games> <budget>`
  - `matrix.py`             — all-vs-all balance matrix.
  - `make_banner.py`        — regenerates BANNER.html from the data.
  - `render3d.py`           — regenerates BATTLE_3D.html.

## Rebuild the pages
    cd sim
    python make_banner.py     # -> ../BANNER.html   (copy to ../../play/BANNER.html to publish)
    python render3d.py        # -> ../BATTLE_3D.html
    python scenarios.py       # sanity: 5/5 should pass

## Publish
Copy the generated HTML into the repo's `play/` folder, commit, push — GitHub Pages serves it.
The working copy on the original machine was `C:\Users\WH407\Downloads\forge\CUS_FACTIONS`;
this `factions/` folder in the repo is the same tree, version-controlled.

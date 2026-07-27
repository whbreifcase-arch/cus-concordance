# Named hotkeys

The mod registers **named** hotkeys, so you bind keys yourself in
*Options → Game Keys* (TTS never lets a mod hijack Alt-zoom or guarantee Esc, so
nothing is hard-captured). Recommended mappings:

| Named action | Suggested key | What it does |
|---|---|---|
| **CUS: Action Wheel** | `Q` | Open the radial wheel for the hovered miniature |
| **CUS: Open Card** | `C` | Toggle the linked card image (player-local) |
| **CUS: Move** | `M` | Begin a tracked MOVE for the hovered miniature |
| **CUS: Attack** | `F` | Begin an attack on the hovered attacker; **press again while hovering the defender** to pick the target |
| **CUS: Ready** | `R` | Open the READY branch for the hovered miniature |
| **CUS: Activate / End Activation** | `E` | Toggle the hovered miniature's activation |
| **CUS: Cancel Operation** | `X` | Close all CUS panels / cancel the current flow |
| **CUS: Undo Last State Change** | `Z` | Pop the script-state undo stack |

## Notes on the targeting flow
Because TTS exposes **no global left-click event on objects**, target selection
uses **hover + hotkey** rather than a raw click (which also prevents accidental
attacks, matching the Codex intent):

```
hover attacker → CUS: Attack → pick packet/mode on the wheel
→ hover the defender → CUS: Attack again → resolver opens
```

Candidate targets are highlighted while you're choosing. `CUS: Cancel Operation`
clears everything.

Everything reachable by hotkey is also reachable by **right-click → context
menu** on the miniature (CUS Actions, Open Linked Card, Link/Unlink/Re-sync,
Nerve Test, Calibrate Forward Axis), so the mod is fully usable with no key
bindings at all.

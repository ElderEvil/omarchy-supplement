## 2026-01-28

## 2026-01-28 Task: research local Omarchy/Hyprland patterns
- Omarchy uses `bindd = ...` extensively for descriptive keybinds.
- Default Hyprland configs use Linux keycodes for symbols:
  - `code:20` corresponds to `-`
  - `code:21` corresponds to `=`
  - `code:19` corresponds to `0` (seen as workspace 10)
- Omarchy scripts commonly parse focused monitor via:
  - `hyprctl monitors -j | jq -r '.[] | select(.focused == true).name'`
- `notify-send` patterns:
  - Info notifications often just include title text (sometimes icon glyph in title)
  - Errors use `-u critical -t <ms>`
- For scale-aware geometry, Omarchy uses `.width / .scale` and `.height / .scale` with `floor` (see `omarchy-cmd-screenshot`).

## 2026-01-28 Task: implementation workaround
- delegate_task appears broken (JSON Parse error: Unexpected EOF), so implementation is done directly via tooling.

## 2026-01-28 Task: scale behavior
- Hyprland appears to snap/ignore some fractional scales (e.g. attempting to go above 1.67 by +0.1 did not change scale).
- Script implements an "up" fallback to 2.00 if the first attempt results in no change.

## 2026-01-28 Task: final scale list
- Tested Hyprland scale acceptance on 2560x1440@144Hz monitor (DP-4).
- Valid scales for this resolution: 0.80, 1.00, 1.25, 1.33, 1.60, 1.67, 2.00
- Capped max at 2.00 per user request.
- Script now cycles through discrete list instead of +/-0.1 increments.

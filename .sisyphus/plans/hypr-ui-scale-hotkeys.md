# Hyprland: On-the-fly UI scale hotkeys (active monitor)

## TL;DR

Add Hyprland keybinds (Omarchy) to adjust the **focused monitor** scale in **0.1** steps, clamped to **0.8–1.6**, with **reset to the monitor's configured scale**, and a notification showing the new value.

**Deliverables**:
- Update: `/home/elder/.config/hypr/bindings.conf` (3 new `bindd` entries)
- Add: `~/.local/bin/omarchy-monitor-scale` (helper script)
- Session state: store per-monitor default scale under `$XDG_RUNTIME_DIR` (session-only)

**Estimated effort**: Short
**Parallel execution**: NO (single linear change)
**Critical path**: script → bindings → verification

---

## Context

### Original Request
"can we make a keyboard config to change ui scale on flight ... omarchy + hyprland"

### Interview Summary (confirmed)
- Scale method: Hyprland **monitor scale**
- Target: **active/focused monitor only**
- Persistence: **session-only** (no writing `monitors.conf`)
- Hotkeys: **Super+Ctrl** + `=` (increase), `-` (decrease), `0` (reset)
- Step size: **0.1**
- Bounds: **0.8–1.6**
- Fractional scaling: **allowed**
- Reset: return to **current configured scale** (treat the scale at startup/first-use as default)
- Notification: **YES**
- Preference: "as Hyprland way as possible"

### Local Findings (verified)
- Bindings file: `/home/elder/.config/hypr/bindings.conf` (uses `bindd = ...`)
- Monitors config: `/home/elder/.config/hypr/monitors.conf` (configured scale includes `1.67`)
- Tools present: `hyprctl`, `jq`
- Detected monitors: `eDP-2`, `DP-4`

### Metis Review (incorporated)
Key plan guardrails added:
- Use `$XDG_RUNTIME_DIR` for session-only default storage
- Use `awk` (not `bc`) for floating-point arithmetic portability
- Document how we preserve monitor mode while changing scale
- Include automated acceptance criteria (no manual key-press requirements)

---

## Work Objectives

### Core Objective
Enable quick scale adjustments for the focused monitor via Hyprland keybinds, without persisting changes to monitor config.

### Definition of Done
- [x] Running the helper script changes the focused monitor scale as expected (up/down/reset)
- [x] Hyprland bindings are present and visible via `hyprctl binds`
- [x] No modifications to `/home/elder/.config/hypr/monitors.conf`

### Must NOT Have (Guardrails)
- Do **not** modify `monitors.conf` (session-only)
- Do **not** change scaling on non-focused monitors
- Do **not** introduce extra UI (waybar module, GUI picker, presets)

---

## Verification Strategy

No existing unit-test harness applies. Verification will be **agent-executable** via `hyprctl`/`jq` and direct script invocation.

---

## TODOs

> Note: Hyprland key presses are hard to simulate reliably in a plan without a full input injector. We will validate binds exist + validate the behavior by calling the script directly.

- [x] 1) Create helper script: `~/.local/bin/omarchy-monitor-scale`

  **What to do**:
  - Preflight dependencies (no installs unless missing):
    - `command -v hyprctl jq notify-send awk` should all succeed.
  - Create an executable script that accepts one arg: `up | down | reset`.
  - Read focused monitor details using:
    - `hyprctl -j monitors | jq '.[] | select(.focused==true)'`
    - Extract: `name`, `width`, `height`, `refreshRate`, `x`, `y`, `scale`
  - Store default scale per monitor (for reset) under:
    - `$XDG_RUNTIME_DIR/hypr-monitor-scale-defaults/<MONITOR_NAME>`
    - If file missing, write the current runtime scale to it (this is the "configured" baseline for the session).
  - Compute next scale:
    - `up`: `scale + 0.1`
    - `down`: `scale - 0.1`
    - `reset`: value stored in defaults file
    - Clamp to `[0.8, 1.6]`
    - Round to 2 decimals to avoid float precision artifacts
  - Apply new scale using Hyprland keyword monitor.
    - Recommended (keeps mode stable; let Hyprland place):
      - `hyprctl keyword monitor "${name},${width}x${height}@${refreshRounded},auto,${newScale}"`
    - Rationale: avoids position drift/overlaps when effective resolution changes.
  - Notify:
    - Use `notify-send` with monitor name + new scale (e.g. `"DP-4 scale: 1.57"`).
  - Exit non-zero with a helpful notification if no focused monitor can be determined.

  **Recommended Agent Profile**:
  - Category: quick
  - Skills: Omarchy

  **Parallelization**: NO (blocks keybind step)

  **References**:
  - `/home/elder/.config/hypr/monitors.conf` - shows existing configured scale (baseline expectation)
  - `hyprctl -j monitors` - authoritative runtime monitor state and focused monitor detection
  - Hyprland monitors docs: https://wiki.hyprland.org/Configuring/Monitors/

  **Acceptance Criteria (agent-executable)**:
  - [ ] Script exists and is executable:
    - `test -x ~/.local/bin/omarchy-monitor-scale`
  - [ ] Focused monitor scale can be read:
    - `hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale'` returns a number
  - [ ] Running `~/.local/bin/omarchy-monitor-scale up` changes scale by ~0.1 (bounded):
    - Capture before/after with the command above; assert `after >= before` and `after <= 1.6`
  - [ ] Running `... down` changes scale by ~-0.1 (bounded):
    - Assert `after <= before` and `after >= 0.8`
  - [ ] Running `... reset` returns to the stored default:
    - Ensure default file exists at `$XDG_RUNTIME_DIR/hypr-monitor-scale-defaults/<MONITOR_NAME>`
    - After changing scale, `reset` returns scale to file contents (compare numerically)
  - [ ] Notification emitted:
    - `command -v notify-send` succeeds
    - `notify-send "Scale" "<MONITOR>: <SCALE>"` returns exit code 0 (or at least does not error)

- [x] 2) Add Hyprland keybinds in `/home/elder/.config/hypr/bindings.conf`

  **What to do**:
  - Add three `bindd` entries matching the existing style:
    - Super+Ctrl + `equal` → exec `~/.local/bin/omarchy-monitor-scale up`
    - Super+Ctrl + `minus` → exec `~/.local/bin/omarchy-monitor-scale down`
    - Super+Ctrl + `0` → exec `~/.local/bin/omarchy-monitor-scale reset`
  - Before adding, check for conflicting existing binds (same modifiers/key). If present:
    - Add the appropriate `unbind = ...` entries (Omarchy pattern) before your new binds.

  **Recommended Agent Profile**:
  - Category: quick
  - Skills: Omarchy

  **Parallelization**: NO (depends on Task 1)

  **References**:
  - `/home/elder/.config/hypr/bindings.conf` - existing `bindd` style and conventions

  **Acceptance Criteria (agent-executable)**:
  - [ ] File contains new binds (grep):
    - `grep -n "omarchy-monitor-scale" /home/elder/.config/hypr/bindings.conf` shows 3 lines
  - [ ] Hyprland sees the binds:
    - `hyprctl binds | grep -c "omarchy-monitor-scale"` returns `3`

- [x] 3) Verify no persistence + document usage

  **What to do**:
  - Verify `monitors.conf` unchanged (hash before/after).
  - Add a short note (comment) near the binds explaining:
    - what keys do, bounds, and that it’s session-only.
  - Optional: if notification spam is annoying, document how to disable it (toggle variable in script).

  **Recommended Agent Profile**:
  - Category: quick
  - Skills: Omarchy

  **Parallelization**: NO (final)

  **Acceptance Criteria (agent-executable)**:
  - [ ] `md5sum /home/elder/.config/hypr/monitors.conf` unchanged across the run
  - [ ] Default files exist under `$XDG_RUNTIME_DIR/hypr-monitor-scale-defaults/` after first use

---

## Success Criteria

### Commands
```bash
# show focused monitor scale
hyprctl -j monitors | jq '.[] | select(.focused==true) | {name, scale}'

# ensure binds are registered
hyprctl binds | grep 'omarchy-monitor-scale'
```

### Final Checklist
- [x] +/-/reset behavior works via direct script calls
- [x] Binds are present and correctly wired to the script
- [x] No changes written to monitors.conf

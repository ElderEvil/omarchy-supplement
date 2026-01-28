## 2026-01-28

## 2026-01-28 Decision: scale clamp vs reset baseline
- We want "reasonable" clamping but also "reset to current".
- Local configured scale is 1.67, which exceeds a hard max of 1.6.
- Decision: clamp min=0.8, and max = max(2.0, defaultScale) where defaultScale is captured per-monitor on first use for the session.

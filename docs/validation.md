# Initialization validation — 2026-10-27

- Flutter 3.47.7 / Flame 1.38.2 resolved successfully; lockfile committed.
- `flutter analyze`: passes.
- `flutter test`: three gameplay tests pass (side-specific terrace response, summit entry direction, base restart state).
- `flutter build web --release`: passes, including Flutter's Wasm compatibility dry run. This is a JavaScript release build, not a shipped Wasm build.
- `openspec validate --all`: passes, one specification.
- `git diff --check`: passes.
- Local Wrangler preview reports running, route ready and serving at https://www.pincheball.localhost:18443.

Checks were run by the initialization agent and root agent. No production deployment, human playtest, mobile performance measurement, final visual approval or full gameplay-duration validation is claimed. Forge-managed Chromium development browser opened with Galaxy S24 portrait emulation (360×780 CSS pixels, DPR 3). Landing screen rendered and a CDP touch started gameplay; console inspection reported no exceptions. The host has no display, so the development browser is headless and agent-visible only.

Browser smoke-check limitation: gameplay renders and starts, but arrow glyphs show missing-character boxes. Console warnings report unavailable external Google fallback fonts in the project-restricted browser. Bundle required glyphs locally or replace them with drawn icons before visual acceptance.

## Open-mountain proof — 2026-10-28

- `flutter analyze`: passes after model/renderer/asset integration.
- `flutter test`: 18 tests pass across model, persistent scenery and flow/camera behavior. Tests cover cone boundaries independent of screen edges, seed reproducibility, side-group input, swept cave entry and near miss, ejection cooldown, summit settling, base restart, fixed timestep partitions, scenery query seams/identity, cosmetic isolation and biome continuity.
- `flutter build web --release`: passes, including Wasm dry run. The served artifact is the JavaScript release build.
- `openspec validate --all`: passes.
- Generated mountain kit: 1254×1254 PNG, RGBA, alpha range 0–255. Inspected visually and loaded successfully in the browser.
- Forge preview runtime reloaded and Chromium development window refreshed. Portrait landing and gameplay render the new art; CDP tap starts and left/right key events activate branches. Two-axis view displays adjoining routes rather than screen-edge walls.

Limitations: no human playtest or mobile performance benchmark. Branches remain arcade impulse surfaces; organic route validation and robust continuous collisions against all terrain are future work. The compact generated sheet needed custom source rectangles rather than the requested equal cells. External fallback-font warnings from the old browser session were present in retained logs; current control labels use ASCII and drawn directional cues.

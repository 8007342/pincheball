# Pincheball

Use Flutter and Flame. Art direction is pixel illustration with smooth continuous motion. Target portrait mobile proportions; the portrait camera navigates one multi-screen world in both axes; wider screens preserve portrait framing with scenic margins. Screen edges are never collision walls. The mountain is broad at the base and narrows to the summit. Read `openspec/specs/pincheball/spec.md` before changing game behavior; maintain it with agreed changes. Design proposals and research live in `docs/design/`; outstanding work lives in `plan/roadmap.md`.

Preserve the core flow: landing → cinematic intro → single-ball uphill pinball → cinematic outro → persistent animated summit view. The ball abstracts the hiker. Base falls restart the run. No score, lives, checkpoints or multiball. The summit Restart button appears after a delay and reloads the page.

Keep proposed numbers and unimplemented features distinct from measured behavior. Initial terrace impulse surfaces and drawn scenery are placeholders, not finished physics or production artwork. Verify Flutter analysis, relevant tests, web release build and OpenSpec validation when changing their respective areas. Keep Cloudflare production deployment separate from local preview work.

Follow forge-wide process-stop guidance: identify processes with `pgrep`, then kill specific PIDs; never use `pkill -f` or `killall -r`.

Use the forge host facilities for local launches: `publish_local` manages the sibling preview container; `browser_open` with engine `chromium` and `dev: true` provides the development browser. Do not start nested containers. If the host reports DISPLAY_UNAVAILABLE, use a headless development window and explain that it is agent-visible only.

User workflow preference: make frequent commits and pushes on descriptive `work/*` branches. Do not push new work directly to main.

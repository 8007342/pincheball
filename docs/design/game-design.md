# Pincheball — mountain design brief

Status: first design proposal, 2026-10-27. The runnable initializer is a mechanics sketch; the specifications below describe the intended game, not completed features. Numerical targets require playtesting.

## Experience

A single ball climbs a beautiful mountain through an apparently endless natural pinball machine. A run has a finite summit and a target duration of 5–15 minutes. Altitude and discovery replace score combos, multiball and collection tricks. The trailhead overlooks a lake, rivers and broad valley flats. Forest gives way to alpine meadow, exposed granite, clouds and a snowy peak. The final obstacle is a single summit cradle that must receive the ball from above; reaching its altitude alone never wins.

The hiker rests on a rock before play and appears on the summit after completion. The ball is an abstraction of the hiker fighting the terrain. Reaching the base restarts the run; no lives, checkpoints or score. Ordinary falls lose altitude until the base restart region is reached. Provisional implementation choice: reuse the same seed on an automatic base restart, and reset all run state; a page reload may choose a fresh seed.

## Controls and physical space

Left-half touch or Left arrow drives every left flipper in the active simulation region; right-half touch or Right arrow drives every right flipper. Each flipper has a clear side marking and consistent hinge orientation. Both sides can be held simultaneously. Track pointer IDs independently, latch each pointer's side on press, and release on cancel, focus loss, pause or pointer up. Keyboard repeat cannot add impulses. Hold raises a flipper; release returns it. Opening gestures are consumed by the transition, not silently applied to the first shot.

Physics uses one 2D collision plane. 2.5D comes from layered art, depth tint, shadows and terrain relief, rather than changing collision distances with perspective. Ball size and flipper reach stay constant. HUD and touch halves remain aligned with the screen. Portrait mobile proportions are the approved gameplay target. The portrait viewport moves horizontally and vertically over one multi-screen mountain. Screen edges have no colliders. Wider displays add scenic margins around the portrait view without stretching it, revealing extra routes or reducing challenge. Pixel illustration with smooth continuous motion is the approved art direction.

## Generation and boundaries

Use normalized units: W = reference portrait viewport width, H = gameplay viewport height. The current completeness slice is a 1260×2000 mountain (roughly 3 W wide at its base and 2.7 H tall), narrowing to a 170-unit summit ledge. Keep the entire small world loaded. Future scale can use spatial chunks in both x and y; 24–36 altitude bands are a later hypothesis, not the initial implementation. A world key contains seed, generator version and tuning version. Independent random streams control route geometry, cosmetics and wildlife, so adding a bird cannot change a shot.

1. Generate a route graph first: safe ascent spine, optional risk/reward branch and recovery connections.
2. Select compatible authored templates with entrance/exit ports and clearance metadata; perturb within validated ranges.
3. Solve flipper-to-receiver trajectories using the actual physics solver, including contact timing and ball radius. Every spine connection needs a robust timing window, not a single exact trajectory.
4. Place obstacles outside guaranteed recovery channels, then validate downward routes too. Reject traps, infinite passive bounce loops, inaccessible flippers and seam collisions.
5. Dress valid geometry with biome-compatible terrain, grounded plants and wildlife anchors. Keep decoration outside shot visibility masks.
6. Generate two chunks ahead and retain at least two below. Persist logical state for every visited chunk; evicted art can rebuild identically. Retain all necessary downward physics until the ball can no longer enter it this step.

The mountain envelope is broad at the base and narrows uphill, independent of the camera. Its projected cone has solid terrain side ridges with readable silhouettes, a closed trailhead basin, a finite summit cap and no invisible side drains. Outer scenery can extend past these boundaries. No screen wrap. Internal routes wander across the face; visible receiving zones and two-axis camera preview must support lateral transfers. Chunk seams own colliders once, share ports and overlap decoration without gaps. Do not delete a falling ball or create new geometry underneath it.

Candidate density: 2–3 flipper pairs per H, staggered 0.28–0.42 H vertically; 3–5 meaningful deflectors per H; at most one precision optional shot in a view. Funnels should cover about 65–80% of descending entry width, with sloped lips and ball-radius clearance. This is a tuning proposal, not evidence of fun. Alternate 15–25 seconds of demanding ascent with 5–10 seconds of generous recovery geometry; keep inputs useful during the quieter passages. Do not secretly change collision geometry based on player performance.

## Ballistics, camera and reward

Start by testing gravity g = 1.1 H/s² and nominal upward launch speed v = 1.05 H/s. For an unobstructed shot, t_apex = v/g ≈ 0.95 s and rise = v²/(2g) ≈ 0.50 H. These values give room for several receivers in view. At a target rise d, require v² >= 2gd, then solve horizontal displacement and collision timing. Validate these estimates with the discrete solver and actual flipper contacts. A fast-forward spring uses a visible guided route or wider camera preview, not an invisible velocity clamp.

Run physics at a fixed timestep, provisionally 1/120 s, and interpolate rendering. Use swept collision or sufficient continuous collision detection for narrow logs and fast ball travel. Bound catch-up work after stalls; pause rather than simulating a hidden multi-second fall after returning to the tab.

Camera has a calm vertical dead zone: ball near 60–65% screen height while rising, nearer 35–40% while falling, with continuous hysteresis between modes. Preview velocity by about 0.25 s, clamp lookahead, and keep the next meaningful receiver visible. Use critically damped follow, no roll, and a hard safety framing constraint if the ball approaches the edge. Never let decorative smoothing lose the ball. Tune maximum speed from usable screen distance / desired reaction time; a candidate 0.8 H margin and 0.65 s warning gives 1.23 H/s. This is a comfort hypothesis, not a universal human threshold.

Trick shots trade risk for altitude or recovery position: a spring gives a predictable launch; a ski lift offers a short visible ascent and releases into a known receiver; a hollow log redirects along an authored arc with visible entrance/exit. A cave temporarily swallows the ball, then an animal claw chases it out with a forceful impulse and a recapture cooldown. Aim for optional shortcuts saving 1–2 successful transfers, not mandatory precision gates. Misses return to a lower flipper zone when earned by the geometry, and can still lose meaningful altitude. No hidden magnet should fabricate a success.

## Biomes and reactive world

Blend from actual altitude, allowing scenery to reverse naturally during a fall. Keep furthest altitude only for progress records. Candidate biome bands: valley 0–18%, forest 15–48%, meadow 43–68%, cloud granite 63–87%, snow 82–100%. Overlap palettes, species and atmosphere through smootherstep; never replace every layer at a line. Trees thin before snow and water becomes distant tarns before disappearing. Summit geography is authored and cannot be obstructed by procedural dressing.

Depth layers: sky (0.02 camera factor), far valley (0.08), mountain silhouettes (0.18), distant woods (0.40), gameplay (1.0), sparse foreground (1.08). Factors are initial art settings. Fixed rocks do not sway. Leaves pivot from rooted branches; stems bend; clouds drift continuously. Assign per-instance phases rather than synchronizing the whole forest.

Emit spatial impact events with position, strength and source. Nearby tree impacts release a bounded leaf burst and one flock; nearby flipper motion startles only creatures within its radius. Birds use coherent flock paths; rabbits flee to a shelter, then may cautiously reappear; deer observe from protected ground, approach after a quiet interval, and retreat from a nearby impact. State machine: idle → alert → flee → sheltered → curious → idle. Cooldowns and hysteresis prevent every tap restarting the same reaction. Wildlife cannot collide with the ball or occlude a catch. Per-chunk budgets and pooled particles keep detail bounded; offscreen wildlife uses cheap state updates. Snow zones use suitable birds and sparse tracks rather than forest animals everywhere.

## Balance evidence to collect

For each generator version, sample at least 1,000 seeds and validate connectivity, seam clearance, summit uniqueness and bounded memory. Replay timestamped input across render rates. Automated agents can expose unwinnable geometry but cannot prove human enjoyment.

Record active play duration, time between useful flipper contacts, successful ascent per transfer, largest fall, recovery success, failed optional shots and offscreen-ball time. Initial hypotheses: median useful intervention every 0.7–2 s; no unplanned passive wait above 3 s; zero offscreen-ball events; successful ordinary runs 5–15 minutes. Compare density variants on the same seeds with people of mixed skill. Track completion percentage as well as duration so only fast survivors do not bias tuning. Do not force a timer to manufacture the desired run length.

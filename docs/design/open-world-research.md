# Small open mountain: research and completeness slice

Reviewed 2026-10-27. This supersedes the earlier **screen-wide corridor assumption**, not the agreed portrait presentation. The user's mountain is broad at the base and narrows toward one summit. “Open world” here means freely connected lateral and vertical terrain inside that mountain, not an infinite map. These are design proposals and source review; they do not establish human comfort, enjoyable density or procedural solvability.

## Primary sources and what transfers

| Source | Evidence reviewed | Application and limit |
| --- | --- | --- |
| [Itay Keren, Scroll Back, GDC 2015 slides](https://media.gdcvault.com/gdc2015/presentations/Keren_Itay_ScrollBack.pdf), especially slides 19–32, 47, 54 and 95 | Camera windows, smoothing, projected position and world cues are distinct camera techniques. The slides distinguish framing action from unnecessary camera motion. | Follow both x and y; use a small dead zone and bounded velocity lookahead. Cave exits and next receivers can influence framing. The timings and safe rectangle below are our proposals, not Keren's measured thresholds. The PDF is now accessible; the earlier research register's “full session review outstanding” still applies to the video, not these slides. |
| [Flame camera and world](https://docs.flame-engine.org/latest/flame/camera.html) | World and camera are separate; `follow`, `moveTo` and shape-based camera bounds are documented. | Screen edges must not become collision boundaries. Camera clipping/constraints are presentation concerns. The page labels itself older documentation; verify APIs against installed Flame before copying signatures. |
| [Box2D simulation](https://box2d.org/documentation/md_simulation.html) and [collision](https://box2d.org/documentation/md_collision.html) | Fixed steps, continuous collision sweeps/time of impact, high-speed dynamic-body handling and final-transform sensor overlaps are documented. | A cave ejection or flipper shot needs swept contact checks, including trigger entry. Reducing timestep alone is not proof against tunneling. Box2D 3.2 C API details are reference concepts, not claims that our pure-Dart model or Forge2D implements identical behavior. |
| [Dormans, Adventures in Level Design, 2010](https://www.pcgworkshop.com/archive/dormans2010adventures.pdf) | Distinguishes mission structure from geometric space generation. | Establish an ascent/recovery connection graph before dressing it as trees and caves. This is an analogy to pinball: graph connectivity alone cannot prove physically reachable shots. |
| [Togelius and Shaker, The search-based approach](https://www.pcgbook.com/chapter02.pdf) | Content representation and evaluation functions are central to search-based generation. | Keep geometric checks separate from simulation-based reachability and human review. We do not need evolutionary generation for this slice; deterministic templates plus rejection tests are enough. |

## Proposed first world

Use approximately **1260 × 2000 world units**, with a **420 × 740 portrait view**. This gives about three views across the broad base and fewer than three views uphill. A short completion is acceptable. Keep the whole model loaded for this small map; streaming is unnecessary until scale justifies it.

Represent the mountain envelope as `left(y)` and `right(y)`, broad at the base and smoothly narrowing toward a small summit landing region. A finite cap avoids a zero-width apex that cannot contain the ball. The cone sides are terrain ridges with visible contact geometry. They are independent of the camera. Spawn randomly within a bounded band around base center, with a clear launch and first recovery region. Use a replayable seed and keep decoration randomness independent of collision randomness.

Scatter left/right flipper branches among trees across the available cross-section, rather than placing every pair against screen edges. Include at least one genuine lateral transfer beyond the starting view, alternate ascent connections and lower recovery connections. Natural materials should explain function: trunks/rocks deflect, branches act as flippers, water can guide or throw the ball, and a cave briefly captures then ejects it with a claw reaching out. These meanings should remain readable before full artwork exists.

Cave lifecycle proposal: entry → short held anticipation → visible claw/ejection → cooldown. One logical ball exists throughout. Disable ordinary collisions while held; position the ball just beyond the exit geometry before launch; suppress recapture until it has cleared the cave. Show the exit direction before force is applied. Camera cueing can reveal the receiving area during anticipation, but must never cut away from the returning ball. Durations and impulse strength remain tunable.

## Camera proposal

Use a portrait camera with continuous x/y follow. A center window around 30–70% of width and 30–65% of height can absorb small bounces; move smoothly when the ball crosses it. Add roughly 0.15–0.25 s of projected motion, clamped so a sudden bounce cannot swing the view across the mountain. Bias upward during ascent and show recovery terrain during a fall. Keep the ball inside an outer safety rectangle even when normal damping would lag behind. Camera safety corrections must move the view, not add a physical wall or silently alter ball velocity.

Do not zoom the entire mountain into one portrait screen during play. A subtle overview during the intro can teach the cone silhouette and starting position. At the ending, pull back into the grand view and echo the lake, waterfall and forest that were actually present in the run. Wider monitors can frame the same portrait gameplay view with scenery; this does not restrict the world's width.

## Completeness proof before expanding

1. **World versus viewport:** move the ball laterally across multiple view widths. It must cross prior screen edges uninterrupted; only the true cone side changes its motion.
2. **Geometry and seeds:** test bounds at every altitude, radius clearance, spawn validity, non-overlapping receivers and a unique summit. Repeat representative seeds. A visual map overlay is useful during development but need not enter the product UI.
3. **Actual dynamics:** sweep launch position/timing through flippers and optional routes, using the same fixed-step solver as gameplay. Test fast branches, rocks, cave entry and ejection against tunneling and immediate recapture. Successful graph traversal is insufficient.
4. **Flow:** landing → intro → free climb → summit entry from above → outro → persistent view → delayed page-reload Restart. Falling to base resets run state, cave timers and inputs; there are no lives, checkpoints or score.
5. **Presentation:** inspect motion in portrait at a small phone size. Confirm x/y camera reversal, falls, cave release, pause/resume and resize. Keep nearby nature responsive with a few bounded animations. These checks require moving browser review; unit tests do not certify atmosphere.

For now, accept a coherent brief climb with these systems working together. Defer larger maps, sophisticated terrain streaming, many animal species and broad asset production. Increase scale only after testing demonstrates usable shot connections, readable camera motion and complete end-to-end flow.

# Storyboard and visual direction

Status: textual production storyboard and character specification. Production illustrations, sprite sheets and visual approval are future work; the initializer uses drawn placeholders.

## Approved direction and evaluated alternatives

| Direction | Strength | Cost / concern |
| --- | --- | --- |
| Deliberate pixel clusters + continuously moving layers | Cartoon expressions, readable silhouettes, fits the user's preference | Tiny texture can shimmer; source art and camera sampling need separate control |
| Painted cut-paper diorama | Rich terrain and clear 2.5D depth; easy modular foliage | Layer edges and joints can look mechanical; larger texture budget |
| Clean illustrated vector | Scalable, inexpensive recolors, precise silhouettes | Can feel sterile; detailed nature needs deliberate shape variety |

Approved direction: pixel illustration with broad color masses and restrained texture, continuous transforms for smooth scenery motion, and crisp ball/flipper silhouettes. Avoid blanket blur and camera snapping. The alternatives above record the evaluation; a three-style comparison is no longer required. Individual character designs and production assets still need visual review.

Compose gameplay for portrait mobile proportions. Keep the playable corridor centered on wider displays, using scenic margins without stretching the world or revealing extra routes. Design both cinematic handoffs and the summit panorama around the same portrait composition.

## Character guide

Hiker: compact adult silhouette, approximately 3 heads tall, oversized boots, soft backpack and broad hat; warm coral jacket (#D97054), ochre pack (#C9A85D), indigo trousers (#34485F), cream highlights (#F4E6C8). Skin tone, gender presentation and final identity are open. Use 48×64 source-pixel cells as an initial test, consistent seated hip/standing foot pivots, padded atlas cells and a contact shadow. Hiker and ball must remain distinct against pale snow and dark forest.

Poses: seated idle, blink, feet forward/back, glance to summit, stand, adjust pack, first step, walk, summit arrival, relieved exhale and seated summit rest. Build a 1.6–2.4 s feet-swing cycle with offset knees/boots, a tiny 3–5 s breathing cycle and irregular blinks. Rock stays still; feet swing from knees, not by rotating the entire character. Test continuous leg articulation against 6–8 authored frames. Avoid double-outline crossfades between incompatible poses.

Ball: small warm ivory sphere with dark blue edge and a restrained golden trail. A contact shadow communicates grounding; a short impact deformation is visual only. Its collision radius never changes. Flippers: carved wood at lower elevations, weathered trail hardware and frost at higher ones, preserving identical shape, side markings and contact readability. Do not rely on red/green alone to identify sides.

Animals: birds have 3–5 coherent wing poses and an alert perch; rabbits use ears-first alert, crouch, flee and cautious peek; deer use head turn, ear flick, walk and retreat. Express curiosity through pauses and head orientation, not constant bouncing.

## Shot-by-shot flow

| Shot | Composition and action | Timing proposal / exit |
| --- | --- | --- |
| 01 — Rest at the trailhead | Hiker sits on rock, boots swing over valley lake. Peak sits high in the background. Slow ripples, rooted foliage, one distant flock. Small “Tap anywhere to climb” cue. | Idle indefinitely; tap or Enter starts once |
| 02 — Decision | Hiker looks toward peak, stops feet naturally, leans forward and stands; hand adjusts pack. Start cue fades. Audio unlocks from the gesture. | 0–0.65 s after start |
| 03 — First steps | Follow a short trail movement; near foliage opens the frame while valley remains spatially anchored. Reveal first flipper basin by continuous camera translation. | 0.65–1.65 s |
| 04 — Handoff | The hike hands off symbolically to the abstract ball, first receiver and both control hints visible; camera settles before release. | 1.65–2.25 s; gameplay starts only when ready |
| 05 — Living ascent | Follow ball with stable dead zone. Alternating route compression and open meadow gives visual breathing room. Biomes overlap, with no chapter cuts or frozen gameplay. | Continuous ascent and regression |
| 06 — Above the cloud | Wisps thin across the margins, near terrain remains clear. Summit cradle gets a distinct silhouette and an approach/recovery pair below. | Last two chunks; no cinematic interruption |
| 07 — Summit catch | Top-entry sensor plus low settled speed captures ball exactly once. Contact sound/brief gleam acknowledges success immediately. | Settle about 0.3 s, then stop gameplay input |
| 08 — Arrival and rest | Camera pulls back gently to show snowy peak piercing clouds. Hiker arrives along the final ledge, rests, exhales; reveal valley far below. | About 3–5 s, then indefinite living tableau; delayed small corner Restart button reloads the page |

All transition channels use one normalized timeline and defined state ownership. Palette, camera, character and audio can overlap; physics is inactive before the first release and after the settled summit capture. Skip resolves directly to a safe gameplay starting state or completed summit tableau. Pause freezes the timeline; resize recomputes framing without restarting it. Repeated taps never create duplicate balls or timelines. Reduced motion replaces the travel pan/pullback with a short dissolve and stable composition while retaining immediate input feedback.

The summit is a reward for arriving, not a second challenge after the ball is captured. Keep replay optional and retain ambient movement after the ending. The ball is the hiker’s abstract struggle, not a magical companion or literal transformation. Audio, storyboard images and final timing need user review. The ending remains loaded; after a few seconds a small corner Restart button reloads the page. Background taps do not replay. The majestic layered view recalls the valley water, forests and route landmarks seen during ascent.

# Small open-mountain proof

The prototype now uses a seeded 1260×2000 world: roughly three portrait view widths across its base and a few screens uphill. The cone narrows to a summit ledge. The camera follows both x and y; screen edges never participate in collisions. Spawn varies near the base center. The whole small model stays loaded.

World composition is persistent and independent of the camera: indexed scenery patches, separate cosmetic randomness, altitude biome weights, grounded vegetation and actual cave/waterfall landmark positions. This applies Ranitas's layer ownership, stable anchors and independent motion principles to one navigable world instead of separate pond compositions.

Branches act as grouped flippers, trees and rocks deflect, waterfalls launch, and caves capture then eject the ball with a claw cue. Cave entry uses swept segment-circle detection and an ejection cooldown. The summit requires entry from above and a short settle before the persistent outro. Base falls reset the run. No score, lives or checkpoints.

Remaining simplifications: branches use arcade impulses rather than rigid-body hinges; route generation still uses provisional rows across the cone rather than validated organic templates. Small-seed automated successes are not proof that every seed is enjoyable or completable. The scenery is a compact proof kit with procedural animation, not the final production mountain. Camera transitions, fauna reactions, optional transports and 5–15 minute tuning remain future work.

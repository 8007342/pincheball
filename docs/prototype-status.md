# Initial prototype status

The initial Flutter/Flame web scaffold is a foundation for design review.

Implemented: seated swinging hiker illustration, start input, timed introduction state, one ball under fixed-step gravity, deterministic repeated terraces with seeded obstacle offsets, side-group controls, basic scrolling/parallax and altitude palette changes, base restart, top-entry summit detection, persistent summit scene and a Restart button after three seconds that reloads the web page. Pointer cancellation, focus loss and app lifecycle release inputs.

Simplifications: flippers are terrace collision surfaces with active/passive impulses, not pivoting rigid bodies. The course is a narrow repeated corridor, not the proposed open route graph. Intro and outro are state/timer placeholders with scene swaps, not finished cinematics. Summit detection checks entry, not settled reception. Drawn scenery is illustrative, not approved pixel artwork. No wildlife, trick-shot transport, authored summit panorama, real seed variety or validated 5–15 minute balance is present yet. Camera framing and speed limits require moving review.

The design and OpenSpec describe the intended destination. Automated checks establish basic scaffold behavior only; they do not establish playability, visual quality or comfort on phones. Production Cloudflare deployment has not been performed.

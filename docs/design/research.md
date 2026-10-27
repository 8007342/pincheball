# Research register and application

Reviewed 2026-10-27. This is source review and design inference, not a human study. No source below establishes ideal flipper density, comfortable ball speed or a guaranteed 5–15 minute completion time for Pincheball.

## Sibling evidence

Repositories were absent from the workspace and unavailable through this project's git mirror. GitHub repository discovery located them; shallow read-only clones supplied the full documents. No sibling files or assets were copied into this project.

| Inspected snapshot | Documents | Application and limits |
| --- | --- | --- |
| [Ranitas at 03f3901](https://github.com/8007342/ranitas/tree/03f3901ba0022746ea1920564bd2df3b90d7e98f) | [research](https://github.com/8007342/ranitas/blob/03f3901ba0022746ea1920564bd2df3b90d7e98f/docs/research.md), [quiet awakening](https://github.com/8007342/ranitas/blob/03f3901ba0022746ea1920564bd2df3b90d7e98f/docs/quiet-awakening.md), art/STYLEGUIDE.md, art/ANIMATION_STYLEGUIDE.md | Follow the newer quiet-awakening corrections over older rotation snapping: anchored minerals, continuous foliage transforms, independently phased creatures, gradual palette/detail emergence. Impact events can drive spatial startle responses. Its tranquil pond timing does not prescribe pinball pacing; avoid importing the three-minute awakening schedule literally. |
| [Cannonball at 238d7de](https://github.com/8007342/cannonball/tree/238d7de3049009c605d8562869cc9cda3d5a1fff) | [motion art](https://github.com/8007342/cannonball/blob/238d7de3049009c605d8562869cc9cda3d5a1fff/docs/research/motion-art.md), docs/research/camera-flow-next.md, docs/research/level-lighting-scenery.md | Separate source pixel style from temporal smoothness; interpolate motion, preserve proportions across aspect ratios, fade distant scenery before it reaches collision relevance. Maintain material/emissive layer ownership and bounded caches. Its racing projection, lower horizon and camera lean are not appropriate pinball defaults. Repository spelling is cannonball. |
| [Demon Attack at 7ef1b57](https://github.com/8007342/demon_attack/tree/7ef1b57337e38b1a487fd755943f1bbdc9ced52d) | [transition research](https://github.com/8007342/demon_attack/blob/7ef1b57337e38b1a487fd755943f1bbdc9ced52d/plan/transition-research.md) | Separate immediate accomplishment response from travel and arrival; coordinate multiple channels with one cutscene clock. Gameplay state stays authoritative, music follows. Its four-second tally/eight-second music loop are authored for that game and should not be pasted into an opening mountain hike. |

## Additional primary technical sources

- [Flame camera and world](https://docs.flame-engine.org/latest/flame/camera.html) documents separation of world, viewfinder, viewport and backdrop. Apply this separation to stable physics and layered scenery. The inspected page labels itself an older documentation version; verify API details against the installed Flame version before implementation.
- [Flame parallax component](https://docs.flame-engine.org/latest/flame/components/parallax_component.html) explains layers with different velocities and animated renderers. Apply depth-dependent camera motion; our layer factors are artistic proposals, not engine recommendations.
- [Glenn Fiedler, Fix Your Timestep](https://github.com/mas-bandwidth/gafferongames/blob/main/content/post/fix_your_timestep.md) motivates bounded/fixed integration steps and render interpolation. Apply to reproducible ball contact and consistent flipper behavior; a fixed step alone does not prevent tunneling or establish cross-platform bitwise determinism.
- [Itay Keren, Scroll Back presentation](https://media.gdcvault.com/gdc2015/presentations/Keren_Itay_ScrollBack.pdf) is the primary follow-up reference for framing important gameplay elements. Search located the presentation; the GDC session page redirected to maintenance, so a full session review is still outstanding. Dead zones and lookahead here remain design proposals rather than claimed quotations from the talk.
- [Cloudflare static assets](https://developers.cloudflare.com/workers/static-assets/) supports serving the built web bundle through Workers. Deployment instructions also describe Pages as an alternative. Account/domain binding and actual public verification remain separate from configuring the repository.

## Evaluation plan

Compare short recorded runs on identical seeds before approving visual style. Ask whether the next receiver is recognizable, whether a fall feels earned, whether incidental wildlife distracts, and whether scenery feels rich without masking shots. Test gentle ascent, fast spring travel and long regression. Review small phones and landscape separately. Automated physics tests cannot establish camera comfort or beauty.

Production implementation needs a generator seed suite, flipper contact timing sweeps, run-duration distribution including failures, sustained memory/render profiling and real touch/browser tests. Document negative results as well as successful demonstrations.

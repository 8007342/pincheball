# Local image-generation probe

Checked 2026-10-27. The user requested a small test of the forge's experimental local image tools, with priority on world-model work over asset production.

## Result

No local image-generation capability is exposed in this running forge. The local probe produced no bitmap. After the user subsequently requested a self-contained asset set for the proof, the standard built-in image generation tool produced a compact project kit; see assets/images/PROVENANCE.md. That success does not validate the missing local backend.

Evidence:

- Tool discovery exposed the normal built-in `image_gen` tool, but no local image-generation MCP method.
- The forge host lane's own `tools/list` returned 31 methods; none generates images. `toolchain_prepare` supports only `flutter`.
- Installed forge CLI wrappers and mounted documentation contained no ComfyUI, Flux, Stable Diffusion, or image-generation entry point.
- The declared local inference service at `inference:11434` responds to Ollama model discovery. Its installed models were `nomic-embed-text:latest` and `qwen2.5:0.5b`, neither an image generator.
- One bounded local POST to `/v1/images/generations` returned HTTP 404 (`404 page not found`). The request used a small 256×256 proof and an eight-second timeout. No work was queued.

This establishes that the current lane cannot access such a tool through the discovered interfaces. It does not establish that experimental image support is absent from other forge versions or the host's development branch. To test that implementation, this lane needs its tool registration/CLI or documented local endpoint.

## Proof prompt retained for a future local attempt

“Pixel illustration of a mossy alpine cave mouth, no text, small game concept.”

Intended use: one atmospheric cave reference, not a final sprite atlas. Final production output should separate the dark mouth, foreground rock lip and animal-claw accent so gameplay capture/ejection can animate independently. Preserve clear silhouette and ball visibility. Do not bake a complete pinball board into a background image.

## Art integration contract

Keep world geometry and collision metadata independent of decorative art. A cave interaction owns its mouth position, radius, capture state, ejection time and velocity; assets supply visual skins. The open mountain can therefore be verified before asset generation works. Once local tools are available, generate one cave or tree first, inspect it, save the image plus exact prompt/tool/model provenance under `assets/images/`, and only then expand the asset set.

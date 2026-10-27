# Pincheball

A Flutter + Flame mountain pinball game: one ball, many flippers, and a living world to climb from a lakeside valley to a snowy summit.

The initial prototype explores grouped left/right controls, procedural terraces, scrolling mountain scenery and a summit target. It is a foundation; organic generation, production art, wildlife, complete cinematic flow and the 5–15 minute balance target remain planned.

## Run

```sh
flutter pub get
flutter run -d chrome
```

Tap to begin. Touch the left/right half or use the left/right arrow keys to drive that side's flippers. Both sides can be active together.

```sh
flutter analyze
flutter test
flutter build web --release
```

See [prototype status](docs/prototype-status.md) for implemented behavior and limitations.

## Design and delivery

- [Agreed experience specification](openspec/specs/pincheball/spec.md)
- [Game design, boundaries, generation and balance](docs/design/game-design.md)
- [Storyboard, character guide and art alternatives](docs/design/storyboard-and-art.md)
- [Sibling research and sources](docs/design/research.md)
- [Remaining work](plan/roadmap.md)
- [Cloudflare deployment](docs/deployment.md)

Production destination: `pincheball.tlatoani.net`. Repository setup does not itself publish the site or configure the Cloudflare account.

# Pincheball

A Flutter + Flame mountain pinball game: one ball, many flippers, and a living world to climb from a lakeside valley to a snowy summit.

The small open-world proof spans several portrait screens horizontally and vertically. A two-axis camera traverses a seeded cone mountain with branch flippers, deflecting trees, waterfalls and animal caves that eject the ball. Persistent composable scenery follows Ranitas’s world-layer principles. Organic route validation, full wildlife, polished cinematics and the later 5–15 minute target remain planned.

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

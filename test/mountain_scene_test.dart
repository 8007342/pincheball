import 'package:flutter_test/flutter_test.dart';
import 'package:pincheball/game/mountain_model.dart';
import 'package:pincheball/game/mountain_scene.dart';

void main() {
  test(
    'world scene is seeded, bounded by mountain, and spans many screens',
    () {
      final model = MountainModel(seed: 21);
      final a = MountainScene(model);
      final b = MountainScene(MountainModel(seed: 21));
      expect(a.decorations.length, greaterThan(50));
      expect(a.decorations.length, lessThan(9 * 6 * 9));
      expect(
        a.decorations.map((d) => [d.id, d.x, d.y, d.kind, d.phase]).toList(),
        b.decorations.map((d) => [d.id, d.x, d.y, d.kind, d.phase]).toList(),
      );
      expect(a.decorations.any((d) => d.x < 420), isTrue);
      expect(a.decorations.any((d) => d.x > 840), isTrue);
      expect(a.decorations.any((d) => d.y > 1480), isTrue);
      for (final d in a.decorations) {
        final bounds = model.boundsAt(d.y);
        expect(d.x, inInclusiveRange(bounds.left, bounds.right));
      }
    },
  );

  test('camera traversal and return preserve identities at patch seams', () {
    final scene = MountainScene(MountainModel());
    final first = scene.visible(left: 200, right: 620, bottom: 200, top: 940);
    scene.visible(left: 600, right: 1020, bottom: 900, top: 1640);
    final returned = scene.visible(
      left: 200,
      right: 620,
      bottom: 200,
      top: 940,
    );
    expect(returned.length, first.length);
    for (var i = 0; i < first.length; i++) {
      expect(identical(first[i], returned[i]), isTrue);
    }
    final moved = scene.visible(left: 201, right: 621, bottom: 201, top: 941);
    final shared = moved.where((d) => first.contains(d));
    expect(shared.length, greaterThan(first.length * .9));
  });

  test(
    'visibility includes canopy extents and matches complete world query',
    () {
      final scene = MountainScene(MountainModel());
      const left = 480.0, right = 900.0, bottom = 480.0, top = 1220.0;
      final queried = scene.visible(
        left: left,
        right: right,
        bottom: bottom,
        top: top,
        padding: 0,
      );
      final expected = scene.decorations.where(
        (d) =>
            d.x + d.extent >= left &&
            d.x - d.extent <= right &&
            d.y + d.extent >= bottom &&
            d.y - d.extent <= top,
      );
      expect(queried.toSet(), expected.toSet());
      expect(
        scene.visible(left: -1000, right: -900, bottom: 0, top: 740),
        isEmpty,
      );
    },
  );

  test('cosmetic seed cannot change collision model or landmarks', () {
    final model = MountainModel(seed: 83);
    final ballX = model.ball.x;
    final branches = model.flippers.map((b) => [b.x, b.y]).toList();
    final a = MountainScene(model, cosmeticSeed: 1);
    final b = MountainScene(model, cosmeticSeed: 2);
    expect(a.decorations.first.x, isNot(b.decorations.first.x));
    expect(model.ball.x, ballX);
    expect(model.flippers.map((b) => [b.x, b.y]).toList(), branches);
    expect(
      a.landmarks.map((l) => [l.id, l.x, l.y]).toList(),
      b.landmarks.map((l) => [l.id, l.x, l.y]).toList(),
    );
    for (final cave in model.caves) {
      expect(
        a.landmarks.any(
          (l) =>
              l.kind == MountainLandmarkKind.cave &&
              l.x == cave.x &&
              l.y == cave.y &&
              l.radius == cave.radius,
        ),
        isTrue,
      );
    }
  });

  test('biome weights stay continuous and normalized across entire ascent', () {
    var previous = MountainScene.biomeAt(-1);
    for (var y = 0.0; y <= MountainModel.height + 1; y++) {
      final b = MountainScene.biomeAt(y);
      final weights = [b.valley, b.forest, b.alpine, b.snow];
      expect(weights.reduce((a, b) => a + b), closeTo(1, 1e-12));
      for (final w in weights) {
        expect(w, inInclusiveRange(0, 1));
      }
      expect((b.forest - previous.forest).abs(), lessThan(.01));
      expect((b.alpine - previous.alpine).abs(), lessThan(.01));
      expect((b.snow - previous.snow).abs(), lessThan(.01));
      previous = b;
    }
    expect(MountainScene.biomeAt(0).valley, 1);
    expect(MountainScene.biomeAt(MountainModel.height).snow, 1);
  });
}

import 'dart:math' as math;

import 'mountain_model.dart';

enum MountainDecorationKind { tree, shrub, grass, flowers, stone, snowPatch }

enum MountainSceneSlot { ground, foliage }

enum MountainLandmarkKind { cave, waterfall }

/// Continuous altitude weights; all four always sum to one.
class MountainBiomeMix {
  const MountainBiomeMix(this.valley, this.forest, this.alpine, this.snow);
  final double valley, forest, alpine, snow;
}

/// A persistent world anchor. Animation offsets belong to the renderer, not x/y.
class MountainDecoration {
  const MountainDecoration({
    required this.id,
    required this.x,
    required this.y,
    required this.kind,
    required this.slot,
    required this.scale,
    required this.phase,
    required this.biome,
  });
  final String id;
  final double x, y, scale, phase;
  final MountainDecorationKind kind;
  final MountainSceneSlot slot;
  final MountainBiomeMix biome;

  /// Conservative culling radius, including gentle sway and the canopy.
  double get extent => (kind == MountainDecorationKind.tree ? 65 : 27) * scale;
}

/// Locations come from the collision model, rather than a second scenic RNG.
class MountainLandmark {
  const MountainLandmark(this.id, this.x, this.y, this.radius, this.kind);
  final String id;
  final double x, y, radius;
  final MountainLandmarkKind kind;
}

/// Composes the entire small mountain once. Camera queries never generate art.
///
/// Ranitas-inspired principles: stable anchors and tier ownership, separate
/// cosmetic randomness, independent motion phases and rooted foliage. Unlike a
/// menu's corner layers, these patches belong to one traversable world.
class MountainScene {
  MountainScene(MountainModel model, {int? cosmeticSeed})
    : cosmeticSeed = cosmeticSeed ?? (model.seed ^ 0x45d9f3b) {
    final placed = <MountainDecoration>[];
    for (var py = 0; py * patchSize < MountainModel.height; py++) {
      for (var px = 0; px * patchSize < MountainModel.width; px++) {
        // Per-patch streams keep existing patches stable if the map expands.
        final random = math.Random(
          this.cosmeticSeed ^ (px * 73856093) ^ (py * 19349663),
        );
        final patch = <MountainDecoration>[];
        for (var index = 0; index < 9; index++) {
          final x = (px + random.nextDouble()) * patchSize;
          final y = (py + random.nextDouble()) * patchSize;
          final scale = .65 + random.nextDouble() * .7;
          final phase = random.nextDouble() * math.pi * 2;
          if (y > MountainModel.height - 85) continue;
          final bounds = model.boundsAt(y);
          if (x < bounds.left + 22 || x > bounds.right - 22) continue;
          final biome = biomeAt(y);
          final roll = random.nextDouble();
          final kind = y > MountainModel.height * .78
              ? (roll < .65
                    ? MountainDecorationKind.snowPatch
                    : MountainDecorationKind.stone)
              : y > MountainModel.height * .56
              ? (roll < .3
                    ? MountainDecorationKind.flowers
                    : roll < .65
                    ? MountainDecorationKind.grass
                    : MountainDecorationKind.stone)
              : (roll < .3
                    ? MountainDecorationKind.tree
                    : roll < .55
                    ? MountainDecorationKind.shrub
                    : roll < .8
                    ? MountainDecorationKind.grass
                    : MountainDecorationKind.flowers);
          // Tall decoration avoids the immediate branch and landmark contact
          // regions. Ground cover can remain underneath the gameplay layer.
          if ((kind == MountainDecorationKind.tree ||
                  kind == MountainDecorationKind.shrub) &&
              _blocksContact(model, x, y)) {
            continue;
          }
          final decoration = MountainDecoration(
            id: 'patch:$px:$py:$index',
            x: x,
            y: y,
            kind: kind,
            slot:
                kind == MountainDecorationKind.tree ||
                    kind == MountainDecorationKind.shrub
                ? MountainSceneSlot.foliage
                : MountainSceneSlot.ground,
            scale: scale,
            phase: phase,
            biome: biome,
          );
          placed.add(decoration);
          patch.add(decoration);
        }
        _patches[_key(px, py)] = List.unmodifiable(patch);
      }
    }
    decorations = List.unmodifiable(placed);
    landmarks = List.unmodifiable([
      for (var i = 0; i < model.caves.length; i++)
        MountainLandmark(
          'cave:$i',
          model.caves[i].x,
          model.caves[i].y,
          model.caves[i].radius,
          MountainLandmarkKind.cave,
        ),
      for (var i = 0; i < model.obstacles.length; i++)
        if (model.obstacles[i].kind == MountainObstacleKind.waterfall)
          MountainLandmark(
            'waterfall:$i',
            model.obstacles[i].x,
            model.obstacles[i].y,
            model.obstacles[i].radius,
            MountainLandmarkKind.waterfall,
          ),
    ]);
  }

  static const patchSize = 240.0;
  static const _maximumExtent = 90.0;
  final int cosmeticSeed;
  late final List<MountainDecoration> decorations;
  late final List<MountainLandmark> landmarks;
  final Map<int, List<MountainDecoration>> _patches = {};

  static int _key(int x, int y) => y * 10000 + x;

  /// Smooth weights are evaluated in world altitude, never screen position.
  static MountainBiomeMix biomeAt(double y) {
    final altitude = (y / MountainModel.height).clamp(0.0, 1.0);
    final forest = _smooth(.10, .30, altitude);
    final alpine = _smooth(.43, .68, altitude);
    final snow = _smooth(.73, .94, altitude);
    return MountainBiomeMix(1 - forest, forest - alpine, alpine - snow, snow);
  }

  static double _smooth(double low, double high, double value) {
    final t = ((value - low) / (high - low)).clamp(0.0, 1.0);
    return t * t * t * (t * (t * 6 - 15) + 10);
  }

  static bool _blocksContact(MountainModel model, double x, double y) {
    for (final branch in model.flippers) {
      if (x >= branch.minX - 35 &&
          x <= branch.maxX + 35 &&
          (y - branch.y).abs() < 55) {
        return true;
      }
    }
    for (final cave in model.caves) {
      if ((x - cave.x).abs() < cave.radius + 45 &&
          (y - cave.y).abs() < cave.radius + 55) {
        return true;
      }
    }
    for (final obstacle in model.obstacles) {
      if ((x - obstacle.x).abs() < obstacle.radius + 40 &&
          (y - obstacle.y).abs() < obstacle.radius + 55) {
        return true;
      }
    }
    return false;
  }

  /// Returns existing anchors in stable painter order. Padding preloads nearby
  /// patches; extents prevent a tree disappearing while its crown is visible.
  List<MountainDecoration> visible({
    required double left,
    required double right,
    required double bottom,
    required double top,
    double padding = 80,
  }) {
    if (![left, right, bottom, top, padding].every((v) => v.isFinite) ||
        right < left ||
        top < bottom ||
        padding < 0) {
      throw ArgumentError('Expected finite ordered bounds and padding >= 0');
    }
    final result = <MountainDecoration>[];
    final margin = padding + _maximumExtent;
    final minX = math.max(0, ((left - margin) / patchSize).floor());
    final maxX = math.min(
      (MountainModel.width / patchSize).ceil() - 1,
      ((right + margin) / patchSize).floor(),
    );
    final minY = math.max(0, ((bottom - margin) / patchSize).floor());
    final maxY = math.min(
      (MountainModel.height / patchSize).ceil() - 1,
      ((top + margin) / patchSize).floor(),
    );
    for (var py = minY; py <= maxY; py++) {
      for (var px = minX; px <= maxX; px++) {
        for (final decoration in _patches[_key(px, py)] ?? const []) {
          final e = decoration.extent + padding;
          if (decoration.x + e >= left &&
              decoration.x - e <= right &&
              decoration.y + e >= bottom &&
              decoration.y - e <= top) {
            result.add(decoration);
          }
        }
      }
    }
    result.sort((a, b) {
      final slot = a.slot.index.compareTo(b.slot.index);
      if (slot != 0) return slot;
      final altitude = b.y.compareTo(a.y);
      return altitude != 0 ? altitude : a.id.compareTo(b.id);
    });
    return List.unmodifiable(result);
  }
}

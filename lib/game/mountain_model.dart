import 'dart:math' as math;

/// Coordinates are world units, with positive Y pointing uphill.
class MountainPoint {
  MountainPoint(this.x, this.y);
  double x;
  double y;
  void setValues(double nextX, double nextY) {
    x = nextX;
    y = nextY;
  }
}

class MountainBounds {
  const MountainBounds(this.left, this.right);
  final double left;
  final double right;
}

enum MountainObstacleKind { tree, rock, waterfall }

class MountainObstacle {
  const MountainObstacle(this.x, this.y, this.radius, this.kind);
  final double x;
  final double y;
  final double radius;
  final MountainObstacleKind kind;
}

class MountainFlipper {
  const MountainFlipper(this.x, this.y, this.leftSide, {this.length = 100});

  /// The branch hinge; the free tip points toward the opposite side.
  final double x;
  final double y;
  final bool leftSide;
  final double length;
  double get angle => leftSide ? .12 : math.pi - .12;
  double get minX => leftSide ? x : x - length;
  double get maxX => leftSide ? x + length : x;
}

class MountainCave {
  const MountainCave(this.x, this.y, this.radius, this.ejectX);
  final double x;
  final double y;
  final double radius;
  final double ejectX;
}

/// Small open-world proof. Geometry belongs to the mountain, never a viewport.
/// This intentionally uses arcade branch contacts, not rigid-body hinge physics.
class MountainModel {
  MountainModel({this.seed = 711}) {
    _generate();
    reset();
  }

  static const width = 1260.0;
  static const height = 2000.0;
  static const ballRadius = 9.0;
  static const gravity = 245.0;
  static const fixedStep = 1 / 120;
  final int seed;
  final ball = MountainPoint(width / 2, 75);
  final velocity = MountainPoint(0, 0);
  final List<MountainFlipper> flippers = [];
  final List<MountainObstacle> obstacles = [];
  final List<MountainCave> caves = [];
  bool left = false;
  bool right = false;
  bool won = false;
  int resetSerial = 0;
  double time = 0;
  double caveTimer = 0;
  double caveCooldown = 0;
  double clawTime = 0;
  MountainCave? activeCave;
  double _accumulator = 0;
  bool _summitSettling = false;
  double _settleTime = 0;

  /// Broad foothills converge to a 170-unit summit ledge.
  MountainBounds boundsAt(double y) {
    final t = (y / height).clamp(0.0, 1.0);
    final half = 630 - 545 * t;
    return MountainBounds(width / 2 - half, width / 2 + half);
  }

  void _generate() {
    final rng = math.Random(seed);
    // Overlapping recovery branches span the face, with real gaps between lanes.
    // The apex receives a hand-authored approach rather than random obstruction.
    for (var row = 0; row < 10; row++) {
      final y = 55.0 + row * 195;
      final bounds = boundsAt(y);
      final available = bounds.right - bounds.left;
      final count = math.max(1, (available / 280).floor());
      for (var lane = 0; lane < count; lane++) {
        final center = bounds.left + available * (lane + .5) / count;
        final jitter = row == 0 ? 0.0 : (rng.nextDouble() - .5) * 36;
        final branchY = y + (lane.isEven ? 0 : 25);
        flippers.add(MountainFlipper(center - 111 + jitter, branchY, true));
        flippers.add(MountainFlipper(center + 111 + jitter, branchY, false));
        // Deflectors sit between rows, away from the central successful arc.
        if (row > 0 && row < 8) {
          final sign = lane.isEven ? -1 : 1;
          obstacles.add(
            MountainObstacle(
              center + sign * 88,
              branchY + 100,
              22,
              row % 3 == 0
                  ? MountainObstacleKind.waterfall
                  : MountainObstacleKind.tree,
            ),
          );
        }
      }
    }
    caves.add(const MountainCave(380, 495, 29, 180));
    caves.add(const MountainCave(775, 1080, 27, -140));
    obstacles.add(
      const MountainObstacle(855, 380, 28, MountainObstacleKind.rock),
    );
  }

  /// Automatic base restart reuses the seed, so learning a route remains useful.
  void reset() {
    final rng = math.Random(seed);
    ball.setValues(width / 2 + (rng.nextDouble() - .5) * 100, 75);
    velocity.setValues((rng.nextDouble() - .5) * 140, 440);
    time = 0;
    left = right = won = false;
    caveTimer = caveCooldown = clawTime = 0;
    activeCave = null;
    _accumulator = _settleTime = 0;
    _summitSettling = false;
    resetSerial++;
  }

  void update(double dt) {
    if (!dt.isFinite || dt <= 0 || won) return;
    _accumulator += dt.clamp(0.0, .1);
    final serial = resetSerial;
    while (_accumulator >= fixedStep && !won && serial == resetSerial) {
      _accumulator -= fixedStep;
      step(fixedStep);
    }
  }

  void step(double dt) {
    if (won || dt <= 0 || !dt.isFinite) return;
    time += dt;
    caveCooldown = math.max(0, caveCooldown - dt);
    clawTime = math.max(0, clawTime - dt);
    if (_summitSettling) {
      _settleTime += dt;
      ball.setValues(width / 2, height + 20);
      velocity.setValues(0, 0);
      if (_settleTime >= .25) won = true;
      return;
    }
    if (caveTimer > 0) {
      caveTimer = math.max(0, caveTimer - dt);
      if (caveTimer == 0) {
        final cave = activeCave!;
        ball.setValues(cave.x, cave.y + cave.radius + ballRadius + 2);
        velocity.setValues(cave.ejectX, 650);
        caveCooldown = 1.5;
        clawTime = .75;
      }
      return;
    }
    final oldX = ball.x;
    final oldY = ball.y;
    velocity.y -= gravity * dt;
    velocity.x *= math.exp(-.035 * dt);
    ball.x += velocity.x * dt;
    ball.y += velocity.y * dt;

    // Collision normals follow the cone slope. The camera cannot form a wall.
    final bounds = boundsAt(ball.y);
    const slope = 545 / height;
    if (ball.x < bounds.left + ballRadius) {
      ball.x = bounds.left + ballRadius;
      _reflect(1, -slope, .82);
    } else if (ball.x > bounds.right - ballRadius) {
      ball.x = bounds.right - ballRadius;
      _reflect(-1, -slope, .82);
    }

    if (velocity.y < 0) {
      for (final branch in flippers) {
        final surface = branch.y + ballRadius;
        if (oldY >= surface && ball.y <= surface) {
          final fraction = (oldY - surface) / (oldY - ball.y);
          final crossX = oldX + (ball.x - oldX) * fraction;
          if (crossX >= branch.minX - ballRadius &&
              crossX <= branch.maxX + ballRadius) {
            final active = branch.leftSide ? left : right;
            ball.y = surface;
            velocity.y = active ? 535 : 130;
            // Branch tip carries the shot laterally into neighbouring routes.
            velocity.x = (branch.leftSide ? 1 : -1) * (active ? 220 : 38);
            break;
          }
        }
      }
    }
    for (final obstacle in obstacles) {
      final dx = ball.x - obstacle.x;
      final dy = ball.y - obstacle.y;
      final distance = math.sqrt(dx * dx + dy * dy);
      final radius = obstacle.radius + ballRadius;
      if (distance < radius && distance > .001) {
        ball.setValues(
          obstacle.x + dx / distance * radius,
          obstacle.y + dy / distance * radius,
        );
        if (obstacle.kind == MountainObstacleKind.waterfall) {
          velocity.y = math.max(velocity.y, 560);
          velocity.x += dx.sign * 85;
        } else {
          _reflect(dx / distance, dy / distance, .88);
        }
      }
    }
    if (caveCooldown == 0) {
      MountainCave? firstCave;
      var firstContact = double.infinity;
      for (final cave in caves) {
        final contact = _caveContact(oldX, oldY, ball.x, ball.y, cave);
        if (contact != null && contact < firstContact) {
          firstContact = contact;
          firstCave = cave;
        }
      }
      if (firstCave != null) {
        activeCave = firstCave;
        caveTimer = .6;
        ball.setValues(firstCave.x, firstCave.y);
        velocity.setValues(0, 0);
        return;
      }
    }
    // A single top-entry receiver. Mere altitude does not complete the climb.
    if (velocity.y < 0 &&
        oldY >= height + 20 &&
        ball.y <= height + 20 &&
        (ball.x - width / 2).abs() < 52) {
      _summitSettling = true;
      _settleTime = 0;
      velocity.setValues(0, 0);
      ball.setValues(width / 2, height + 20);
    }
    if (ball.y < -25) {
      reset();
      return;
    }
    velocity.x = velocity.x.clamp(-430, 430);
    velocity.y = velocity.y.clamp(-650, 700);
  }

  // First segment/circle intersection, including a segment starting inside.
  // Cave mouth radius is a center-entry trigger, not a solid collision radius.
  double? _caveContact(
    double fromX,
    double fromY,
    double toX,
    double toY,
    MountainCave cave,
  ) {
    final dx = toX - fromX;
    final dy = toY - fromY;
    final ox = fromX - cave.x;
    final oy = fromY - cave.y;
    final c = ox * ox + oy * oy - cave.radius * cave.radius;
    if (c <= 0) return 0;
    final a = dx * dx + dy * dy;
    if (a < 1e-12) return null;
    final b = 2 * (ox * dx + oy * dy);
    final discriminant = b * b - 4 * a * c;
    if (discriminant < 0) return null;
    final t = (-b - math.sqrt(discriminant)) / (2 * a);
    return t >= 0 && t <= 1 ? t : null;
  }

  void _reflect(double nx, double ny, double restitution) {
    final length = math.sqrt(nx * nx + ny * ny);
    nx /= length;
    ny /= length;
    final inward = velocity.x * nx + velocity.y * ny;
    if (inward < 0) {
      velocity.x -= (1 + restitution) * inward * nx;
      velocity.y -= (1 + restitution) * inward * ny;
    }
  }
}

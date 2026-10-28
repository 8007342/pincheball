import 'package:flutter_test/flutter_test.dart';
import 'package:pincheball/game/mountain_model.dart';

void main() {
  test('mountain is several views wide and narrows independently of camera', () {
    final model = MountainModel();
    expect(model.boundsAt(0).right - model.boundsAt(0).left, 1260);
    expect(
      model.boundsAt(MountainModel.height).right -
          model.boundsAt(MountainModel.height).left,
      170,
    );
    // A ball crossing the old 420-wide view encounters no invisible screen wall.
    model.ball.setValues(410, 180);
    model.velocity.setValues(250, 100);
    model.step(.1);
    expect(model.ball.x, greaterThan(420));
    expect(model.velocity.x, greaterThan(0));
  });

  test('actual sloped mountain edges contain ball and reflect inward', () {
    final model = MountainModel();
    final edge = model.boundsAt(900).right;
    model.ball.setValues(edge - 2, 900);
    model.velocity.setValues(200, 0);
    model.step(MountainModel.fixedStep);
    expect(
      model.ball.x,
      lessThanOrEqualTo(
        model.boundsAt(model.ball.y).right - MountainModel.ballRadius,
      ),
    );
    expect(model.velocity.x, lessThan(0));
  });

  test('seed fixes spawn and geometry while varied seeds change spawn', () {
    final a = MountainModel(seed: 1);
    final b = MountainModel(seed: 1);
    final c = MountainModel(seed: 2);
    expect(a.ball.x, b.ball.x);
    expect(a.ball.x, isNot(c.ball.x));
    expect(a.ball.x, inInclusiveRange(580, 680));
    expect(a.flippers.map((f) => f.x), b.flippers.map((f) => f.x));
    expect(a.flippers.any((f) => f.x < 420), isTrue);
    expect(a.flippers.any((f) => f.x > 840), isTrue);
  });

  test('left and right inputs only boost corresponding branch contacts', () {
    final model = MountainModel()..left = true;
    final branch = model.flippers.firstWhere((f) => f.leftSide);
    model.ball.setValues(branch.x + 50, branch.y + 11);
    model.velocity.setValues(0, -300);
    model.step(MountainModel.fixedStep);
    expect(model.velocity.y, 535);
    final other = model.flippers.firstWhere((f) => !f.leftSide);
    model.ball.setValues(other.x - 50, other.y + 11);
    model.velocity.setValues(0, -300);
    model.step(MountainModel.fixedStep);
    expect(model.velocity.y, 130);
  });

  test(
    'cave captures, pauses, ejects with claw and does not immediately recapture',
    () {
      final model = MountainModel();
      final cave = model.caves.first;
      model.ball.setValues(cave.x, cave.y);
      model.velocity.setValues(0, -10);
      model.step(MountainModel.fixedStep);
      expect(model.caveTimer, greaterThan(0));
      expect(model.velocity.y, 0);
      for (var i = 0; i < 73; i++) {
        model.step(MountainModel.fixedStep);
      }
      expect(model.caveTimer, 0);
      expect(model.velocity.y, greaterThan(600));
      expect(model.clawTime, greaterThan(0));
      expect(model.caveCooldown, greaterThan(1));
      model.ball.setValues(cave.x, cave.y);
      model.step(MountainModel.fixedStep);
      expect(model.caveTimer, 0);
    },
  );

  test('fast cave crossing captures even when both endpoints are outside', () {
    final model = MountainModel();
    final cave = model.caves.first;
    model.ball.setValues(cave.x - 70, cave.y);
    model.velocity.setValues(18000, 0);
    model.step(MountainModel.fixedStep);
    expect(model.activeCave, same(cave));
    expect(model.caveTimer, greaterThan(0));
    expect(model.ball.x, cave.x);
  });

  test('fast near miss does not trigger a cave', () {
    final model = MountainModel();
    final cave = model.caves.first;
    model.ball.setValues(cave.x - 70, cave.y + cave.radius + 3);
    model.velocity.setValues(18000, 0);
    model.step(MountainModel.fixedStep);
    expect(model.activeCave, isNull);
    expect(model.caveTimer, 0);
  });

  test('summit needs top entry and settles before completing once', () {
    final model = MountainModel();
    model.ball.setValues(630, MountainModel.height + 19);
    model.velocity.setValues(0, 100);
    model.step(MountainModel.fixedStep);
    expect(model.won, isFalse);
    model.ball.setValues(630, MountainModel.height + 22);
    model.velocity.setValues(0, -300);
    model.step(MountainModel.fixedStep);
    expect(model.won, isFalse);
    for (var i = 0; i < 32; i++) {
      model.step(MountainModel.fixedStep);
    }
    expect(model.won, isTrue);
    final y = model.ball.y;
    model.update(.1);
    expect(model.ball.y, y);
  });

  test('base fall resets all run state and preserves the learned seed', () {
    final model = MountainModel();
    final spawnX = model.ball.x;
    final serial = model.resetSerial;
    model.left = model.right = true;
    model.ball.setValues(500, -26);
    model.velocity.setValues(0, -50);
    model.step(MountainModel.fixedStep);
    expect(model.resetSerial, serial + 1);
    expect(model.ball.x, spawnX);
    expect(model.ball.y, 75);
    expect(model.left || model.right || model.won, isFalse);
    expect(model.activeCave, isNull);
    expect(model.time, 0);
  });

  test(
    'fixed step produces same result across ordinary rendering partitions',
    () {
      final a = MountainModel(seed: 4)..left = true;
      final b = MountainModel(seed: 4)..left = true;
      for (var i = 0; i < 60; i++) {
        a.update(1 / 60);
      }
      for (var i = 0; i < 120; i++) {
        b.update(1 / 120);
      }
      expect(a.ball.x, closeTo(b.ball.x, 1e-9));
      expect(a.ball.y, closeTo(b.ball.y, 1e-9));
    },
  );
}

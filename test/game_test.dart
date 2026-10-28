import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincheball/main.dart';
import 'package:pincheball/game/mountain_model.dart';

void main() {
  test('start is idempotent and hands intro into play', () {
    final game = MountainGame(seed: 711);
    game.onGameResize(Vector2(360, 780));
    game.start();
    final serial = game.model.resetSerial;
    game.start();
    expect(game.model.resetSerial, serial);
    for (var i = 0; i < 40; i++) {
      game.update(.05);
    }
    expect(game.playing, isTrue);
    expect(game.intro, isFalse);
  });
  test('camera follows lateral world travel beyond the original screen', () {
    final game = MountainGame(seed: 711);
    game.onGameResize(Vector2(360, 780));
    game.playing = true;
    game.model.ball.setValues(1000, 300);
    game.model.velocity.setValues(0, 0);
    game.update(.016);
    expect(game.cameraX, greaterThan(MountainModel.width / 2));
    expect(game.model.ball.x, greaterThan(420));
  });
  test('summit remains loaded and restart appears after delay', () {
    final game = MountainGame(seed: 711);
    game.onGameResize(Vector2(360, 780));
    game.won = true;
    for (var i = 0; i < 59; i++) {
      game.update(.05);
    }
    expect(game.restartAvailable.value, isFalse);
    for (var i = 0; i < 3; i++) {
      game.update(.05);
    }
    expect(game.restartAvailable.value, isTrue);
    game.start();
    expect(game.won, isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pincheball/main.dart';

void main() {
  test('left input boosts left terrace but not right terrace', () {
    final left = MountainGame()..left = true;
    left.ball.setValues(100, 65);
    left.velocity.setValues(0, -300);
    left.step(1 / 60);
    expect(left.velocity.y, 465);
    final right = MountainGame()..left = true;
    right.ball.setValues(320, 65);
    right.velocity.setValues(0, -300);
    right.step(1 / 60);
    expect(right.velocity.y, 155);
  });
  test('summit requires entry from above inside receiving bowl', () {
    final game = MountainGame();
    game.ball.setValues(210, MountainGame.summit + 25);
    game.velocity.setValues(0, 50);
    game.step(1 / 120);
    expect(game.won, isFalse);
    game.velocity.setValues(0, -300);
    game.step(1 / 60);
    expect(game.won, isTrue);
  });
  test('base fall restarts the run at its introduction', () {
    final game = MountainGame();
    game.left = true;
    game.keyLeft = true;
    game.accumulator = .05;
    game.ball.setValues(210, 10);
    game.velocity.setValues(0, -100);
    game.step(1 / 120);
    expect(game.intro, isTrue);
    expect(game.cameraY, 0);
    expect(game.accumulator, 0);
    expect(game.left, isFalse);
    expect(game.keyLeft, isFalse);
    expect(game.ball.y, 80);
  });
}

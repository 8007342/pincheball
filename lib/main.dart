import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'restart_stub.dart' if (dart.library.js_interop) 'restart_web.dart';

void main() => runApp(const PincheballApp());

class PincheballApp extends StatelessWidget {
  const PincheballApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pincheball',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: const MountainScreen(),
  );
}

class MountainScreen extends StatefulWidget {
  const MountainScreen({super.key});
  @override
  State<MountainScreen> createState() => _MountainScreenState();
}

class _MountainScreenState extends State<MountainScreen>
    with WidgetsBindingObserver {
  final game = MountainGame();
  final focus = FocusNode();
  final pointers = <int, bool>{};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      pointers.clear();
      game.keyLeft = game.keyRight = false;
      sync();
      game.pauseEngine();
    } else {
      game.resumeEngine();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    focus.dispose();
    super.dispose();
  }

  void sync() {
    game.left = pointers.values.contains(true) || game.keyLeft;
    game.right = pointers.values.contains(false) || game.keyRight;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Focus(
      focusNode: focus,
      autofocus: true,
      onFocusChange: (value) {
        if (!value) {
          pointers.clear();
          game.keyLeft = game.keyRight = false;
          sync();
        }
      },
      onKeyEvent: (_, event) {
        final down = event is! KeyUpEvent;
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          game.keyLeft = down;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          game.keyRight = down;
        } else if ((event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter) &&
            down) {
          game.start();
        } else {
          return KeyEventResult.ignored;
        }
        sync();
        return KeyEventResult.handled;
      },
      child: Listener(
        onPointerDown: (event) {
          focus.requestFocus();
          if (!game.playing || game.won) {
            game.start();
            return;
          }
          pointers[event.pointer] =
              event.localPosition.dx < context.size!.width / 2;
          sync();
        },
        onPointerUp: (event) {
          pointers.remove(event.pointer);
          sync();
        },
        onPointerCancel: (event) {
          pointers.remove(event.pointer);
          sync();
        },
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: game)),
            Positioned(
              right: 16,
              bottom: 16,
              child: ValueListenableBuilder<bool>(
                valueListenable: game.restartAvailable,
                builder: (_, visible, child) => visible
                    ? TextButton(
                        onPressed: reloadPage,
                        child: const Text('Restart'),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class MountainGame extends FlameGame {
  static const worldWidth = 420.0;
  static const summit = 12000.0;
  final ball = Vector2(210, 80);
  final velocity = Vector2.zero();
  bool playing = false, won = false, left = false, right = false;
  bool keyLeft = false, keyRight = false;
  double time = 0, cameraY = 0, accumulator = 0;
  final restartAvailable = ValueNotifier(false);
  bool intro = false;
  double transitionTime = 0;
  double get viewportScale => math.min(size.x / worldWidth, size.y / 740);
  double get viewHeight => size.y / viewportScale;
  void start() {
    if (playing || intro || won) {
      return;
    }
    playing = false;
    intro = true;
    transitionTime = 0;
    won = false;
    restartAvailable.value = false;
    cameraY = 0;
    accumulator = 0;
    left = right = keyLeft = keyRight = false;
    ball.setValues(210, 80);
    velocity.setValues(45, 420);
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    if (intro) {
      transitionTime += dt;
      if (transitionTime >= 1.8) {
        intro = false;
        playing = true;
      }
    }
    if (won) {
      transitionTime += dt;
      if (transitionTime >= 3) {
        restartAvailable.value = true;
      }
    }
    if (!playing || won || size.x == 0) {
      return;
    }
    accumulator += dt.clamp(0, .1);
    while (accumulator >= 1 / 120 && playing && !won) {
      accumulator -= 1 / 120;
      step(1 / 120);
    }
    final target = (ball.y - viewHeight * .42).clamp(0.0, summit);
    cameraY += (target - cameraY) * (1 - math.exp(-dt * 5));
  }

  void step(double dt) {
    final oldY = ball.y;
    velocity.y -= 245 * dt;
    velocity.x *= math.exp(-dt * .08);
    ball.add(velocity * dt);
    if (ball.x < 23) {
      ball.x = 23;
      velocity.x = velocity.x.abs() * .82;
    }
    if (ball.x > 397) {
      ball.x = 397;
      velocity.x = -velocity.x.abs() * .82;
    }
    // Each seeded terrace offers two active flippers and a central danger gap.
    for (
      var row = math.max(0, ((ball.y - 100) / 200).floor() - 1);
      row <= (ball.y / 200).floor() + 1;
      row++
    ) {
      final y = 50.0 + row * 200;
      if (velocity.y < 0 && oldY >= y + 13 && ball.y <= y + 13) {
        final onLeft = ball.x < 188;
        final onRight = ball.x > 232;
        if (onLeft || onRight) {
          final active = onLeft ? left : right;
          ball.y = y + 13;
          velocity.y = active ? 465 : 155;
          velocity.x = (onLeft ? 1 : -1) * (active ? 130 : 48);
        }
      }
      final random = math.Random(row + 711);
      final rock = Vector2(95 + random.nextDouble() * 230, y + 115);
      final offset = ball - rock;
      if (offset.length > 0 && offset.length < 28) {
        final normal = offset.normalized();
        if (velocity.dot(normal) < 0) {
          velocity.sub(normal * (1.8 * velocity.dot(normal)));
        }
        ball.setFrom(rock + normal * 28);
      }
    }
    if (ball.y < 15) {
      playing = false;
      start();
    }
    // The summit bowl receives the ball from above; crossing its height is insufficient.
    if (ball.y <= summit + 22 &&
        oldY >= summit + 22 &&
        velocity.y < 0 &&
        (ball.x - 210).abs() < 52) {
      won = true;
      transitionTime = 0;
    }
    velocity.x = velocity.x.clamp(-260, 260);
    velocity.y = velocity.y.clamp(-540, 520);
  }

  void text(
    Canvas canvas,
    String value,
    Offset at,
    double fontSize,
    Color color, {
    bool center = false,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    p.paint(canvas, at - Offset(center ? p.width / 2 : 0, 0));
  }

  void line(Canvas c, Offset a, Offset b, Color color, double width) =>
      c.drawLine(
        a,
        b,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
  double sy(double altitude) => viewHeight - (altitude - cameraY);
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final c = canvas;
    if (size.x == 0) {
      return;
    }
    final scale = viewportScale;
    c.save();
    c.translate((size.x - worldWidth * scale) / 2, 0);
    c.scale(scale);
    final h = viewHeight;
    final progress = (cameraY / summit).clamp(0.0, 1.0);
    final sky = Color.lerp(
      const Color(0xffa9d9c8),
      const Color(0xff334e78),
      progress,
    )!;
    c.drawRect(
      Rect.fromLTWH(0, 0, 420, h),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, h), [
          sky,
          const Color(0xffe7e8c9),
        ]),
    );
    c.drawCircle(
      const Offset(330, 85),
      31,
      Paint()..color = const Color(0xffffe9aa),
    );
    for (var layer = 0; layer < 3; layer++) {
      final p = Path()..moveTo(-20, h);
      for (var x = -20.0; x <= 450; x += 15) {
        final ridge =
            h * .3 +
            layer * 75 +
            math.sin(x / 95 + layer) * 75 +
            math.cos(x / 47) * 18 +
            cameraY * (.008 + layer * .006);
        p.lineTo(x, ridge % (h + 200) - 70);
      }
      p
        ..lineTo(450, h)
        ..close();
      c.drawPath(
        p,
        Paint()
          ..color = [
            const Color(0xff8faea5),
            const Color(0xff658d81),
            const Color(0xff355e58),
          ][layer],
      );
    }
    if (cameraY < 400) {
      c.drawOval(
        Rect.fromCenter(center: Offset(90, sy(-100)), width: 540, height: 180),
        Paint()..color = const Color(0xff6bb5b6),
      );
      for (var i = 0; i < 8; i++) {
        line(
          c,
          Offset(15 + i * 42, sy(-70) - i % 3 * 12),
          Offset(43 + i * 42, sy(-70) - i % 3 * 12),
          const Color(0xffb4e0cc),
          2,
        );
      }
    }
    for (var i = 0; i < 8; i++) {
      final x = (i * 93.0 + time * (2 + i % 3)) % 540 - 60;
      final y = 80 + i % 4 * 62.0;
      c.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 80, height: 17),
        Paint()..color = const Color(0x33ffffff),
      );
    }
    if (playing && !won) {
      drawCourse(c);
    }
    if (!playing || won) {
      final rockY = h * .71;
      c.drawOval(
        Rect.fromCenter(
          center: Offset(210, rockY + 35),
          width: 210,
          height: 64,
        ),
        Paint()..color = const Color(0xff203e3d),
      );
      drawHiker(c, Offset(210, rockY));
      text(
        c,
        'PINCHEBALL',
        Offset(210, h * .19),
        36,
        const Color(0xffffefb9),
        center: true,
      );
      text(
        c,
        won ? 'A LITTLE CLOSER TO THE SKY' : 'THE MOUNTAIN IS CALLING',
        Offset(210, h * .19 + 52),
        13,
        const Color(0xff173e3d),
        center: true,
      );
      text(
        c,
        won ? 'SUMMIT REACHED' : 'ONE BALL. ALL THE WAY UP.',
        Offset(210, rockY + 83),
        14,
        const Color(0xffffefb9),
        center: true,
      );
      text(
        c,
        won
            ? 'BREATHE. YOU MADE IT.'
            : intro
            ? 'THE JOURNEY BEGINS…'
            : 'TAP ANYWHERE TO BEGIN',
        Offset(210, h - 53),
        13,
        const Color(0xffffefb9),
        center: true,
      );
    } else {
      text(
        c,
        '${(ball.y / summit * 100).clamp(0, 100).floor()}%  ↑ SUMMIT',
        const Offset(20, 24),
        14,
        const Color(0xffffefb9),
      );
      text(
        c,
        '← LEFT       RIGHT →',
        Offset(210, h - 30),
        12,
        const Color(0xffffefb9),
        center: true,
      );
    }
    c.restore();
  }

  void drawCourse(Canvas c) {
    final low = math.max(0, (cameraY / 200).floor() - 1);
    final high = ((cameraY + viewHeight) / 200).ceil() + 1;
    for (var row = low; row <= high; row++) {
      final altitude = 50.0 + row * 200;
      if (altitude > summit - 80) {
        continue;
      }
      final y = sy(altitude);
      final snow = altitude / summit > .75;
      final foliage = snow ? const Color(0xffe2eee6) : const Color(0xff254f43);
      final random = math.Random(row + 711);
      final rockX = 95 + random.nextDouble() * 230;
      // Side scenery never obscures the collision plane.
      for (final x in [14.0, 406.0]) {
        line(
          c,
          Offset(x, y - 20),
          Offset(x, y - 88),
          const Color(0xff725d48),
          7,
        );
        final tree = Path()
          ..moveTo(x, y - 125)
          ..lineTo(x - 31, y - 40)
          ..lineTo(x + 31, y - 40)
          ..close();
        c.drawPath(tree, Paint()..color = foliage);
        final sway = math.sin(time * 1.2 + row) * 2;
        line(
          c,
          Offset(x - 12, y - 67),
          Offset(x + 12 + sway, y - 68),
          foliage,
          8,
        );
      }
      line(
        c,
        Offset(25, y + 23),
        Offset(150, y + 12),
        const Color(0xff9c8970),
        13,
      );
      line(
        c,
        Offset(395, y + 23),
        Offset(270, y + 12),
        const Color(0xff9c8970),
        13,
      );
      final leftRise = left ? -22.0 : 10.0;
      final rightRise = right ? -22.0 : 10.0;
      line(
        c,
        Offset(55, y),
        Offset(184, y + leftRise),
        left ? const Color(0xffffce79) : const Color(0xffd69a62),
        12,
      );
      line(
        c,
        Offset(365, y),
        Offset(236, y + rightRise),
        right ? const Color(0xffffce79) : const Color(0xffd69a62),
        12,
      );
      c.drawCircle(
        Offset(rockX, sy(altitude + 115)),
        18,
        Paint()..color = const Color(0xff647c70),
      );
      c.drawCircle(
        Offset(rockX - 5, sy(altitude + 115) - 5),
        7,
        Paint()..color = const Color(0xffa2b3a1),
      );
    }
    if (cameraY + viewHeight > summit) {
      final y = sy(summit);
      line(
        c,
        Offset(153, y - 13),
        Offset(165, y + 13),
        const Color(0xffffd189),
        10,
      );
      line(
        c,
        Offset(165, y + 13),
        Offset(255, y + 13),
        const Color(0xffffd189),
        10,
      );
      line(
        c,
        Offset(255, y + 13),
        Offset(267, y - 13),
        const Color(0xffffd189),
        10,
      );
      text(
        c,
        'SUMMIT',
        Offset(210, y - 60),
        14,
        const Color(0xffffefb9),
        center: true,
      );
    }
    final at = Offset(ball.x, sy(ball.y));
    c.drawCircle(
      at + const Offset(3, 5),
      10,
      Paint()..color = const Color(0x44203532),
    );
    c.drawCircle(at, 9, Paint()..color = const Color(0xffffe3a0));
    c.drawCircle(at - const Offset(3, 3), 3, Paint()..color = Colors.white);
  }

  void drawHiker(Canvas c, Offset p) {
    final swing = math.sin(time * 2.5) * 7;
    line(
      c,
      p + const Offset(-8, 0),
      p + Offset(-5 + swing, 27),
      const Color(0xff293f53),
      8,
    );
    line(
      c,
      p + const Offset(8, 0),
      p + Offset(11 - swing, 27),
      const Color(0xff293f53),
      8,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: p + const Offset(0, -21),
          width: 29,
          height: 38,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xffdf7853),
    );
    c.drawRect(
      Rect.fromCenter(
        center: p + const Offset(-19, -22),
        width: 13,
        height: 26,
      ),
      Paint()..color = const Color(0xffe7bb76),
    );
    c.drawCircle(
      p + const Offset(0, -50),
      11,
      Paint()..color = const Color(0xffedc99f),
    );
    c.drawRect(
      Rect.fromCenter(center: p + const Offset(1, -60), width: 34, height: 8),
      Paint()..color = const Color(0xffe3bd72),
    );
    c.drawRect(
      Rect.fromCenter(center: p + const Offset(1, -65), width: 21, height: 10),
      Paint()..color = const Color(0xffe3bd72),
    );
    line(
      c,
      p + const Offset(8, -28),
      p + const Offset(23, -7),
      const Color(0xffedc99f),
      6,
    );
  }
}

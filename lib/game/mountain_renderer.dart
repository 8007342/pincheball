import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mountain_model.dart';
import 'mountain_scene.dart';

/// Presentation only: the portrait camera looks into a wider collision world.
class MountainRenderer {
  ui.Image? kit;
  Future<void> load() async {
    final bytes = await rootBundle.load('assets/images/mountain-kit.png');
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    kit = (await codec.getNextFrame()).image;
    codec.dispose();
  }

  void sprite(Canvas c, int index, Rect destination) {
    final image = kit;
    if (image == null) return;
    const sources = [
      Rect.fromLTWH(0, 0, 627, 724),
      Rect.fromLTWH(627, 0, 627, 724),
      Rect.fromLTWH(0, 724, 700, 530),
      Rect.fromLTWH(700, 724, 554, 530),
    ];
    c.drawImageRect(
      image,
      sources[index],
      destination,
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  static const ink = Color(0xff183c42);
  void line(Canvas c, Offset a, Offset b, Color color, double width) {
    c.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void label(
    Canvas c,
    String text,
    Offset p,
    double size,
    Color color, {
    bool center = false,
  }) {
    final t = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    t.paint(c, p - Offset(center ? t.width / 2 : 0, 0));
  }

  double hash(int n) => math.Random(n + 9137).nextDouble();
  void render(
    Canvas c,
    Size size,
    Rect stage,
    MountainModel m,
    MountainScene scene,
    double cameraX,
    double cameraBottom,
    double time, {
    required bool playing,
    required bool intro,
    required bool won,
    required double transitionTime,
  }) {
    c.drawRect(Offset.zero & size, Paint()..color = const Color(0xff122e37));
    final scale = stage.width / 420;
    final h = stage.height / scale;
    c.save();
    c.clipRect(stage);
    c.translate(stage.left, 0);
    c.scale(scale);
    final progress = (m.ball.y / MountainModel.height).clamp(0.0, 1.0);
    backdrop(c, h, won ? 1 : progress, time, cameraX, cameraBottom);
    if (playing && !won) {
      terrain(c, m, scene, cameraX, cameraBottom, h, time);
      // Screen aligned controls and a directional summit cue; no remote fonts.
      label(c, 'LEFT', Offset(32, h - 40), 11, const Color(0xfff5e8bd));
      label(c, 'RIGHT', Offset(329, h - 40), 11, const Color(0xfff5e8bd));
      line(
        c,
        Offset(210, h - 44),
        Offset(210, h - 28),
        const Color(0x55f5e8bd),
        1,
      );
      final bearing = ((MountainModel.width / 2 - cameraX) * .12).clamp(
        -42.0,
        42.0,
      );
      line(
        c,
        Offset(210, 30),
        Offset(210 + bearing, 20),
        const Color(0xfff6e8b8),
        2,
      );
      label(
        c,
        'THE SUMMIT',
        const Offset(210, 41),
        10,
        const Color(0xfff6e8b8),
        center: true,
      );
      if (m.caveTimer > 0)
        label(
          c,
          'SOMETHING STIRS...',
          Offset(210, h * .67),
          12,
          const Color(0xffffda9a),
          center: true,
        );
    } else {
      tableau(
        c,
        h,
        time,
        won,
        intro
            ? transitionTime / 1.8
            : won
            ? (transitionTime / 3).clamp(0, 1)
            : 0,
      );
      if (!won) {
        label(
          c,
          'PINCHEBALL',
          Offset(210, h * .16),
          35,
          const Color(0xffffedb8),
          center: true,
        );
        label(
          c,
          'A MOUNTAIN TO WANDER',
          Offset(210, h * .16 + 51),
          11,
          const Color(0xffd2e3cc),
          center: true,
        );
        label(
          c,
          intro ? 'FOLLOW THE TRAIL...' : 'TAP ANYWHERE TO CLIMB',
          Offset(210, h - 65),
          12,
          const Color(0xffffedb8),
          center: true,
        );
      } else {
        label(
          c,
          'ABOVE THE CLOUDS',
          Offset(210, h * .16),
          23,
          const Color(0xffffedb8),
          center: true,
        );
        label(
          c,
          'All that way. All your own.',
          Offset(210, h * .16 + 40),
          11,
          const Color(0xffd9e8e5),
          center: true,
        );
      }
    }
    c.restore();
  }

  void backdrop(Canvas c, double h, double p, double t, double cx, double cy) {
    c.drawRect(
      Rect.fromLTWH(0, 0, 420, h),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, h), [
          Color.lerp(const Color(0xff376d82), const Color(0xff243d67), p)!,
          Color.lerp(const Color(0xffe5d8ac), const Color(0xffb9d6da), p)!,
        ]),
    );
    c.drawCircle(
      const Offset(320, 125),
      33,
      Paint()..color = const Color(0xffffdf9c),
    );
    for (var layer = 0; layer < 4; layer++) {
      final path = Path()..moveTo(-50, h);
      for (double x = -50; x < 480; x += 10) {
        final wx = x + cx * (.02 + layer * .025);
        final y =
            h * (.32 + layer * .13) +
            math.sin(wx / 110 + layer * 2) * 45 +
            math.cos(wx / 53 + layer) * 25 -
            cy * .008;
        path.lineTo(x, y);
      }
      path
        ..lineTo(480, h)
        ..close();
      c.drawPath(
        path,
        Paint()
          ..color = [
            const Color(0xff94b5b4),
            const Color(0xff658f97),
            const Color(0xff3f7179),
            const Color(0xff294f5b),
          ][layer],
      );
    }
    // The valley lake remains recognizable in the summit composition.
    final lake = Path()
      ..moveTo(-40, h * .78)
      ..cubicTo(70, h * .70, 210, h * .86, 460, h * .73)
      ..lineTo(460, h * .91)
      ..cubicTo(210, h * .98, 90, h * .84, -40, h * .96)
      ..close();
    c.drawPath(
      lake,
      Paint()
        ..color = Color.lerp(
          const Color(0xff6dafa9),
          const Color(0xff73a6ba),
          p,
        )!,
    );
    for (var i = 0; i < 16; i++) {
      final x = hash(i) * 440 - 10;
      final y = h * (.79 + hash(i + 80) * .12);
      line(
        c,
        Offset(x, y),
        Offset(x + 12 + math.sin(t * .6 + i) * 5, y),
        const Color(0x778ed2c7),
        1,
      );
    }
    for (var i = 0; i < 6; i++) {
      final x = (hash(i + 600) * 560 + t * (1 + i % 3) - cx * .025) % 560 - 70;
      final y = 70 + i * 53.0;
      c.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 100, height: 14),
        Paint()..color = const Color(0x24edf1df),
      );
    }
  }

  Offset project(double x, double y, double cx, double cb, double h) =>
      Offset(x - cx + 210, h - (y - cb));

  void terrain(
    Canvas c,
    MountainModel m,
    MountainScene scene,
    double cx,
    double cb,
    double h,
    double t,
  ) {
    final path = Path();
    final low = math.max(-20.0, cb - 100),
        high = math.min(MountainModel.height + 80, cb + h + 100);
    for (double y = low; y <= high; y += 25) {
      final b = m.boundsAt(y);
      final p = project(b.left, y, cx, cb, h);
      if (y == low) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    for (double y = high; y >= low; y -= 25) {
      final b = m.boundsAt(y);
      final p = project(b.right, y, cx, cb, h);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    final snow =
        ((cb + h * .45) / MountainModel.height - .55).clamp(0.0, .45) / .45;
    c.drawPath(
      path,
      Paint()
        ..color = Color.lerp(
          const Color(0xff577a58),
          const Color(0xffc9d9d3),
          snow,
        )!,
    );
    c.drawPath(
      path,
      Paint()
        ..color = const Color(0xff8d9c7a)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
    // Fine clusters stay world anchored; their number is bounded by this small map.
    c.save();
    c.clipPath(path);
    for (var i = 0; i < 290; i++) {
      final x = hash(i + 2300) * MountainModel.width,
          y = hash(i + 4300) * MountainModel.height;
      final p = project(x, y, cx, cb, h);
      if (p.dx < -30 || p.dx > 450 || p.dy < -30 || p.dy > h + 30) continue;
      final color = y > MountainModel.height * .75
          ? const Color(0xffecede0)
          : [
              const Color(0xff769765),
              const Color(0xff9ba16a),
              const Color(0xff3e6851),
            ][i % 3];
      c.drawRect(
        Rect.fromLTWH(p.dx, p.dy, 3 + i % 5, 2 + i % 3),
        Paint()..color = color,
      );
      if (i % 7 == 0)
        line(
          c,
          p,
          p + Offset(math.sin(t + i) * 2, -7),
          const Color(0xffa8b580),
          1,
        );
    }
    // Wandering trail suggests lateral routes, never a screen boundary.
    final trail = Path();
    for (double y = 0; y <= MountainModel.height; y += 20) {
      final x =
          MountainModel.width / 2 +
          math.sin(y / 170) * math.max(0, 180 * (1 - y / MountainModel.height));
      final p = project(x, y, cx, cb, h);
      if (y == 0) {
        trail.moveTo(p.dx, p.dy);
      } else {
        trail.lineTo(p.dx, p.dy);
      }
    }
    c.drawPath(
      trail,
      Paint()
        ..color = const Color(0x449cc09b)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 19,
    );
    c.restore();

    for (final d in scene.visible(
      left: cx - 210,
      right: cx + 210,
      bottom: cb,
      top: cb + h,
      padding: 90,
    )) {
      final p = project(d.x, d.y, cx, cb, h);
      switch (d.kind) {
        case MountainDecorationKind.tree:
          tree(c, p, 13 * d.scale, t, d.phase);
        case MountainDecorationKind.shrub:
          if (kit != null) {
            sprite(
              c,
              3,
              Rect.fromCenter(
                center: p + const Offset(0, -13),
                width: 44 * d.scale,
                height: 41 * d.scale,
              ),
            );
            break;
          }
          for (var j = 0; j < 5; j++) {
            final sway = math.sin(t * .8 + d.phase + j * .3) * 1.5;
            c.drawOval(
              Rect.fromCenter(
                center:
                    p + Offset((j - 2) * 6 * d.scale + sway, -5 - (j % 2) * 5),
                width: 15 * d.scale,
                height: 12 * d.scale,
              ),
              Paint()
                ..color = j.isEven
                    ? const Color(0xff44795b)
                    : const Color(0xff6c975e),
            );
          }
        case MountainDecorationKind.grass:
          for (var j = 0; j < 4; j++) {
            line(
              c,
              p + Offset(j * 3, 0),
              p + Offset(j * 3 + math.sin(t + d.phase) * 2, -5 - j % 3 * 2),
              const Color(0xff9cab72),
              1,
            );
          }
        case MountainDecorationKind.flowers:
          for (var j = 0; j < 3; j++) {
            final stem = p + Offset(j * 5, -6 - j % 2 * 4);
            line(c, p + Offset(j * 5, 0), stem, const Color(0xff739868), 1);
            c.drawRect(
              Rect.fromCenter(center: stem, width: 3, height: 3),
              Paint()
                ..color = j.isEven
                    ? const Color(0xffe0b87d)
                    : const Color(0xffbba7c5),
            );
          }
        case MountainDecorationKind.stone:
          rock(c, p, 7 * d.scale);
        case MountainDecorationKind.snowPatch:
          c.drawOval(
            Rect.fromCenter(
              center: p,
              width: 30 * d.scale,
              height: 9 * d.scale,
            ),
            Paint()..color = const Color(0xffe4e8d9),
          );
      }
    }
    for (final o in m.obstacles) {
      final p = project(o.x, o.y, cx, cb, h);
      if (p.dx < -80 || p.dx > 500 || p.dy < -100 || p.dy > h + 100) continue;
      final kind = o.kind.name;
      if (kind == 'tree') {
        tree(c, p, o.radius, t, o.x * .02);
      } else if (kind == 'waterfall') {
        waterfall(c, p, o.radius, t);
      } else {
        rock(c, p, o.radius);
      }
    }
    for (final f in m.flippers) {
      final p = project(f.x, f.y, cx, cb, h);
      if (p.dx < -160 || p.dx > 580 || p.dy < -100 || p.dy > h + 100) continue;
      final active = f.leftSide ? m.left : m.right;
      final direction = f.leftSide ? 1.0 : -1.0;
      final tip = p + Offset(direction * f.length, active ? -38 : 12);
      line(
        c,
        p + const Offset(0, 8),
        tip + const Offset(0, 8),
        const Color(0x55332e29),
        12,
      );
      line(
        c,
        p,
        tip,
        active ? const Color(0xffd5b66c) : const Color(0xff967549),
        12,
      );
      line(
        c,
        p + const Offset(0, -3),
        tip + const Offset(0, -3),
        const Color(0xffc9a774),
        3,
      );
      c.drawCircle(p, 8, Paint()..color = const Color(0xff4f6350));
      // A small leaf and side notch make branch controls recognizable.
      c.drawOval(
        Rect.fromCenter(
          center: tip + const Offset(-4, -9),
          width: 17,
          height: 8,
        ),
        Paint()..color = const Color(0xff91b56d),
      );
      label(
        c,
        f.leftSide ? 'L' : 'R',
        p + const Offset(0, -24),
        9,
        const Color(0xffeee6c7),
        center: true,
      );
    }
    for (final cave in m.caves) {
      final p = project(cave.x, cave.y, cx, cb, h);
      rock(c, p, cave.radius + 13);
      if (kit != null)
        sprite(
          c,
          2,
          Rect.fromCenter(
            center: p + Offset(0, -cave.radius * .15),
            width: cave.radius * 3.4,
            height: cave.radius * 2.6,
          ),
        );
      if (kit == null)
        c.drawOval(
          Rect.fromCenter(
            center: p,
            width: cave.radius * 2,
            height: cave.radius * 1.65,
          ),
          Paint()..color = const Color(0xff162c31),
        );
      line(
        c,
        p + Offset(-cave.radius * .65, 9),
        p + Offset(cave.radius * .65, 9),
        const Color(0xff6b7e5e),
        6,
      );
      if (m.clawTime > 0 && m.activeCave == cave) {
        final reach = math.sin((m.clawTime * 5).clamp(0.0, math.pi)) * 38;
        for (var j = 0; j < 3; j++) {
          line(
            c,
            p + Offset(-10 + j * 10, 4),
            p + Offset(-15 + j * 10, -20 - reach),
            const Color(0xffe3c3a0),
            4,
          );
        }
      }
    }
    final top = project(
      MountainModel.width / 2,
      MountainModel.height,
      cx,
      cb,
      h,
    );
    rock(c, top + const Offset(0, 20), 48);
    line(
      c,
      top + const Offset(-43, -6),
      top + const Offset(-28, 17),
      const Color(0xffeee3b7),
      7,
    );
    line(
      c,
      top + const Offset(-28, 17),
      top + const Offset(28, 17),
      const Color(0xffeee3b7),
      7,
    );
    line(
      c,
      top + const Offset(28, 17),
      top + const Offset(43, -6),
      const Color(0xffeee3b7),
      7,
    );
    if (m.caveTimer <= 0) {
      final p = project(m.ball.x, m.ball.y, cx, cb, h);
      c.drawOval(
        Rect.fromCenter(center: p + const Offset(4, 9), width: 21, height: 9),
        Paint()..color = const Color(0x55233f40),
      );
      c.drawCircle(p, 9, Paint()..color = const Color(0xffffe9ad));
      c.drawRect(
        Rect.fromLTWH(p.dx - 5, p.dy - 5, 5, 4),
        Paint()..color = const Color(0xfffffff0),
      );
    }
  }

  void rock(Canvas c, Offset p, double r) {
    if (kit != null) {
      sprite(
        c,
        1,
        Rect.fromCenter(
          center: p + Offset(0, -r * .25),
          width: r * 2.7,
          height: r * 2.7,
        ),
      );
      return;
    }
    final path = Path()
      ..moveTo(p.dx - r, p.dy + r * .45)
      ..lineTo(p.dx - r * .8, p.dy - r * .5)
      ..lineTo(p.dx - r * .15, p.dy - r * .85)
      ..lineTo(p.dx + r * .65, p.dy - r * .55)
      ..lineTo(p.dx + r, p.dy + r * .25)
      ..lineTo(p.dx + r * .3, p.dy + r * .65)
      ..close();
    c.drawPath(path, Paint()..color = const Color(0xff596c66));
    final face = Path()
      ..moveTo(p.dx - r * .8, p.dy - r * .5)
      ..lineTo(p.dx - r * .15, p.dy - r * .85)
      ..lineTo(p.dx + r * .65, p.dy - r * .55)
      ..lineTo(p.dx, p.dy - r * .15)
      ..close();
    c.drawPath(face, Paint()..color = const Color(0xff92a397));
  }

  void tree(Canvas c, Offset p, double r, double t, double phase) {
    if (kit != null) {
      sprite(
        c,
        0,
        Rect.fromLTWH(p.dx - r * 2.3, p.dy - r * 5.0, r * 4.6, r * 5.3),
      );
      for (var i = 0; i < 4; i++) {
        final a = t * .6 + phase + i;
        c.drawRect(
          Rect.fromLTWH(p.dx + math.sin(a) * r, p.dy - r * (1 + i * .7), 2, 1),
          Paint()..color = const Color(0xffaec66e),
        );
      }
      return;
    }
    line(
      c,
      p + Offset(0, r * .7),
      p + Offset(0, -r * 1.5),
      const Color(0xff655c42),
      r * .45,
    );
    for (var j = 0; j < 3; j++) {
      final sway = math.sin(t * .9 + phase + j * .4) * 2;
      final canopy = Path()
        ..moveTo(p.dx + sway, p.dy - r * (3.8 - j * .65))
        ..lineTo(p.dx - r * (1.15 + j * .16) + sway, p.dy - r * (1.5 - j * .55))
        ..lineTo(p.dx + r * (1.15 + j * .16) + sway, p.dy - r * (1.5 - j * .55))
        ..close();
      c.drawPath(
        canopy,
        Paint()
          ..color = [
            const Color(0xff306756),
            const Color(0xff285c4b),
            const Color(0xff204d42),
          ][j],
      );
      for (var k = 0; k < 3; k++) {
        c.drawRect(
          Rect.fromLTWH(
            p.dx - r * .55 + k * r * .4 + sway,
            p.dy - r * (2 - j * .55),
            r * .24,
            3,
          ),
          Paint()..color = const Color(0xff477e5c),
        );
      }
    }
  }

  void waterfall(Canvas c, Offset p, double r, double t) {
    rock(c, p + Offset(0, -r * .3), r + 9);
    c.drawRect(
      Rect.fromCenter(center: p + Offset(0, 10), width: r * 1.2, height: r * 3),
      Paint()..color = const Color(0xff77bcbc),
    );
    for (var j = 0; j < 6; j++) {
      final y = ((t * 50 + j * 15) % (r * 3)) - r * 1.5;
      line(
        c,
        p + Offset(-r * .35 + j % 3 * r * .3, y),
        p + Offset(-r * .35 + j % 3 * r * .3, y + 8),
        const Color(0xffd2e6ce),
        2,
      );
    }
    c.drawOval(
      Rect.fromCenter(
        center: p + Offset(0, r * 1.8),
        width: r * 2.5,
        height: 12,
      ),
      Paint()..color = const Color(0x88cdebd7),
    );
  }

  void tableau(Canvas c, double h, double t, bool won, double progress) {
    if (won) {
      // Cloud sea opens slowly onto the same lake, trees, falls and cave silhouettes.
      final ease = progress * progress * (3 - 2 * progress);
      c.save();
      c.translate(0, 25 * (1 - ease));
      for (var i = 0; i < 4; i++) {
        final x = 40 + i * 112.0 + math.sin(t * .08 + i) * 14;
        c.drawOval(
          Rect.fromCenter(
            center: Offset(x, h * .58 + i % 2 * 25),
            width: 210,
            height: 58,
          ),
          Paint()..color = Color.fromRGBO(213, 230, 223, .25 + ease * .15),
        );
      }
      waterfall(c, Offset(83, h * .76), 10, t);
      for (var i = 0; i < 6; i++) {
        tree(
          c,
          Offset(35 + i * 65.0, h * .86 + i % 2 * 12),
          6,
          t,
          i.toDouble(),
        );
      }
      rock(c, Offset(315, h * .82), 14);
      c.drawOval(
        Rect.fromCenter(center: Offset(315, h * .82), width: 15, height: 12),
        Paint()..color = ink,
      );
      c.restore();
    }
    final rise = introEase(progress) * (won ? 0 : 24);
    final rockY = h * .72 - rise;
    final peak = Path()
      ..moveTo(30, h)
      ..lineTo(170, rockY + 8)
      ..lineTo(236, rockY - 7)
      ..lineTo(405, h)
      ..close();
    c.drawPath(
      peak,
      Paint()..color = won ? const Color(0xffbccfc9) : const Color(0xff536955),
    );
    rock(c, Offset(207, rockY + 27), 66);
    if (won)
      line(
        c,
        Offset(164, rockY - 7),
        Offset(236, rockY - 13),
        const Color(0xffeef0df),
        11,
      );
    drawHiker(c, Offset(210, rockY), t);
    for (var i = 0; i < 3; i++) {
      final x = (t * 8 + i * 145) % 500 - 40,
          y = h * .37 + math.sin(t * .4 + i) * 13;
      line(
        c,
        Offset(x - 5, y - 2),
        Offset(x, y + math.sin(t * 3 + i) * 2),
        ink,
        1,
      );
      line(
        c,
        Offset(x, y + math.sin(t * 3 + i) * 2),
        Offset(x + 5, y - 2),
        ink,
        1,
      );
    }
  }

  double introEase(double p) {
    final q = p.clamp(0.0, 1.0);
    return q * q * (3 - 2 * q);
  }

  void drawHiker(Canvas c, Offset p, double time) {
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

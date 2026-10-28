import 'dart:math' as math;
import 'game/mountain_model.dart';
import 'game/mountain_scene.dart';
import 'game/mountain_renderer.dart';

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
  MountainGame({int? seed}) : model = MountainModel(seed: seed ?? DateTime.now().millisecondsSinceEpoch);
  final MountainModel model;
  late final MountainScene scene = MountainScene(model);
  final restartAvailable = ValueNotifier(false);
  bool playing = false, won = false, intro = false;
  bool left = false, right = false, keyLeft = false, keyRight = false;
  double time = 0, transitionTime = 0;
  double cameraX = MountainModel.width / 2, cameraBottom = 0;
  final painter = MountainRenderer();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await painter.load();
  }

  Rect get stage => Rect.fromLTWH(
    (size.x - math.min(size.x, size.y * 420 / 780)) / 2,
    0, math.min(size.x, size.y * 420 / 780), size.y,
  );
  double get viewportScale => stage.width / 420;
  double get viewHeight => size.y / viewportScale;

  void start() {
    if (playing || intro || won) return;
    model.reset();
    intro = true;
    transitionTime = 0;
    restartAvailable.value = false;
    left = right = keyLeft = keyRight = false;
    cameraX = model.ball.x;
    cameraBottom = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final elapsed = dt.clamp(0.0, .05);
    time += elapsed;
    if (intro) {
      transitionTime += elapsed;
      if (transitionTime >= 1.8) { intro = false; playing = true; }
    }
    if (won) {
      transitionTime += elapsed;
      if (transitionTime >= 3 && !restartAvailable.value) restartAvailable.value = true;
    }
    if (!playing || won || size.x <= 0 || size.y <= 0) return;
    model.left = left;
    model.right = right;
    final serial = model.resetSerial;
    model.update(elapsed);
    if (serial != model.resetSerial) {
      left = right = keyLeft = keyRight = false;
      cameraX = model.ball.x;
      cameraBottom = 0;
    }
    if (model.won) { won = true; transitionTime = 0; }
    final lead = (model.velocity.x * .18).clamp(-65.0, 65.0);
    final targetX = (model.ball.x + lead).clamp(210.0, MountainModel.width - 210);
    final targetY = (model.ball.y - viewHeight * (model.velocity.y >= 0 ? .38 : .62)).clamp(0.0, MountainModel.height - viewHeight * .5);
    final smooth = 1 - math.exp(-elapsed * 5);
    cameraX += (targetX - cameraX) * smooth;
    cameraBottom += (targetY - cameraBottom) * smooth;
    // Safety framing is stronger than decorative camera easing.
    cameraX = cameraX.clamp(model.ball.x - 160, model.ball.x + 160);
    cameraBottom = cameraBottom.clamp(model.ball.y - viewHeight + 90, model.ball.y - 90).clamp(0.0, MountainModel.height);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) return;
    painter.render(canvas, Size(size.x, size.y), stage, model, scene, cameraX, cameraBottom,
      time, playing: playing, intro: intro, won: won, transitionTime: transitionTime);
  }
}

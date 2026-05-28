import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../../../core/theme.dart';
import '../../../math_engine/domain/entities/math_problem.dart';

class GamePainter extends CustomPainter {
  final GameControllerState state;

  GamePainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // 1. Dibujar el fondo del espacio/pista
    final bgPaint = Paint()..color = GameTheme.spaceCadet;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Dibujar pista de carreras (carril central vertical)
    final double trackWidth = width * 0.85;
    final double trackLeft = (width - trackWidth) / 2;

    final trackPaint = Paint()
      ..color = GameTheme.slateBlue.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(trackLeft, 0, trackWidth, height),
      trackPaint,
    );

    // Bordes brillantes neón de la pista
    final borderPaint = Paint()
      ..color = GameTheme.neonCyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(trackLeft, 0),
      Offset(trackLeft, height),
      borderPaint,
    );
    canvas.drawLine(
      Offset(trackLeft + trackWidth, 0),
      Offset(trackLeft + trackWidth, height),
      borderPaint,
    );

    // Línea segmentada en el centro que se desplaza hacia abajo (efecto de movimiento)
    if (state.status == GameStatus.running) {
      final double dashHeight = 30.0;
      final double dashSpace = 20.0;
      final double speedOffset =
          (state.progress * height * 5) % (dashHeight + dashSpace);

      final dashPaint = Paint()
        ..color = GameTheme.textGrey.withValues(alpha: 0.2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      double y = -speedOffset;
      while (y < height) {
        canvas.drawLine(
          Offset(width / 2, y),
          Offset(width / 2, y + dashHeight),
          dashPaint,
        );
        y += dashHeight + dashSpace;
      }
    }

    // 2. Dibujar Portales Matemáticos (Decision Zones)
    _paintPortals(canvas, size, trackLeft, trackWidth);

    // 3. Dibujar Jefe Enemigo en la Meta (si el progreso está avanzado)
    _paintBoss(canvas, size, trackLeft, trackWidth);

    // 4. Dibujar a Leo y su Ejército de Soldados
    _paintPlayerArmy(canvas, size);
  }

  /// Renderiza los portales matemáticos flotantes en su posición de progreso correspondiente
  void _paintPortals(
    Canvas canvas,
    Size size,
    double trackLeft,
    double trackWidth,
  ) {
    final double width = size.width;
    final double height = size.height;

    // Altura vertical central donde se dibuja a Leo para interactuar (75% de la pantalla)
    final double playerY = height * 0.75;

    for (int i = 0; i < state.decisionZones.length; i++) {
      if (i < state.levelProblems.length) {
        final double zoneProgress = state.decisionZones[i];
        final problem = state.levelProblems[i];

        // Calcular posición Y en pantalla en base al progreso actual del juego
        // A medida que el progreso aumenta, el portal baja hacia Leo.
        final double relativeProgress = zoneProgress - state.progress;

        // Solo dibujar portales que están por delante en el camino
        if (relativeProgress > -0.1 && relativeProgress < 0.8) {
          final double portalY = playerY - (relativeProgress * height * 2.5);

          // Si el portal ya fue cruzado por Leo, no se pinta
          if (portalY > height + 50) continue;

          // Dimensiones de los portales
          final double portalWidth = trackWidth * 0.44;
          final double portalHeight = 65.0;
          final double gap = trackWidth * 0.04;

          // Portal Izquierdo (A)
          final double rectALeft = trackLeft + gap / 2;
          final Rect rectA = Rect.fromLTWH(
            rectALeft,
            portalY - portalHeight / 2,
            portalWidth,
            portalHeight,
          );

          // Portal Derecho (B)
          final double rectBLeft = width / 2 + gap / 2;
          final Rect rectB = Rect.fromLTWH(
            rectBLeft,
            portalY - portalHeight / 2,
            portalWidth,
            portalHeight,
          );

          // Estilo de diseño pedagógico: Ambos portales se ven de color cian neón neutro
          // para que el niño calcule antes de cruzar. Si el portal ya pasó la línea de Leo,
          // se revela si fue correcto o no brevemente.
          final bool isPassed = portalY > playerY;
          Color portalColorA = GameTheme.neonCyan;
          Color portalColorB = GameTheme.neonCyan;

          if (isPassed) {
            // Revelar feedback
            final int correctIdx = problem.getCorrectOptionIndex(
              state.soldiersCountAtPortal[i] ?? 1,
            );
            portalColorA = (correctIdx == 0)
                ? GameTheme.neonGreen
                : GameTheme.neonRed;
            portalColorB = (correctIdx == 1)
                ? GameTheme.neonGreen
                : GameTheme.neonRed;
          }

          // Dibujar Portal A
          _drawPortalFrame(
            canvas,
            rectA,
            portalColorA,
            problem.optionA.expression,
            isPassed,
          );

          // Dibujar Portal B
          _drawPortalFrame(
            canvas,
            rectB,
            portalColorB,
            problem.optionB.expression,
            isPassed,
          );
        }
      }
    }
  }

  /// Dibuja el marco y texto de un portal individual con efecto neón
  void _drawPortalFrame(
    Canvas canvas,
    Rect rect,
    Color color,
    String text,
    bool isPassed,
  ) {
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(12),
    );

    // Relleno semi-transparente del portal
    final fillPaint = Paint()
      ..color = color.withValues(alpha: isPassed ? 0.25 : 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    // Borde neón
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(rrect, borderPaint);

    // Dibujar el texto de la operación matemática
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(blurRadius: 10.0, color: color, offset: const Offset(0, 0)),
      ],
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: rect.width, maxWidth: rect.width);

    final textOffset = Offset(
      rect.left,
      rect.top + (rect.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  /// Dibuja el combate final con el Jefe Enemigo al final del camino
  void _paintBoss(
    Canvas canvas,
    Size size,
    double trackLeft,
    double trackWidth,
  ) {
    final double width = size.width;
    final double height = size.height;
    final double playerY = height * 0.75;

    // Se empieza a ver cuando el progreso supera el 75%
    if (state.progress > 0.75) {
      final double relativeProgress = 1.0 - state.progress;
      final double bossY = playerY - (relativeProgress * height * 2.5);

      final double bossRadius = 55.0;
      final Offset bossCenter = Offset(width / 2, bossY);

      // Dibujar área defensiva del jefe (Círculo rojo brillante)
      final zonePaint = Paint()
        ..color = GameTheme.neonRed.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(bossCenter, bossRadius * 1.6, zonePaint);

      final borderZonePaint = Paint()
        ..color = GameTheme.neonRed.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round;
      canvas.drawCircle(bossCenter, bossRadius * 1.6, borderZonePaint);

      // Dibujar cuerpo del Jefe (Octágono o Círculo premium)
      final bossPaint = Paint()
        ..color = GameTheme.slateBlue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(bossCenter, bossRadius, bossPaint);

      final bossGlowPaint = Paint()
        ..color = GameTheme.neonOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawCircle(bossCenter, bossRadius, bossGlowPaint);

      // Dibujar "Ojos" del jefe para que sea más imponente
      final eyePaint = Paint()..color = GameTheme.neonRed;
      canvas.drawCircle(
        Offset(bossCenter.dx - 18, bossCenter.dy - 10),
        6,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(bossCenter.dx + 18, bossCenter.dy - 10),
        6,
        eyePaint,
      );

      // Dibujar contador de soldados del jefe
      final bossCountStyle = const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: GameTheme.neonRed,
            offset: Offset(0, 0),
          ),
        ],
      );

      final textSpan = TextSpan(
        text: '${state.bossSoldiers}',
        style: bossCountStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(minWidth: bossRadius * 2);

      final textOffset = Offset(
        bossCenter.dx - bossRadius,
        bossCenter.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);

      // Dibujar soldados del jefe alrededor de él
      final int activeEnemies = state.bossSoldiers;
      if (activeEnemies > 0) {
        final double enemySoldierRadius = 6.0;
        final int maxVisualEnemies = min(activeEnemies, 40);

        final enemyPaint = Paint()..color = GameTheme.neonRed;

        for (int i = 0; i < maxVisualEnemies; i++) {
          // Distribuir en un anillo alrededor del jefe
          final double angle = (i * 2 * pi) / maxVisualEnemies;
          final double dist = bossRadius * 1.3;
          final double x = bossCenter.dx + cos(angle) * dist;
          final double y = bossCenter.dy + sin(angle) * dist;
          canvas.drawCircle(Offset(x, y), enemySoldierRadius, enemyPaint);
        }
      }
    }
  }

  /// Dibuja a Leo y a su ejército
  void _paintPlayerArmy(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Posición del jugador fija en el 75% del alto de la pantalla,
    // y la X depende del valor horizontal de Leo (-0.8 a 0.8 en escala de pista).
    final double trackWidth = width * 0.85;
    final double playerX = width / 2 + (state.leoX * trackWidth / 2);
    final double playerY = height * 0.75;
    final Offset playerCenter = Offset(playerX, playerY);

    // Dibujar a Leo (El avatar principal en el centro de la formación)
    final double leoRadius = 14.0;

    // Aura brillante alrededor de Leo
    final leoAura = Paint()
      ..color = GameTheme.neonCyan.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(playerCenter, leoRadius * 1.5, leoAura);

    // Cuerpo de Leo
    final leoPaint = Paint()
      ..color = GameTheme.slateBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(playerCenter, leoRadius, leoPaint);

    final leoBorder = Paint()
      ..color = GameTheme.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(playerCenter, leoRadius, leoBorder);

    // Corona/Detalle dorado para Leo (líder del ejército)
    final crownPaint = Paint()
      ..color =
          const Color(0xFFFFD700) // Oro
      ..style = PaintingStyle.fill;

    final crownPath = Path()
      ..moveTo(playerCenter.dx - 8, playerCenter.dy - 6)
      ..lineTo(playerCenter.dx - 8, playerCenter.dy - 13)
      ..lineTo(playerCenter.dx - 4, playerCenter.dy - 9)
      ..lineTo(playerCenter.dx, playerCenter.dy - 15)
      ..lineTo(playerCenter.dx + 4, playerCenter.dy - 9)
      ..lineTo(playerCenter.dx + 8, playerCenter.dy - 13)
      ..lineTo(playerCenter.dx + 8, playerCenter.dy - 6)
      ..close();
    canvas.drawPath(crownPath, crownPaint);

    // Dibujar Soldados del ejército (Clones)
    final double soldierRadius = 6.0;

    // Para dar un efecto de correr, usaremos una oscilación basada en el tiempo/progreso
    final double runCycle = sin(state.progress * 40 * pi) * 2.0;

    for (var soldier in state.soldiers) {
      if (soldier.id == 0) continue; // El 0 es Leo

      // Las posiciones offset son relativas a Leo
      double x = playerCenter.dx + soldier.currentOffsetX;
      // Añadir la oscilación vertical al correr para el dinamismo visual
      double y =
          playerCenter.dy +
          soldier.currentOffsetY +
          (soldier.id % 2 == 0 ? runCycle : -runCycle);

      // Pintar soldado individual con escala de animación
      final double size = soldierRadius * soldier.scale;
      if (size > 0) {
        final soldierPaint = Paint()
          ..color = soldier.color.withValues(alpha: soldier.scale)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), size, soldierPaint);

        // Brillo neón en el borde del soldado
        final soldierBorderPaint = Paint()
          ..color = Colors.white.withValues(alpha: soldier.scale * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(x, y), size, soldierBorderPaint);
      }
    }

    // Dibujar el total de soldados sobre el ejército (UI flotante)
    final countStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          blurRadius: 5.0,
          color: GameTheme.neonCyan,
          offset: Offset(0, 0),
        ),
      ],
    );

    final textSpan = TextSpan(
      text: '${state.soldiersCount}',
      style: countStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    // Posicionar el indicador de soldados flotando arriba del grupo
    final textOffset = Offset(
      playerCenter.dx - textPainter.width / 2,
      playerCenter.dy -
          35.0 -
          (state.soldiersCount > 30 ? 15 : 0), // Subir si hay muchos soldados
    );

    // Fondo de burbuja pequeña para el texto
    final bubblePaint = Paint()
      ..color = GameTheme.slateBlue.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        textOffset.dx - 8,
        textOffset.dy - 2,
        textPainter.width + 16,
        textPainter.height + 4,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(bubbleRect, bubblePaint);

    final bubbleBorder = Paint()
      ..color = GameTheme.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(bubbleRect, bubbleBorder);

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    // Repintar siempre que el progreso, la posición o la cantidad de soldados cambie
    return oldDelegate.state.progress != state.progress ||
        oldDelegate.state.leoX != state.leoX ||
        oldDelegate.state.soldiersCount != state.soldiersCount ||
        oldDelegate.state.bossSoldiers != state.bossSoldiers ||
        oldDelegate.state.status != state.status;
  }
}

/// Una clase de datos ligera que desacopla completamente el CustomPainter de la lógica
/// directa del ChangeNotifier, pasando solo lo necesario para el renderizado.
class GameControllerState {
  final GameStatus status;
  final double progress;
  final double leoX;
  final int soldiersCount;
  final List<Soldier> soldiers;
  final int bossSoldiers;
  final List<double> decisionZones;
  final List<MathProblem> levelProblems;
  final Map<int, int>
  soldiersCountAtPortal; // Mapea índice del portal con soldados que tenía Leo al entrar

  GameControllerState({
    required this.status,
    required this.progress,
    required this.leoX,
    required this.soldiersCount,
    required this.soldiers,
    required this.bossSoldiers,
    required this.decisionZones,
    required this.levelProblems,
    required this.soldiersCountAtPortal,
  });
}

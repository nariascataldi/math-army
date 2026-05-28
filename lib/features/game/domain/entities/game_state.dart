import 'package:flutter/material.dart';

enum GameStatus { idle, running, mathChallenge, bossBattle, victory, defeat }

/// Representa a un soldado individual del ejército del jugador.
/// Contiene datos para micro-animaciones en el CustomPainter.
class Soldier {
  final int id;
  // Posición relativa al avatar "Leo" (centro de la bandada)
  double targetOffsetX;
  double targetOffsetY;
  double currentOffsetX;
  double currentOffsetY;

  // Para animación de aparición
  double scale;
  Color color;

  Soldier({
    required this.id,
    this.targetOffsetX = 0.0,
    this.targetOffsetY = 0.0,
    this.currentOffsetX = 0.0,
    this.currentOffsetY = 0.0,
    this.scale = 0.0,
    this.color = const Color(0xFF00E5FF),
  });

  /// Actualiza suavemente la posición actual hacia la posición objetivo
  /// para dar un efecto orgánico de fluido/bandada.
  void update(double dt) {
    // Interpolación lineal suave (lerp) para las posiciones
    currentOffsetX += (targetOffsetX - currentOffsetX) * 0.1;
    currentOffsetY += (targetOffsetY - currentOffsetY) * 0.1;

    // Crecer gradualmente al aparecer
    if (scale < 1.0) {
      scale += dt * 4.0;
      if (scale > 1.0) scale = 1.0;
    }
  }
}

/// Representa al avatar principal, Leo.
class Leo {
  double
  x; // Posición horizontal (-1.0 es extremo izquierdo, 1.0 es extremo derecho)
  double speedY; // Velocidad de avance vertical

  Leo({
    this.x = 0.0,
    this.speedY =
        0.10, // Avance por segundo (0.10 significa 10% del recorrido por segundo)
  });
}

/// Representa al Jefe Enemigo en la meta.
class EnemyBoss {
  final int initialSoldiers = 70;
  int currentSoldiers = 70;
  final Color color = const Color(0xFFFF3131);

  EnemyBoss();
}

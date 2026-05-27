import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Para inyección de dependencias y reactividad
import '../controllers/game_controller.dart';
import '../widgets/game_painter.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/game_state.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          return SafeArea(
            child: Stack(
              children: [
                // 1. El lienzo principal del juego 2D
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // Mover horizontalmente a Leo según el arrastre del dedo.
                    // details.primaryDelta es en píxeles. Lo normalizamos al ancho de la pantalla.
                    final double screenWidth = MediaQuery.of(context).size.width;
                    final double normalizedDelta = (details.primaryDelta ?? 0.0) / (screenWidth * 0.4);
                    controller.moveLeo(normalizedDelta);
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: GamePainter(
                      state: GameControllerState(
                        status: controller.status,
                        progress: controller.progress,
                        leoX: controller.leo.x,
                        soldiersCount: controller.activeSoldiers.length,
                        soldiers: controller.activeSoldiers,
                        bossSoldiers: controller.boss.currentSoldiers,
                        decisionZones: controller.decisionZones,
                        levelProblems: controller.levelProblems,
                        soldiersCountAtPortal: controller.soldiersCountAtPortal,
                      ),
                    ),
                  ),
                ),

                // 2. Interfaz superior (HUD del juego)
                _buildHUD(context, controller),

                // 3. Fallback de controles táctiles laterales (Botones flotantes invisibles o semi-transparentes)
                if (controller.status == GameStatus.running)
                  _buildSideTouchControls(controller),

                // 4. Overlays de estado de juego (Idle, Victoria, Derrota, Batalla de Jefe)
                _buildGameOverlays(context, controller),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construye el HUD superior (Nivel, barra de progreso, botón de reinicio y mute)
  Widget _buildHUD(BuildContext context, GameController controller) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Indicador de nivel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: GameTheme.neonGlow(color: GameTheme.neonCyan),
                child: Text(
                  'NIVEL ${controller.currentLevel}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: GameTheme.neonCyan,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              
              // Botones de control rápido
              Row(
                children: [
                  // Silencio/Sonido
                  IconButton(
                    icon: Icon(
                      controller.audioSystem.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: GameTheme.neonCyan,
                    ),
                    onPressed: () => controller.toggleMute(),
                  ),
                  const SizedBox(width: 8),
                  // Reiniciar
                  IconButton(
                    icon: const Icon(Icons.refresh, color: GameTheme.neonCyan),
                    onPressed: () => controller.resetLevel(),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso de avance del nivel
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: GameTheme.neonCyan, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      backgroundColor: GameTheme.slateBlue,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        controller.progress > 0.85 ? GameTheme.neonOrange : GameTheme.neonCyan,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.stars_sharp, color: GameTheme.neonOrange, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  /// Botones táctiles a los lados como soporte de accesibilidad al arrastre
  Widget _buildSideTouchControls(GameController controller) {
    return Positioned.fill(
      child: Row(
        children: [
          // Lado Izquierdo
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => controller.moveLeo(-0.15),
              child: const SizedBox.expand(),
            ),
          ),
          // Lado Derecho
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => controller.moveLeo(0.15),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye los diferentes Overlays flotantes
  Widget _buildGameOverlays(BuildContext context, GameController controller) {
    switch (controller.status) {
      case GameStatus.idle:
        return _buildStartOverlay(context, controller);
      case GameStatus.bossBattle:
        return _buildBossBattleOverlay(context, controller);
      case GameStatus.victory:
        return _buildVictoryOverlay(context, controller);
      case GameStatus.defeat:
        return _buildDefeatOverlay(context, controller);
      case GameStatus.running:
        return const SizedBox.shrink();
    }
  }

  /// Overlay de pantalla de bienvenida / inicio de nivel
  Widget _buildStartOverlay(BuildContext context, GameController controller) {
    return Container(
      color: GameTheme.spaceCadet.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              Text(
                'MATH ARMY',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 42,
                  color: GameTheme.neonCyan,
                  shadows: [
                    const Shadow(
                      blurRadius: 15,
                      color: GameTheme.neonCyan,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¡El runner de matemáticas!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameTheme.textGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              
              // Tarjeta descriptiva
              Container(
                padding: const EdgeInsets.all(20),
                decoration: GameTheme.neonGlow(color: GameTheme.neonCyan.withOpacity(0.5)),
                child: Column(
                  children: [
                    Text(
                      'Misión del Nivel ${controller.currentLevel}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Controla al héroe "Leo" deslizando tu dedo a los lados.\n'
                      '2. Cruza por el portal matemático correcto.\n'
                      '3. ¡Reúne al menos 70 soldados para vencer al jefe enemigo!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GameTheme.textWhite,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Botón de Inicio
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.neonCyan,
                  foregroundColor: GameTheme.spaceCadet,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  shadowColor: GameTheme.neonCyan,
                ),
                onPressed: () => controller.startGame(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '¡JUGAR AHORA!',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: GameTheme.spaceCadet,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.play_arrow_rounded, size: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pequeño indicador del estado de la batalla contra el jefe
  Widget _buildBossBattleOverlay(BuildContext context, GameController controller) {
    return Positioned(
      bottom: 80,
      left: 32,
      right: 32,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: GameTheme.neonGlow(color: GameTheme.neonOrange),
        child: Column(
          children: [
            Text(
              '¡COMBATE FINAL!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: GameTheme.neonOrange,
                fontSize: 20,
                shadows: [
                  const Shadow(blurRadius: 10, color: GameTheme.neonOrange),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.people, color: GameTheme.neonCyan),
                    Text(
                      '${controller.activeSoldiers.length}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Tu Ejército', style: TextStyle(fontSize: 10, color: GameTheme.textGrey)),
                  ],
                ),
                const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                Column(
                  children: [
                    const Icon(Icons.security, color: GameTheme.neonRed),
                    Text(
                      '${controller.boss.currentSoldiers}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Jefe Enemigo', style: TextStyle(fontSize: 10, color: GameTheme.textGrey)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Overlay en caso de ganar el nivel
  Widget _buildVictoryOverlay(BuildContext context, GameController controller) {
    return Container(
      color: GameTheme.spaceCadet.withOpacity(0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                '¡VICTORIA!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 46,
                  color: GameTheme.neonGreen,
                  shadows: [
                    const Shadow(
                      blurRadius: 15,
                      color: GameTheme.neonGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Derrotaste al jefe enemigo con éxito.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameTheme.textWhite,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.neonGreen,
                  foregroundColor: GameTheme.spaceCadet,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: GameTheme.neonGreen,
                  elevation: 10,
                ),
                onPressed: () => controller.nextLevel(),
                child: Text(
                  'SIGUIENTE NIVEL',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: GameTheme.spaceCadet,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Overlay en caso de perder el nivel
  Widget _buildDefeatOverlay(BuildContext context, GameController controller) {
    return Container(
      color: GameTheme.spaceCadet.withOpacity(0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sentiment_very_dissatisfied,
                color: GameTheme.neonRed,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'DERROTA',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 46,
                  color: GameTheme.neonRed,
                  shadows: [
                    const Shadow(
                      blurRadius: 15,
                      color: GameTheme.neonRed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu ejército no fue lo suficientemente grande.\n'
                '¡El jefe requiere al menos 70 soldados!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameTheme.textWhite,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: Calcula mentalmente antes de cruzar los portales.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameTheme.neonCyan,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.neonRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: GameTheme.neonRed,
                  elevation: 10,
                ),
                onPressed: () => controller.resetLevel(),
                child: Text(
                  'REINTENTAR',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/audio_utils.dart';
import '../../../math_engine/domain/entities/math_problem.dart';
import '../../../math_engine/domain/repositories/math_repository.dart';
import '../../domain/entities/game_state.dart';

class GameController extends ChangeNotifier {
  final MathRepository mathRepository;
  final AudioSystem audioSystem;

  // Estado del juego
  GameStatus status = GameStatus.idle;
  int currentLevel = 1;
  double progress = 0.0; // Progresión del recorrido (0.0 a 1.0)
  
  // Personajes y entidades
  final Leo leo = Leo();
  final EnemyBoss boss = EnemyBoss();
  List<Soldier> activeSoldiers = [];
  List<MathProblem> levelProblems = [];
  final Map<int, int> soldiersCountAtPortal = {};
  
  // Zonas de decisión (posiciones de progreso donde aparecen los portales)
  final List<double> decisionZones = [0.18, 0.36, 0.54, 0.72, 0.90];
  int nextDecisionZoneIndex = 0;

  // Bucle de físicas y animación
  Ticker? _ticker;
  Duration? _lastElapsed;

  // Timer para la batalla final contra el jefe
  Timer? _battleTimer;

  GameController({
    required this.mathRepository,
    required this.audioSystem,
  }) {
    _initLevel();
  }

  void _initLevel() {
    progress = 0.0;
    leo.x = 0.0;
    nextDecisionZoneIndex = 0;
    status = GameStatus.idle;
    boss.currentSoldiers = boss.initialSoldiers;
    soldiersCountAtPortal.clear();
    
    // Obtener problemas para el nivel actual
    levelProblems = mathRepository.getProblemsForLevel(currentLevel);
    
    // Inicializar con 1 soldado (el propio Leo o su primer escolta)
    activeSoldiers.clear();
    _setSoldierCount(1);
    
    notifyListeners();
  }

  /// Inicia el juego
  void startGame() {
    if (status != GameStatus.idle) return;
    status = GameStatus.running;
    
    _ticker = Ticker(_onTick);
    _lastElapsed = null;
    _ticker!.start();
    
    notifyListeners();
  }

  /// Reinicia el nivel actual
  void resetLevel() {
    _cleanup();
    _initLevel();
  }

  /// Pasa al siguiente nivel
  void nextLevel() {
    _cleanup();
    currentLevel++;
    _initLevel();
    startGame();
  }

  /// Silencia o activa el sistema de sonido del juego
  void toggleMute() {
    audioSystem.toggleMute();
    notifyListeners();
  }

  /// Limpia los tickers y timers para evitar fugas de memoria
  void _cleanup() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    _battleTimer?.cancel();
    _battleTimer = null;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  /// Actualización de físicas por fotograma (Game Loop)
  void _onTick(Duration elapsed) {
    if (status != GameStatus.running) return;

    if (_lastElapsed == null) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt = (elapsed.inMicroseconds - _lastElapsed!.inMicroseconds) / 1000000.0;
    _lastElapsed = elapsed;

    // 1. Avanzar progreso del runner
    progress += leo.speedY * dt;
    if (progress >= 0.98) {
      progress = 1.0;
      _ticker?.stop();
      _startBossBattle();
    }

    // 2. Verificar colisión con portales matemáticos
    if (nextDecisionZoneIndex < decisionZones.length &&
        nextDecisionZoneIndex < levelProblems.length) {
      final double zoneProgress = decisionZones[nextDecisionZoneIndex];
      
      // Si cruzamos el portal en el eje Y
      if (progress >= zoneProgress) {
        _handlePortalCollision();
      }
    }

    // 3. Actualizar posiciones físicas de los soldados (suavizado del CustomPainter)
    for (var soldier in activeSoldiers) {
      soldier.update(dt);
    }

    notifyListeners();
  }

  /// Procesa la colisión con el portal basándose en la posición lateral de Leo
  void _handlePortalCollision() {
    final problem = levelProblems[nextDecisionZoneIndex];
    final int previousCount = activeSoldiers.length;
    
    // Registrar el recuento antes de aplicar la operación
    soldiersCountAtPortal[nextDecisionZoneIndex] = previousCount;
    
    // Si Leo está a la izquierda (x < 0) entra por el Portal A, si no por el Portal B
    final int selectedPortalIndex = leo.x < 0 ? 0 : 1;
    final int correctPortalIndex = problem.getCorrectOptionIndex(previousCount);
    
    final operation = problem.getOperationByIndex(selectedPortalIndex);
    final int newCount = operation.apply(previousCount);
    
    _setSoldierCount(newCount);

    if (selectedPortalIndex == correctPortalIndex) {
      audioSystem.playPortalSuccess();
    } else {
      audioSystem.playPortalFailure();
    }

    nextDecisionZoneIndex++;
  }

  /// Mover lateralmente a Leo (Control táctil o botón)
  void moveLeo(double deltaX) {
    if (status != GameStatus.running) return;
    
    // Limitar la posición horizontal de Leo a los bordes de la pista (-0.8 a 0.8)
    leo.x = (leo.x + deltaX).clamp(-0.8, 0.8);
    _recalculateSoldierFormations();
    notifyListeners();
  }

  /// Ajusta el total de soldados de forma animada e inteligente
  void _setSoldierCount(int targetCount) {
    final int currentCount = activeSoldiers.length;

    if (targetCount > currentCount) {
      // Agregar nuevos soldados
      for (int i = currentCount; i < targetCount; i++) {
        // Nacen desde la posición central actual de Leo para un efecto visual de explosión
        activeSoldiers.add(
          Soldier(
            id: i,
            currentOffsetX: 0.0,
            currentOffsetY: 0.0,
          ),
        );
        if (i - currentCount < 10) {
          audioSystem.playSoldierSpawn();
        }
      }
    } else if (targetCount < currentCount) {
      // Eliminar soldados sobrantes
      activeSoldiers.removeRange(targetCount, currentCount);
    }

    _recalculateSoldierFormations();
  }

  /// Algoritmo de formación concéntrica para los soldados alrededor de Leo.
  /// Genera un efecto orgánico en el CustomPainter.
  void _recalculateSoldierFormations() {
    if (activeSoldiers.isEmpty) return;

    // El primer soldado (id: 0) siempre va en el centro (Leo)
    activeSoldiers[0].targetOffsetX = 0.0;
    activeSoldiers[0].targetOffsetY = 0.0;

    int soldierIndex = 1;
    int layer = 1;

    // Distribuimos a los soldados restantes en capas concéntricas
    while (soldierIndex < activeSoldiers.length) {
      // Capacidad de la capa actual
      final int layerCapacity = layer * 6;
      final double radius = layer * 18.0; // Distancia entre capas de soldados (en píxeles)

      for (int i = 0; i < layerCapacity && soldierIndex < activeSoldiers.length; i++) {
        final double angle = (i * 2 * pi) / layerCapacity;
        
        // Asignar posición ideal
        activeSoldiers[soldierIndex].targetOffsetX = cos(angle) * radius;
        activeSoldiers[soldierIndex].targetOffsetY = sin(angle) * radius;
        
        soldierIndex++;
      }
      layer++;
    }
  }

  /// Inicia el combate automático contra el jefe final
  void _startBossBattle() {
    status = GameStatus.bossBattle;
    notifyListeners();

    // Iniciar timer recurrente para combatir a los soldados 1 a 1
    _battleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (activeSoldiers.isEmpty && boss.currentSoldiers > 0) {
        // Derrota: nos quedamos sin soldados pero el jefe aún tiene
        status = GameStatus.defeat;
        audioSystem.playDefeat();
        _battleTimer?.cancel();
      } else if (boss.currentSoldiers <= 0) {
        // Victoria: el jefe fue derrotado y aún nos quedan soldados
        status = GameStatus.victory;
        audioSystem.playVictory();
        _battleTimer?.cancel();
      } else {
        // Colisión: se eliminan mutuamente 1 a 1
        boss.currentSoldiers--;
        activeSoldiers.removeLast();
        _recalculateSoldierFormations();
      }
      notifyListeners();
    });
  }
}

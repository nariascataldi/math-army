import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/audio_utils.dart';
import '../../../math_engine/domain/entities/math_operation.dart';
import '../../../math_engine/domain/entities/math_problem.dart';
import '../../../math_engine/domain/repositories/math_repository.dart';
import '../../domain/entities/game_state.dart';

class GameController extends ChangeNotifier {
  final MathRepository mathRepository;
  final AudioSystem audioSystem;

  // Estado del juego
  GameStatus status = GameStatus.idle;
  int currentLevel = 1;
  double progress = 0.0;

  // Personajes y entidades
  final Leo leo = Leo();
  final EnemyBoss boss = EnemyBoss();
  List<Soldier> activeSoldiers = [];
  List<MathProblem> levelProblems = [];
  final Map<int, int> soldiersCountAtPortal = {};

  // Zonas de decisión
  final List<double> decisionZones = [0.18, 0.36, 0.54, 0.72, 0.90];
  int nextDecisionZoneIndex = 0;

  // Estado del challenge matemático (2 fases)
  int _challengeSoldiersCount = 0;
  int get challengeSoldiersCount => _challengeSoldiersCount;
  int _currentChallengeIndex = 0;
  int get currentChallengeIndex => _currentChallengeIndex;
  MathChallengePhase _challengePhase = MathChallengePhase.question;
  MathChallengePhase get challengePhase => _challengePhase;
  int _mathResult = 0;
  int get mathResult => _mathResult;

  // Bucle de físicas y animación
  Ticker? _ticker;
  Duration? _lastElapsed;

  // Timer para la batalla final contra el jefe
  Timer? _battleTimer;

  GameController({required this.mathRepository, required this.audioSystem}) {
    _initLevel();
  }

  void _initLevel() {
    progress = 0.0;
    leo.x = 0.0;
    nextDecisionZoneIndex = 0;
    status = GameStatus.idle;
    boss.currentSoldiers = boss.initialSoldiers;
    soldiersCountAtPortal.clear();
    _challengePhase = MathChallengePhase.question;

    levelProblems = mathRepository.getProblemsForLevel(currentLevel);

    activeSoldiers.clear();
    _setSoldierCount(1);

    notifyListeners();
  }

  void startGame() {
    if (status != GameStatus.idle) return;
    status = GameStatus.running;

    _ticker = Ticker(_onTick);
    _lastElapsed = null;
    _ticker!.start();

    notifyListeners();
  }

  void resetLevel() {
    _cleanup();
    _initLevel();
  }

  void nextLevel() {
    _cleanup();
    currentLevel++;
    _initLevel();
    startGame();
  }

  void toggleMute() {
    audioSystem.toggleMute();
    notifyListeners();
  }

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

  void _onTick(Duration elapsed) {
    if (status != GameStatus.running) return;

    if (_lastElapsed == null) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt =
        (elapsed.inMicroseconds - _lastElapsed!.inMicroseconds) / 1000000.0;
    _lastElapsed = elapsed;

    progress += leo.speedY * dt;
    if (progress >= 0.98) {
      progress = 1.0;
      _ticker?.stop();
      _startBossBattle();
    }

    if (nextDecisionZoneIndex < decisionZones.length &&
        nextDecisionZoneIndex < levelProblems.length) {
      final double zoneProgress = decisionZones[nextDecisionZoneIndex];
      if (progress >= zoneProgress) {
        _showMathChallenge();
      }
    }

    for (var soldier in activeSoldiers) {
      soldier.update(dt);
    }

    notifyListeners();
  }

  /// Inicia el challenge en Fase 1 (pregunta matemática)
  void _showMathChallenge() {
    _ticker?.stop();
    _currentChallengeIndex = nextDecisionZoneIndex;
    _challengeSoldiersCount = activeSoldiers.length;
    _challengePhase = MathChallengePhase.question;
    soldiersCountAtPortal[nextDecisionZoneIndex] = _challengeSoldiersCount;
    status = GameStatus.mathChallenge;
    notifyListeners();
  }

  /// FASE 1: Procesa la respuesta a la pregunta matemática
  void submitMathAnswer(int selectedIndex) {
    if (status != GameStatus.mathChallenge) return;
    if (_challengePhase != MathChallengePhase.question) return;

    final problem = levelProblems[_currentChallengeIndex];
    final question = problem.getMathQuestion(_challengeSoldiersCount);
    final bool isCorrect = selectedIndex == question.correctIndex;

    // Bonus/penalty fijo por responder
    int bonus;
    if (isCorrect) {
      bonus = 5;
      audioSystem.playPortalSuccess();
    } else {
      bonus = -3;
      audioSystem.playPortalFailure();
    }

    _mathResult = _challengeSoldiersCount + bonus;
    if (_mathResult < 0) _mathResult = 0;
    _setSoldierCount(_mathResult);

    // Transicionar a Fase 2 después del feedback
    Future.delayed(const Duration(milliseconds: 600), () {
      if (status == GameStatus.mathChallenge) {
        _challengePhase = MathChallengePhase.operationChoice;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// FASE 2: Procesa la elección de operación
  void submitOperationChoice(int selectedIndex) {
    if (status != GameStatus.mathChallenge) return;
    if (_challengePhase != MathChallengePhase.operationChoice) return;

    final problem = levelProblems[_currentChallengeIndex];
    final choices = problem.getOperationChoices(_mathResult);
    final chosen = choices[selectedIndex];

    // Aplicar la operación elegida al resultado de la fase 1
    final int newCount = chosen.operation.type == MathOperationType.div
        ? _mathResult *
              chosen
                  .operation
                  .value // En fase 2, div se convierte en mult
        : chosen.operation.type == MathOperationType.sub
        ? _mathResult +
              chosen
                  .operation
                  .value // En fase 2, sub se convierte en add
        : chosen.operation.apply(_mathResult);

    _setSoldierCount(newCount);
    nextDecisionZoneIndex++;

    audioSystem.playPortalSuccess();

    // Reanudar el juego después del feedback
    Future.delayed(const Duration(milliseconds: 800), () {
      if (status == GameStatus.mathChallenge) {
        status = GameStatus.running;
        _challengePhase = MathChallengePhase.question;
        _lastElapsed = null;
        _ticker?.start();
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void moveLeo(double deltaX) {
    if (status != GameStatus.running) return;
    leo.x = (leo.x + deltaX).clamp(-0.8, 0.8);
    _recalculateSoldierFormations();
    notifyListeners();
  }

  void _setSoldierCount(int targetCount) {
    final int currentCount = activeSoldiers.length;

    if (targetCount > currentCount) {
      for (int i = currentCount; i < targetCount; i++) {
        activeSoldiers.add(
          Soldier(id: i, currentOffsetX: 0.0, currentOffsetY: 0.0),
        );
        if (i - currentCount < 10) {
          audioSystem.playSoldierSpawn();
        }
      }
    } else if (targetCount < currentCount) {
      activeSoldiers.removeRange(targetCount, currentCount);
    }

    _recalculateSoldierFormations();
  }

  void _recalculateSoldierFormations() {
    if (activeSoldiers.isEmpty) return;

    activeSoldiers[0].targetOffsetX = 0.0;
    activeSoldiers[0].targetOffsetY = 0.0;

    int soldierIndex = 1;
    int layer = 1;

    while (soldierIndex < activeSoldiers.length) {
      final int layerCapacity = layer * 6;
      final double radius = layer * 18.0;

      for (
        int i = 0;
        i < layerCapacity && soldierIndex < activeSoldiers.length;
        i++
      ) {
        final double angle = (i * 2 * pi) / layerCapacity;
        activeSoldiers[soldierIndex].targetOffsetX = cos(angle) * radius;
        activeSoldiers[soldierIndex].targetOffsetY = sin(angle) * radius;
        soldierIndex++;
      }
      layer++;
    }
  }

  void _startBossBattle() {
    status = GameStatus.bossBattle;
    notifyListeners();

    _battleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (activeSoldiers.isEmpty && boss.currentSoldiers > 0) {
        status = GameStatus.defeat;
        audioSystem.playDefeat();
        _battleTimer?.cancel();
      } else if (boss.currentSoldiers <= 0) {
        status = GameStatus.victory;
        audioSystem.playVictory();
        _battleTimer?.cancel();
      } else {
        boss.currentSoldiers--;
        activeSoldiers.removeLast();
        _recalculateSoldierFormations();
      }
      notifyListeners();
    });
  }
}
